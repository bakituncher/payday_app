const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkSubscriptionDueDates = onSchedule(
  {
    schedule: "every 1 hours",
    region: "us-central1",
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    console.log("🚀 Bildirim kontrolü başladı (Force Run Modu)...");

    try {
      // 1. Tüm kullanıcıları çek (Timezone filtresi olmadan)
      const usersSnapshot = await db.collection("users").get();

      if (usersSnapshot.empty) {
        console.log("❌ Kayıtlı kullanıcı bulunamadı.");
        return;
      }

      const notifications = [];
      let processedCount = 0;

      // 2. Her kullanıcıyı kontrol et
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const userId = userDoc.id;

        if (!userData.fcmToken) {
          console.log(`⚠️ Kullanıcının fcmToken'ı yok, atlanıyor: ${userId}`);
          continue;
        }

        // Kullanıcının UTC Offset bilgisini al (Yoksa varsayılan 3 - Türkiye)
        const userOffset = userData.utcOffset !== undefined ? userData.utcOffset : 3;

        // 3. Kullanıcının YEREL saatine göre "Yarın"ı hesapla
        const now = new Date();
        const userLocalNow = new Date(now.getTime() + (userOffset * 60 * 60 * 1000));

        const userTomorrowStartLocal = new Date(userLocalNow);
        userTomorrowStartLocal.setDate(userTomorrowStartLocal.getDate() + 1);
        userTomorrowStartLocal.setHours(0, 0, 0, 0);

        const userTomorrowEndLocal = new Date(userLocalNow);
        userTomorrowEndLocal.setDate(userTomorrowEndLocal.getDate() + 1);
        userTomorrowEndLocal.setHours(23, 59, 59, 999);

        // 4. Firestore sorgusu için tarihleri UTC'ye geri çevir
        const queryStart = new Date(userTomorrowStartLocal.getTime() - (userOffset * 60 * 60 * 1000));
        const queryEnd = new Date(userTomorrowEndLocal.getTime() - (userOffset * 60 * 60 * 1000));

        // 5. Abonelikleri sorgula
        const subscriptionsSnapshot = await db.collection(`users/${userId}/subscriptions`)
            .where("nextPaymentDate", ">=", admin.firestore.Timestamp.fromDate(queryStart))
            .where("nextPaymentDate", "<=", admin.firestore.Timestamp.fromDate(queryEnd))
            .get();

        if (subscriptionsSnapshot.empty) continue;

        // 6. Bildirimleri hazırla
        for (const subDoc of subscriptionsSnapshot.docs) {
          const subData = subDoc.data();

          console.log(`🔔 Bildirim Hazırlanıyor: ${userId} -> ${subData.name}`);

          const message = {
            token: userData.fcmToken,
            notification: {
              title: "Ödeme Hatırlatması 💸",
              body: `${subData.name} ödemesi yarın!`,
            },
            data: {
              route: "/subscriptions",
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
          };
          notifications.push(messaging.send(message));
          processedCount++;
        }
      }

      // 7. Gönderim
      if (notifications.length > 0) {
        const results = await Promise.allSettled(notifications);
        const ok = results.filter((r) => r.status === "fulfilled").length;
        const failed = results.filter((r) => r.status === "rejected").length;
        if (failed > 0) {
          console.error(`❌ ${failed} bildirim gönderilemedi, detaylar:`, results.filter((r) => r.status === "rejected"));
        }
        console.log(`✅ Toplam ${processedCount} bildirim hazırlandı, gönderim sonucu: ${ok} başarılı / ${failed} başarısız.`);
      } else {
        console.log("🔕 Bu döngüde gönderilecek bildirim yok.");
      }

    } catch (error) {
      console.error("❌ Hata:", error);
    }
  }
);