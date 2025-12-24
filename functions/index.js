const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

admin.initializeApp();

// ⏰ ZAMAN AYARI: Her gün 10:00 (Türkiye Saati)
exports.checkSubscriptionReminders = onSchedule(
  {
    schedule: "every day 10:00",
    timeZone: "Europe/Istanbul",
    region: "us-central1",
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // 1. --- BUGÜNÜN TARİHİNİ BELİRLE (TÜRKİYE SAATİYLE) ---
    const now = new Date();
    // Türkiye saatine göre tarihi string'e çevir (Örn: "12/24/2025")
    const turkeyDateString = now.toLocaleDateString("en-US", {
        timeZone: "Europe/Istanbul"
    });
    // O string'den temiz bir tarih objesi oluştur (Saat 00:00:00 olur)
    const today = new Date(turkeyDateString);

    logger.info(`📅 Kontrol Tarihi (TR): ${today.toDateString()}`);

    try {
      const snapshot = await db.collectionGroup("subscriptions")
        .where("reminderEnabled", "==", true)
        .where("status", "==", "active")
        .get();

      if (snapshot.empty) {
        logger.info("📭 Hatırlatılacak aktif abonelik yok.");
        return;
      }

      const promises = [];
      let sentCount = 0;

      for (const doc of snapshot.docs) {
        const sub = doc.data();

        // nextBillingDate yoksa veya userId yoksa atla
        if (!sub.nextBillingDate || !sub.userId) continue;

        // 2. --- TIMESTAMP VERİSİNİ İŞLEME VE SAAT DİLİMİ DÜZELTMESİ ---
        let billingTimestampAsDate;

        try {
            // Firestore Timestamp kontrolü (.toDate fonksiyonu var mı?)
            if (typeof sub.nextBillingDate.toDate === 'function') {
                billingTimestampAsDate = sub.nextBillingDate.toDate();
            } else {
                // String veya JS Date geldiyse (Eski veri veya farklı format)
                billingTimestampAsDate = new Date(sub.nextBillingDate);
            }
        } catch (e) {
            logger.warn(`⚠️ Tarih format hatası (Doc ID: ${doc.id}):`, e);
            continue;
        }

        // ÖNEMLİ: Timestamp UTC gelir (Örn: 23 Aralık 21:00).
        // Bunu doğrudan setHours(0) yaparsan sunucu UTC ise 23 Aralık olarak kalır.
        // Oysa Türkiye'de o an 24 Aralık'tır.
        // Çözüm: Fatura tarihini de Türkiye saatine göre String'e çevirip, tekrar Date yapıyoruz.

        const billDateTurkeyString = billingTimestampAsDate.toLocaleDateString("en-US", {
            timeZone: "Europe/Istanbul"
        });

        // Artık elimizde faturanın Türkiye'deki tam GÜNÜ var (Saat 00:00:00)
        const nextBillDateTR = new Date(billDateTurkeyString);

        // 3. --- HATIRLATMA GÜNÜNÜ HESAPLA ---
        const daysBefore = sub.reminderDaysBefore || 1;

        // Fatura tarihinden gün sayısını çıkar
        const reminderDate = new Date(nextBillDateTR);
        reminderDate.setDate(reminderDate.getDate() - daysBefore);

        // Debug Log (Sadece yakın tarihleri logla)
        if (Math.abs(reminderDate.getTime() - today.getTime()) < 86400000) {
             logger.info(`🔍 İnceleme: ${sub.name} -> Hedef: ${reminderDate.toDateString()} | Bugün: ${today.toDateString()}`);
        }

        // 4. --- EŞLEŞTİRME ---
        // Artık iki tarih de string dönüşümüyle oluşturulduğu için saatleri 00:00:00'dır.
        // Güvenle milisaniye karşılaştırması yapabiliriz.
        if (reminderDate.getTime() === today.getTime()) {
           logger.info(`🔔 EŞLEŞTİ! ${sub.name} bildirimi gönderiliyor.`);
           promises.push(sendNotification(db, messaging, sub.userId, sub));
           sentCount++;
        }
      }

      if (promises.length > 0) {
        await Promise.all(promises);
      }

      logger.info(`✅ İşlem tamamlandı. Bugün ${sentCount} kişiye bildirim gönderildi.`);

    } catch (error) {
      logger.error("🔥 Kritik Hata:", error);
    }
  }
);

async function sendNotification(db, messaging, userId, sub) {
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data();
    const token = userData.fcmToken;

    if (!token) {
        logger.warn(`🚫 Token yok: ${userId}`);
        return;
    }

    const message = {
      token: token,
      notification: {
        title: "Ödemeniz Yaklaşıyor! 🔔",
        body: `${sub.name} ödemeniz ${sub.reminderDaysBefore} gün içinde yapılacak. Tutar: ${sub.amount} ${sub.currency || ''}`,
      },
      data: {
        route: "/subscriptions",
        subscriptionId: sub.id ? sub.id.toString() : "", // ID string olmalı
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
    };

    await messaging.send(message);
    logger.info(`🚀 Gönderildi -> ${sub.name}`);

  } catch (error) {
    logger.error(`❌ Bildirim hatası (User: ${userId}):`, error.message);
  }
}