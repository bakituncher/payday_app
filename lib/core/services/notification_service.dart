import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:payday/core/models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Saat Dilimi Ayarları (Çok Önemli)
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Android Ayarları
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Ayarları
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // --- GÜNLÜK 3 BİLDİRİM (İngilizce Metinler) ---
  Future<void> scheduleDailyEngagementReminders() async {
    // ID: 100 -> Sabah 09:00
    await _scheduleDaily(
      100,
      'Good Morning! \u2600\ufe0f',
      'Have you planned your budget for today?',
      9, 0,
    );

    // ID: 101 -> Öğlen 14:00
    await _scheduleDaily(
      101,
      'Track Your Spending \ud83d\udcb8',
      "Don't forget to log your lunch or coffee expenses.",
      14, 0,
    );

    // ID: 102 -> Akşam 20:00
    await _scheduleDaily(
      102,
      'Wrap Up Your Day \ud83c\udf19',
      'Take a moment to review your daily transactions.',
      20, 0,
    );
  }

  // Yardımcı Fonksiyon (Google Play Dostu - Inexact Mode)
  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily engagement notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Google Play dostu inexact mod
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
    );
  }

  // --- ABONELİK HATIRLATMASI ---
  Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!subscription.reminderEnabled) return;

    // Hatırlatma Tarihi: Fatura tarihinden X gün önce, sabah 10:00'da
    final billingDate = subscription.nextBillingDate;
    var scheduledDate = billingDate.subtract(Duration(days: subscription.reminderDaysBefore));

    // Saat 10:00 olarak ayarla
    final notificationTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      10, 0,
    );

    if (notificationTime.isBefore(DateTime.now())) return;

    // ID üret (String ID'yi Integer'a çeviriyoruz)
    final notificationId = subscription.id.hashCode;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Upcoming Bill: ${subscription.name}',
      'Your payment of ${subscription.amount} ${subscription.currency} is coming up.',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Abonelik silinirse bildirimi de sil
  Future<void> cancelSubscriptionNotification(String subscriptionId) async {
    await flutterLocalNotificationsPlugin.cancel(subscriptionId.hashCode);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
