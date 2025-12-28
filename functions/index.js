const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

admin.initializeApp();

// 🌍 GÜNLÜK AKILLI BİLDİRİM SERVİSİ
// Bu fonksiyon her saat başı çalışır ve üç farklı zaman dilimini kontrol eder:
// 1. Gece 00:00 -> Maaş Günü Bildirimi
// 2. Sabah 10:00 -> Fatura, Harcama ve Özet (Faydalı İçerik)
// 3. Akşam 20:00 -> Premium Propagandası (Pazarlama - HER GÜN)
exports.dailySmartNotifications = onSchedule(
  {
    schedule: "0 * * * *", // Her saatin 0. dakikası
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async (event) => {
    const db = admin.firestore();
    const messaging = admin.messaging();
    const now = new Date();
    const currentUtcHour = now.getUTCHours();

    logger.info(`⏰ Global Saat Kontrolü Başladı: UTC ${currentUtcHour}:00`);

    // Üç işlemi paralel yürüt (Hız optimizasyonu)
    await Promise.all([
      checkMidnightPayday(db, messaging, now, currentUtcHour),
      checkMorningBrief(db, messaging, now, currentUtcHour),
      checkEveningMarketing(db, messaging, now, currentUtcHour),
    ]);

    logger.info("✅ Tüm kontroller tamamlandı.");
  }
);

// ---------------------------------------------------------------------------
// 🌙 1. MODÜL: GECE YARISI MAAŞ KONTROLÜ (Hedef Saat: 00:00)
// ---------------------------------------------------------------------------
async function checkMidnightPayday(db, messaging, now, currentUtcHour) {
  const targetOffset = calculateTargetOffset(0, currentUtcHour); // Hedef 00:00

  try {
    const usersSnapshot = await db.collection("users")
      .where("utcOffset", "==", targetOffset)
      .get();

    if (usersSnapshot.empty) return;

    logger.info(`🌙 Gece Kontrolü (00:00) -> Offset: ${targetOffset} | Kullanıcı: ${usersSnapshot.size}`);
    const userTodayNormalized = normalizeToUtcNoon(now, targetOffset);
    const promises = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken || !userData.nextPayday) continue;

      try {
        let paydayDate;
        if (userData.nextPayday.toDate) {
            paydayDate = userData.nextPayday.toDate();
        } else {
            paydayDate = new Date(userData.nextPayday);
        }

        const paydayAdjusted = new Date(paydayDate.getTime() + (12 * 3600000));
        const paydayNormalized = normalizeToUtcNoon(paydayAdjusted, targetOffset);

        if (paydayNormalized.getTime() === userTodayNormalized.getTime()) {
            promises.push(sendNotification(messaging, fcmToken, {
                title: "Payday! 💸",
                body: "It's 00:00! Your new pay period has started. Great time to plan your budget!",
                route: "/home",
                type: "payday"
            }));
        }
      } catch (e) {
        logger.error(`Maaş hatası (${userDoc.id}):`, e);
      }
    }

    if (promises.length > 0) await Promise.all(promises);

  } catch (error) {
    logger.error("🔥 Gece Modülü Hatası:", error);
  }
}

// ---------------------------------------------------------------------------
// ☀️ 2. MODÜL: SABAH GÜNLÜK ÖZET (Hedef Saat: 10:00)
// Sadece Fatura, Harcama ve Özet (Pazarlama YOK)
// ---------------------------------------------------------------------------
async function checkMorningBrief(db, messaging, now, currentUtcHour) {
  const targetOffset = calculateTargetOffset(10, currentUtcHour); // Hedef 10:00

  // Rotasyon: Modulo 2 (0: Harcama, 1: Özet)
  const startOfYear = new Date(now.getFullYear(), 0, 0);
  const diff = now - startOfYear;
  const oneDay = 1000 * 60 * 60 * 24;
  const dayOfYear = Math.floor(diff / oneDay);

  try {
    const usersSnapshot = await db.collection("users")
      .where("utcOffset", "==", targetOffset)
      .get();

    if (usersSnapshot.empty) return;

    logger.info(`☀️ Sabah Kontrolü (10:00) -> Offset: ${targetOffset} | Kullanıcı: ${usersSnapshot.size}`);
    const userTodayNormalized = normalizeToUtcNoon(now, targetOffset);
    const promises = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      const userId = userDoc.id;

      if (!fcmToken) continue;

      let notificationSent = false;

      // A. FATURA KONTROLÜ (Öncelikli)
      const subsSnapshot = await db.collection(`users/${userId}/subscriptions`)
          .where("reminderEnabled", "==", true)
          .where("status", "==", "active")
          .get();

      if (!subsSnapshot.empty) {
          for (const subDoc of subsSnapshot.docs) {
              if (notificationSent) break;
              const sub = subDoc.data();
              if (!sub.nextBillingDate) continue;

              let rawBillingDate;
              try {
                  rawBillingDate = sub.nextBillingDate.toDate ? sub.nextBillingDate.toDate() : new Date(sub.nextBillingDate);
              } catch (e) { continue; }

              const billDateAdjusted = new Date(rawBillingDate.getTime() + (12 * 3600000));
              const billDateNormalized = normalizeToUtcNoon(billDateAdjusted, targetOffset);
              const diffTime = billDateNormalized.getTime() - userTodayNormalized.getTime();
              const daysDiff = Math.round(diffTime / (1000 * 60 * 60 * 24));

              let reminderDays = 1;
              if (sub.reminderDaysBefore !== undefined && sub.reminderDaysBefore !== null) {
                   const parsed = parseInt(sub.reminderDaysBefore, 10);
                   if (!isNaN(parsed)) reminderDays = parsed;
              }

              if (daysDiff === reminderDays) {
                  promises.push(sendNotification(messaging, fcmToken, {
                      title: "Payment Upcoming! 🔔",
                      body: `${sub.name} payment is due in ${daysDiff} days.`,
                      route: "/subscriptions",
                      itemId: sub.id || subDoc.id,
                      type: "bill"
                  }));
                  notificationSent = true;
              }
          }
      }

      if (notificationSent) continue;

      // B. ETKİLEŞİM ROTASYONU (Pazarlama BURADAN KALDIRILDI)
      // Modulo 2: Bir gün Harcama, diğer gün Özet
      const rotationIndex = dayOfYear % 2;

      if (rotationIndex === 0) {
          promises.push(sendNotification(messaging, fcmToken, {
              title: "Add Transaction ☕️",
              body: "Don't forget to enter your expenses for today!",
              route: "/add-transaction",
              type: "engagement"
          }));
      } else {
           promises.push(sendNotification(messaging, fcmToken, {
              title: "How's Your Budget? 📊",
              body: "Check your monthly summary to track your spending.",
              route: "/monthly-summary",
              type: "engagement"
          }));
      }
    }

    if (promises.length > 0) await Promise.all(promises);

  } catch (error) {
    logger.error("🔥 Sabah Modülü Hatası:", error);
  }
}

// ---------------------------------------------------------------------------
// 🌆 3. MODÜL: AKŞAM PAZARLAMA (Hedef Saat: 20:00)
// Sadece Premium Olmayanlara, Reklamsız Sürüm Propagandası (HER GÜN)
// ---------------------------------------------------------------------------
async function checkEveningMarketing(db, messaging, now, currentUtcHour) {
  const targetOffset = calculateTargetOffset(20, currentUtcHour); // Hedef 20:00

  // ❌ KALDIRILDI: 3 Günde 1 kuralı iptal edildi. Artık her gün çalışıyor.

  try {
    // ⚠️ DÜZELTME: .where("isPremium", "==", false) kaldırıldı.
    // Böylece 'isPremium' alanı hiç olmayan kullanıcılara da bildirim gidecek.
    const usersSnapshot = await db.collection("users")
      .where("utcOffset", "==", targetOffset)
      .get();

    if (usersSnapshot.empty) return;

    logger.info(`🌆 Akşam Kontrolü (20:00) -> Offset: ${targetOffset} | Taranan: ${usersSnapshot.size} kişi`);

    const promises = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      // 🛡️ GÜVENLİ FİLTRELEME
      // Eğer kullanıcı Premium ise (true) -> ATL (Gönderme)
      // Eğer isPremium null, false veya hiç yoksa -> GÖNDER
      if (!fcmToken || userData.isPremium === true) continue;

      promises.push(sendNotification(messaging, fcmToken, {
          title: "Tired of Ads? 🌟",
          body: "Go Premium for an ad-free, unlimited, and powerful experience!",
          route: "/premium",
          type: "marketing"
      }));
    }

    if (promises.length > 0) await Promise.all(promises);

  } catch (error) {
    logger.error("🔥 Akşam Modülü Hatası:", error);
  }
}

// ---------------------------------------------------------------------------
// 🛠 YARDIMCI FONKSİYONLAR
// ---------------------------------------------------------------------------

function calculateTargetOffset(targetHour, currentUtcHour) {
    let offset = targetHour - currentUtcHour;
    if (offset <= -12) offset += 24;
    if (offset > 14) offset -= 24;
    return offset;
}

const normalizeToUtcNoon = (dateObj, offsetHours = 0) => {
    const localMs = dateObj.getTime() + (offsetHours * 3600000);
    const localDate = new Date(localMs);
    const year = localDate.getUTCFullYear();
    const month = localDate.getUTCMonth();
    const day = localDate.getUTCDate();
    return new Date(Date.UTC(year, month, day, 12, 0, 0));
};

async function sendNotification(messaging, token, data) {
    try {
        const message = {
          token: token,
          notification: {
            title: data.title,
            body: data.body,
          },
          data: {
            route: data.route || "/home",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            type: data.type || "general",
            itemId: data.itemId ? data.itemId.toString() : ""
          },
        };
        await messaging.send(message);
    } catch (e) {
        logger.error(`❌ Gönderim Hatası (${data.type}):`, e.message);
    }
}