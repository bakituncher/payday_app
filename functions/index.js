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

    // --- SAAT DİLİMİ DÜZELTMESİ ---
    // Sunucu saati (UTC) yerine Türkiye saatini (UTC+3) baz alıyoruz.
    const now = new Date();

    // Türkiye'deki günün tarihini string olarak al (Örn: "12/24/2025")
    const turkeyDateString = now.toLocaleDateString("en-US", {
        timeZone: "Europe/Istanbul"
    });

    // O string'den yeni bir tarih objesi oluştur (Otomatik olarak 00:00 olur)
    const today = new Date(turkeyDateString);

    // Emin olmak için saati sıfırla
    today.setHours(0, 0, 0, 0);

    logger.info(`📅 Türkiye Tarihi Baz Alındı: ${today.toDateString()} (Sunucu saati: ${now.toISOString()})`);

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
        const docId = doc.id;

        if (!sub.nextBillingDate || !sub.userId) continue;

        // --- TARİH DÖNÜŞTÜRME (Timestamp veya String) ---
        let nextBillDate;
        try {
            if (typeof sub.nextBillingDate.toDate === 'function') {
                nextBillDate = sub.nextBillingDate.toDate();
            } else {
                nextBillDate = new Date(sub.nextBillingDate);
            }
        } catch (e) {
            logger.warn(`⚠️ Tarih hatası: ${docId}`);
            continue;
        }

        // Fatura Tarihini al ve saatini sıfırla
        nextBillDate.setHours(0, 0, 0, 0);

        // Kaç gün önce?
        const daysBefore = sub.reminderDaysBefore || 1;

        // Hatırlatma Tarihi = Fatura - Gün Sayısı
        const reminderDate = new Date(nextBillDate);
        reminderDate.setDate(reminderDate.getDate() - daysBefore);

        // --- DETAYLI LOG (Hata ayıklamak için) ---
        // Sadece beklediğimiz tarihse log basalım ki ortalık karışmasın
        if (Math.abs(reminderDate.getTime() - today.getTime()) < 86400000) { // 1 gün fark varsa logla
             logger.info(`🔍 İnceleme: ${sub.name} -> Hedef: ${reminderDate.toDateString()} | Bugün: ${today.toDateString()}`);
        }

        // KONTROL: Eşit mi?
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

    if (!token) return;

    const message = {
      token: token,
      notification: {
        title: "Ödemeniz Yaklaşıyor! 🔔",
        body: `${sub.name} ödemeniz ${sub.reminderDaysBefore} gün içinde yapılacak. Tutar: ${sub.amount} ${sub.currency || ''}`,
      },
      data: {
        route: "/subscriptions",
        subscriptionId: sub.id,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
    };

    await messaging.send(message);
    logger.info(`🚀 Gönderildi -> ${sub.name}`);

  } catch (error) {
    logger.error(`❌ Bildirim hatası (User: ${userId}):`, error.message);
  }
}