const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

admin.initializeApp();

// 🌍 SEKTÖR STANDARDI: GLOBAL HATIRLATMA SERVİSİ
// Bu fonksiyon her saat başı çalışır ve dünya üzerinde saati 10:00 olan herkese bakar.
exports.checkSubscriptionReminders = onSchedule(
  {
    schedule: "0 * * * *",  // Her saatin 0. dakikası (00:00, 01:00...)
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // 1. --- HEDEF KİTLE TESPİTİ ---
    const now = new Date();
    const currentUtcHour = now.getUTCHours();

    // Formül: Yerel saati 10:00 olan offseti bul.
    // Offset = HedefSaat(10) - UTC_Saati
    let targetOffset = 10 - currentUtcHour;

    // Matematiksel döngü düzeltmesi (-12 ile +14 arası)
    if (targetOffset <= -12) targetOffset += 24;
    if (targetOffset > 14) targetOffset -= 24;

    logger.info(`🌍 Global Saat Kontrolü: UTC ${currentUtcHour}:00 | Hedeflenen Offset: ${targetOffset}`);

    try {
      // 2. --- KULLANICILARI GETİR ---
      const usersSnapshot = await db.collection("users")
        .where("utcOffset", "==", targetOffset)
        .get();

      if (usersSnapshot.empty) {
        logger.info(`ℹ️ Offset ${targetOffset} bölgesinde kullanıcı yok.`);
        return;
      }

      const promises = [];
      let sentCount = 0;

      // 3. --- TARİH NORMALİZASYONU İÇİN YARDIMCI ---
      // Verilen tarihi, "YYYY-MM-DD" stringine çevirip, sonra UTC 12:00 olarak geri döndürür.
      // Bu, saat farklarından doğan hataları YOK EDER.
      const normalizeToUtcNoon = (dateObj, offsetHours = 0) => {
        // Tarihi kullanıcının yerel saatine kaydır (Milisaniye cinsinden)
        const localMs = dateObj.getTime() + (offsetHours * 3600000);
        const localDate = new Date(localMs);

        // YYYY-MM-DD formatını al
        const year = localDate.getUTCFullYear();
        const month = localDate.getUTCMonth(); // 0-11
        const day = localDate.getUTCDate();

        // Temiz bir UTC tarihi oluştur (Saat 12:00:00)
        return new Date(Date.UTC(year, month, day, 12, 0, 0));
      };

      // Kullanıcının "Bugünü" (UTC 12:00'ye normalize edilmiş)
      const userTodayNormalized = normalizeToUtcNoon(now, targetOffset);

      logger.info(`📅 Bu bölge için 'Bugün' kabul edilen tarih: ${userTodayNormalized.toISOString().split('T')[0]}`);

      // 4. --- KULLANICILARI TARA ---
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        if (!fcmToken) continue;

        const subsSnapshot = await db.collection(`users/${userId}/subscriptions`)
            .where("reminderEnabled", "==", true)
            .where("status", "==", "active")
            .get();

        if (subsSnapshot.empty) continue;

        for (const subDoc of subsSnapshot.docs) {
            const sub = subDoc.data();
            if (!sub.nextBillingDate) continue;

            // Fatura Tarihini JS Date Objesine Çevir
            let rawBillingDate;
            try {
                rawBillingDate = sub.nextBillingDate.toDate ? sub.nextBillingDate.toDate() : new Date(sub.nextBillingDate);
            } catch (e) { continue; }

            // 🔥 KRİTİK ADIM: Faturayı Normalize Et
            // Fatura tarihini UTC 12:00'ye sabitliyoruz.
            // +12 Saat ekleme mantığını (data skew fix) burada uyguluyoruz.
            // Bu, gece yarısı (00:00) kaydedilen verilerin batı ülkelerinde bir önceki güne düşmesini engeller.
            const billDateAdjusted = new Date(rawBillingDate.getTime() + (12 * 3600000));
            const billDateNormalized = normalizeToUtcNoon(billDateAdjusted, targetOffset);

            // GÜN FARKINI HESAPLA (Milisaniye farkı / Bir gün)
            const diffTime = billDateNormalized.getTime() - userTodayNormalized.getTime();
            const daysDiff = Math.round(diffTime / (1000 * 60 * 60 * 24));

            // Hatırlatma ayarını al (Yoksa 1 gün)
            let reminderDays = 1;
            if (sub.reminderDaysBefore !== undefined && sub.reminderDaysBefore !== null) {
                 const parsed = parseInt(sub.reminderDaysBefore, 10);
                 if (!isNaN(parsed)) reminderDays = parsed;
            }

            // --- DEBUG LOGU (Sadece yakın tarihleri gör) ---
            if (Math.abs(daysDiff) <= reminderDays + 1) {
                logger.info(`🔍 DEBUG: ${sub.name} (User: ${userId})
                | User Today: ${userTodayNormalized.toISOString().split('T')[0]}
                | Bill Date : ${billDateNormalized.toISOString().split('T')[0]}
                | Kalan Gün : ${daysDiff}
                | Ayarlı    : ${reminderDays}`);
            }

            // EŞLEŞTİRME
            if (daysDiff === reminderDays) {
                 logger.info(`🚀 BİLDİRİM GÖNDERİLİYOR: ${sub.name}`);
                 promises.push(sendNotification(messaging, fcmToken, sub));
                 sentCount++;
            }
        }
      }

      if (promises.length > 0) {
        await Promise.all(promises);
      }
      logger.info(`✅ Döngü Bitti. Gönderilen: ${sentCount}`);

    } catch (error) {
      logger.error("🔥 Kritik Hata:", error);
    }
  }
);

async function sendNotification(messaging, token, sub) {
    try {
        const message = {
          token: token,
          notification: {
            title: "Ödemeniz Yaklaşıyor! 🔔",
            body: `${sub.name} ödemeniz ${sub.reminderDaysBefore} gün içinde yapılacak. Tutar: ${sub.amount} ${sub.currency || ''}`,
          },
          data: {
            route: "/subscriptions",
            subscriptionId: sub.id ? sub.id.toString() : "",
            click_action: "FLUTTER_NOTIFICATION_CLICK"
          },
        };
        await messaging.send(message);
    } catch (e) {
        logger.error(`❌ Gönderim Hatası:`, e.message);
    }
}