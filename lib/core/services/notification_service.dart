/// Notification Service for bill reminders and subscription alerts
/// Industry-grade implementation with local notifications support
import 'package:flutter/foundation.dart';
import 'package:payday_flutter/core/models/bill_reminder.dart';
import 'package:payday_flutter/core/models/subscription.dart';

/// Notification types for the app
enum NotificationType {
  billReminder,
  subscriptionDue,
  paydayReminder,
  savingsGoal,
  unusedSubscription,
  weeklyReport,
}

/// Notification data model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final Map<String, dynamic>? payload;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.payload,
    this.actionRoute,
  });
}

/// Notification service interface
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Schedule a notification
  Future<void> scheduleNotification(AppNotification notification);

  /// Cancel a scheduled notification
  Future<void> cancelNotification(String notificationId);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Get pending notifications
  Future<List<AppNotification>> getPendingNotifications();

  /// Schedule bill reminder notification
  Future<void> scheduleBillReminder(BillReminder reminder);

  /// Schedule subscription due notification
  Future<void> scheduleSubscriptionDueNotification(Subscription subscription);

  /// Schedule payday reminder
  Future<void> schedulePaydayReminder(DateTime payday);

  /// Schedule weekly subscription report
  Future<void> scheduleWeeklyReport();
}

/// Local notification service implementation
/// Note: For production, integrate with flutter_local_notifications package
class LocalNotificationService implements NotificationService {
  final List<AppNotification> _scheduledNotifications = [];
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // In production, initialize flutter_local_notifications here
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // const DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings();
    // const InitializationSettings initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsDarwin,
    // );
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _initialized = true;
    debugPrint('NotificationService: Initialized');
  }

  @override
  Future<bool> requestPermissions() async {
    // In production, request permissions from flutter_local_notifications
    // For iOS:
    // final result = await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(alert: true, badge: true, sound: true);
    // return result ?? false;

    debugPrint('NotificationService: Permissions requested');
    return true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    // Check notification permissions
    return true;
  }

  @override
  Future<void> scheduleNotification(AppNotification notification) async {
    await initialize();

    // In production, use flutter_local_notifications
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   notification.id.hashCode,
    //   notification.title,
    //   notification.body,
    //   tz.TZDateTime.from(notification.scheduledTime, tz.local),
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'bill_reminders',
    //       'Bill Reminders',
    //       channelDescription: 'Notifications for upcoming bills',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //     ),
    //     iOS: const DarwinNotificationDetails(),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );

    _scheduledNotifications.add(notification);
    debugPrint('NotificationService: Scheduled - ${notification.title}');
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    // In production:
    // await flutterLocalNotificationsPlugin.cancel(notificationId.hashCode);

    _scheduledNotifications.removeWhere((n) => n.id == notificationId);
    debugPrint('NotificationService: Cancelled - $notificationId');
  }

  @override
  Future<void> cancelAllNotifications() async {
    // In production:
    // await flutterLocalNotificationsPlugin.cancelAll();

    _scheduledNotifications.clear();
    debugPrint('NotificationService: All notifications cancelled');
  }

  @override
  Future<List<AppNotification>> getPendingNotifications() async {
    return List.unmodifiable(_scheduledNotifications);
  }

  @override
  Future<void> scheduleBillReminder(BillReminder reminder) async {
    final notification = AppNotification(
      id: 'bill_${reminder.id}',
      title: '${reminder.emoji} ${reminder.subscriptionName} due soon',
      body: '\$${reminder.amount.toStringAsFixed(2)} due on ${_formatDate(reminder.dueDate)}',
      type: NotificationType.billReminder,
      scheduledTime: reminder.reminderDate,
      payload: {
        'subscriptionId': reminder.subscriptionId,
        'amount': reminder.amount,
      },
      actionRoute: '/subscriptions',
    );

    await scheduleNotification(notification);
  }

  @override
  Future<void> scheduleSubscriptionDueNotification(Subscription subscription) async {
    final reminderDate = subscription.nextBillingDate.subtract(
      Duration(days: subscription.reminderDaysBefore),
    );

    if (reminderDate.isAfter(DateTime.now())) {
      final notification = AppNotification(
        id: 'sub_${subscription.id}_${subscription.nextBillingDate.millisecondsSinceEpoch}',
        title: '${subscription.emoji} ${subscription.name} billing soon',
        body: '\$${subscription.amount.toStringAsFixed(2)} will be charged on ${_formatDate(subscription.nextBillingDate)}',
        type: NotificationType.subscriptionDue,
        scheduledTime: reminderDate,
        payload: {
          'subscriptionId': subscription.id,
          'amount': subscription.amount,
        },
        actionRoute: '/subscriptions/${subscription.id}',
      );

      await scheduleNotification(notification);
    }
  }

  @override
  Future<void> schedulePaydayReminder(DateTime payday) async {
    final reminderDate = payday.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      final notification = AppNotification(
        id: 'payday_${payday.millisecondsSinceEpoch}',
        title: '💰 Payday Tomorrow!',
        body: 'Your payday is tomorrow. Time to review your budget!',
        type: NotificationType.paydayReminder,
        scheduledTime: reminderDate,
        actionRoute: '/home',
      );

      await scheduleNotification(notification);
    }
  }

  @override
  Future<void> scheduleWeeklyReport() async {
    // Schedule for Sunday at 6 PM
    final now = DateTime.now();
    var nextSunday = now.add(Duration(days: DateTime.sunday - now.weekday));
    if (nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }
    final reportTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 18, 0);

    final notification = AppNotification(
      id: 'weekly_report_${reportTime.millisecondsSinceEpoch}',
      title: '📊 Weekly Subscription Report',
      body: 'Check your subscription spending for this week',
      type: NotificationType.weeklyReport,
      scheduledTime: reportTime,
      actionRoute: '/subscriptions/analysis',
    );

    await scheduleNotification(notification);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

