const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkSubscriptionDueDates = onSchedule(
  {
    schedule: "every 1 hours", // ✅ Her saat başı çalış
    region: "us-central1",     // Zaman dilimi ayarını kaldırdık, UTC baz alacağız
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // 1. Şu anki UTC saatini al
    const now = new Date();
    const currentUtcHour = now.getUTCHours();

    // 2. Hedefimiz: Kullanıcının yerel saatinin 09:00 olması.
    // Formül: (UTC Saati + Kullanıcı Offseti) = 09:00
    // Buradan kullanıcı offsetini bulalım: Offset = 9 - UTC Saati
    let targetOffset = 9 - currentUtcHour;

    // Dünyanın dönüşünü hesaba kat (Örn: UTC 20:00 iken, sabah 9 olması için +13 saat ilerideki Yeni Zelanda gerekir)
    // Offsetler genelde -12 ile +14 arasındadır.
    if (targetOffset < -12) {
        targetOffset += 24;
    } else if (targetOffset > 14) {
        targetOffset -= 24;
    }

    console.log(`🕒 UTC Saat: ${currentUtcHour}:00. Hedef Yerel Saat: 09:00.`);
    console.log(`🌍 Bu saatte bildirim alacak kullanıcıların UTC Offseti: ${targetOffset}`);

    try {
      // 3. Sadece bu saat dilimindeki (Offset'teki) kullanıcıları bul
      // Bu sayede tüm veritabanını taramaktan kurtuluruz, maliyet düşer.
      const usersSnapshot = await db.collection("users")
        .where("utcOffset", "==", targetOffset)
        .get();

      if (usersSnapshot.empty) {
        console.log(`✅ Offset'i ${targetOffset} olan kullanıcı bulunamadı.`);
        return;
      }

      console.log(`bust: ${usersSnapshot.size} kullanıcı bu saat diliminde.`);

      // Bildirim listesi
      const notifications = [];

      // 4. Bulunan her kullanıcı için abonelikleri kontrol et
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const userId = userDoc.id;

        if (!userData.fcmToken) continue;

        // Bu kullanıcının aboneliklerini çek
        // (Yarına ait ödemesi olanları)

        // Kullanıcının yerel saatine göre "Yarın"ı hesapla
        // Basitlik adına sunucu tarihini baz alıp 1 gün ekliyoruz,
        // çünkü zaten kullanıcının sabah 9'una denk geldik.
        const userTomorrow = new Date();
        userTomorrow.setDate(userTomorrow.getDate() + 1);
        userTomorrow.setHours(0,0,0,0); // Gün başı

        const userTomorrowEnd = new Date(userTomorrow);
        userTomorrowEnd.setHours(23,59,59,999); // Gün sonu

        const subscriptionsSnapshot = await db.collection(`users/${userId}/subscriptions`)
            .where("nextPaymentDate", ">=", admin.firestore.Timestamp.fromDate(userTomorrow))
            .where("nextPaymentDate", "<=", admin.firestore.Timestamp.fromDate(userTomorrowEnd))
            .get();

        if (subscriptionsSnapshot.empty) continue;

        // Bildirim gönder
        for (const subDoc of subscriptionsSnapshot.docs) {
            const subData = subDoc.data();

            const message = {
                token: userData.fcmToken,
                notification: {
                    title: "Ödeme Hatırlatması 💸",
                    body: `${subData.name} ödemesi yarın!`,
                },
                data: {
                    route: "/subscriptions",
                    click_action: "FLUTTER_NOTIFICATION_CLICK"
                }
            };
            notifications.push(messaging.send(message));
        }
      }

      if (notifications.length > 0) {
        await Promise.allSettled(notifications);
        console.log(`🚀 Toplam ${notifications.length} bildirim gönderildi.`);
      } else {
        console.log("🔕 Bu saat dilimindeki kullanıcıların yarın için ödemesi yok.");
      }

    } catch (error) {
      console.error("❌ Hata oluştu:", error);
    }
  }
);