const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkSubscriptionDueDates = onSchedule(
  {
    schedule: "every 1 hours", // Test için "every 5 minutes" da yapabilirsiniz
    region: "us-central1",
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    console.log("🚀 FORCE DEBUG MODU: Tarih kontrolü olmadan bildirim gönderiliyor...");

    try {
      // 1. Tüm kullanıcıları çek
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
          console.log(`⚠️ Token yok, atlanıyor: ${userId}`);
          continue;
        }

        // --- TARİH HESAPLAMALARINI DEVRE DIŞI BIRAKTIK ---
        // Amaç: Sistem çalışıyor mu test etmek.

        // 3. Abonelikleri sorgula (Tarih filtresi YOK, sadece 1 tane örnek al)
        const subscriptionsSnapshot = await db.collection(`users/${userId}/subscriptions`)
            .limit(1) // Sadece 1 tane getir, spam olmasın
            .get();

        let notificationTitle = "Test Bildirimi 🧪";
        let notificationBody = "Bu bir test bildirimidir. Sistem çalışıyor!";
        let route = "/home"; // Varsayılan rota

        // Eğer kullanıcının hiç aboneliği yoksa bile test mesajı gitsin
        if (!subscriptionsSnapshot.empty) {
          const subData = subscriptionsSnapshot.docs[0].data();
          notificationTitle = "Ödeme Hatırlatması 💸";
          notificationBody = `${subData.name} için ödeme zamanı (Test)`;
          route = "/subscriptions";
        } else {
             console.log(`ℹ️ Kullanıcının aboneliği yok, genel test mesajı gönderilecek: ${userId}`);
        }

        console.log(`🔔 GÖNDERİLİYOR: ${userId} -> ${notificationBody}`);

        const message = {
          token: userData.fcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            route: route,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            // Test olduğunu belli eden bir parametre
            isTest: "true"
          },
        };

        // Hata yakalamayı bireysel yapalım ki biri patlarsa döngü durmasın
        const sendPromise = messaging.send(message)
            .then(() => {
                console.log(`✅ Başarılı: ${userId}`);
                return { status: "fulfilled" };
            })
            .catch((e) => {
                console.error(`❌ Hata (${userId}):`, e.message);
                // Token geçersizse silmeyi deneyebilirsin (isteğe bağlı)
                return { status: "rejected", error: e };
            });

        notifications.push(sendPromise);
        processedCount++;
      }

      // 4. Sonuçları bekle
      if (notifications.length > 0) {
        await Promise.all(notifications);
        console.log(`🏁 İşlem tamamlandı. Toplam deneme: ${processedCount}`);
      } else {
        console.log("🔕 Hiçbir kullanıcıda geçerli token bulunamadı.");
      }

    } catch (error) {
      console.error("🔥 Genel Kritik Hata:", error);
    }
  }
);