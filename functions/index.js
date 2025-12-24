const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

admin.initializeApp();

// 🌍 GLOBAL ZAMANLAYICI: Her saat başı çalışır (Cron: Dakika 0)
exports.checkSubscriptionReminders = onSchedule(
  {
    schedule: "0 * * * *",
    region: "us-central1", // Veya tercih ettiğin bölge
    timeoutSeconds: 540,   // Uzun süren işlemler için süre (9 dk)
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // 1. --- HANGİ SAAT DİLİMİNİ KONTROL EDECEĞİZ? ---
    const now = new Date();
    const currentUtcHour = now.getUTCHours();

    // HEDEF: Yerel saati 10:00 olan kullanıcıları bulmak.
    // Formül: (UTC Saati + Kullanıcı Offseti) = 10
    // Buradan Kullanıcı Offseti'ni çekiyoruz:
    let targetOffset = 10 - currentUtcHour;

    // Offset döngüsü düzeltmesi (-12 ile +14 arası standarttır)
    // Örn: UTC 23:00 ise (10-23 = -13) -> +11 (Yeni günün sabahı)
    if (targetOffset <= -12) targetOffset += 24;
    if (targetOffset > 14) targetOffset -= 24;

    logger.info(`🌍 Global Kontrol (UTC: ${currentUtcHour}:00) -> Hedef Offset: ${targetOffset} (Bu bölgedeki kullanıcılara günaydın deme vakti ☀️)`);

    try {
      // 2. --- KULLANICILARI BUL ---
      // 'utcOffset' alanı hesapladığımız değere eşit olan kullanıcıları getir
      const usersSnapshot = await db.collection("users")
        .where("utcOffset", "==", targetOffset)
        .get();

      if (usersSnapshot.empty) {
        logger.info(`ℹ️ Offseti ${targetOffset} olan kullanıcı bulunamadı, bu saat dilimi boş.`);
        return;
      }

      logger.info(`👥 Bu saat diliminde ${usersSnapshot.size} kullanıcı bulundu. Kontroller başlıyor...`);

      const promises = [];
      let sentCount = 0;

      // 3. --- KULLANICILARI TARA ---
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        // Token yoksa bildirimi atla
        if (!fcmToken) continue;

        // Kullanıcının "Bugünü"nü hesapla (Saat 00:00:00 olarak)
        // Kullanıcının yerel saati şu an 10:00 olduğu için, UTC zamanına offset ekleyerek yerel zamanı buluyoruz.
        const localNowMs = now.getTime() + (targetOffset * 3600000); // 1 saat = 3600000 ms
        const localDateObj = new Date(localNowMs);

        // Sadece Tarih kısmını alıp (YYYY-MM-DD), saatini sıfırlıyoruz.
        // Bu işlem milisaniye karşılaştırmasında hatayı önler.
        const todayString = localDateObj.toISOString().split('T')[0]; // "2025-12-25" gibi
        const todayDate = new Date(todayString); // UTC 00:00 olarak parse eder

        // --- ABONELİKLERİ ÇEK ---
        // Collection Group yerine kullanıcının alt koleksiyonuna gidiyoruz (Daha hızlı ve güvenli)
        const subsSnapshot = await db.collection(`users/${userId}/subscriptions`)
            .where("reminderEnabled", "==", true)
            .where("status", "==", "active")
            .get();

        if (subsSnapshot.empty) continue;

        for (const subDoc of subsSnapshot.docs) {
            const sub = subDoc.data();

            if (!sub.nextBillingDate) continue;

            // Fatura Tarihini JS Date Objesine Çevir
            let billingDate;
            try {
                if (typeof sub.nextBillingDate.toDate === 'function') {
                    billingDate = sub.nextBillingDate.toDate();
                } else {
                    billingDate = new Date(sub.nextBillingDate);
                }
            } catch (e) { continue; }

            // Fatura tarihini de "YYYY-MM-DD" stringine çevirip tekrar Date yaparak saatini sıfırlıyoruz.
            // Bu sayede "25 Aralık 21:00" ile "25 Aralık 00:00" karmaşasını çözüyoruz.
            const billString = billingDate.toISOString().split('T')[0];
            const cleanBillDate = new Date(billString);

            // --- GÜN SAYISI (String/Number hatası çözümü) ---
            let reminderDays = 1;
            if (sub.reminderDaysBefore !== undefined && sub.reminderDaysBefore !== null) {
                 const parsed = parseInt(sub.reminderDaysBefore, 10);
                 if (!isNaN(parsed)) reminderDays = parsed;
            }

            // HEDEF TARİH = Fatura Tarihi - Gün Sayısı
            // JS Date objelerinde gün çıkarmak için setDate kullanılır
            const targetReminderDate = new Date(cleanBillDate);
            targetReminderDate.setDate(cleanBillDate.getDate() - reminderDays);

            // --- KARŞILAŞTIRMA ---
            // Bugün o gün mü?
            if (targetReminderDate.getTime() === todayDate.getTime()) {
                 logger.info(`🔔 EŞLEŞTİ! User: ${userId} | Sub: ${sub.name} | Fatura: ${billString}`);
                 promises.push(sendNotification(messaging, fcmToken, sub));
                 sentCount++;
            }
        }
      }

      if (promises.length > 0) {
        await Promise.all(promises);
      }

      logger.info(`✅ Döngü bitti. Toplam ${sentCount} bildirim gönderildi.`);

    } catch (error) {
      logger.error("🔥 Global Fonksiyon Hatası:", error);
    }
  }
);

// Bildirim Gönderme Yardımcı Fonksiyonu
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
        logger.error(`❌ Bildirim gönderilemedi (${sub.name}):`, e.message);
    }
}