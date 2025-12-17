/// Local implementation of SubscriptionRepository using SharedPreferences
/// Data persists across app restarts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/core/models/bill_reminder.dart';
import 'package:payday/core/repositories/subscription_repository.dart';

class LocalSubscriptionRepository implements SubscriptionRepository {
  static const String _subscriptionsKey = 'local_subscriptions';
  static const String _remindersKey = 'local_reminders';

  List<Subscription>? _cachedSubscriptions;
  List<BillReminder>? _cachedReminders;

  // Load subscriptions from SharedPreferences
  Future<List<Subscription>> _loadSubscriptions() async {
    if (_cachedSubscriptions != null) return _cachedSubscriptions!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_subscriptionsKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedSubscriptions = [];
      return _cachedSubscriptions!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedSubscriptions = jsonList
          .map((json) => Subscription.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedSubscriptions = [];
    }

    return _cachedSubscriptions!;
  }

  Future<void> _saveSubscriptions() async {
    if (_cachedSubscriptions == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedSubscriptions!.map((s) => s.toJson()).toList();
    await prefs.setString(_subscriptionsKey, json.encode(jsonList));
  }

  // Load reminders from SharedPreferences
  Future<List<BillReminder>> _loadReminders() async {
    if (_cachedReminders != null) return _cachedReminders!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_remindersKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedReminders = [];
      return _cachedReminders!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedReminders = jsonList
          .map((json) => BillReminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedReminders = [];
    }

    return _cachedReminders!;
  }

  Future<void> _saveReminders() async {
    if (_cachedReminders == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedReminders!.map((r) => r.toJson()).toList();
    await prefs.setString(_remindersKey, json.encode(jsonList));
  }

  @override
  Future<List<Subscription>> getSubscriptions(String userId) async {
    final subscriptions = await _loadSubscriptions();
    return subscriptions.where((s) => s.userId == userId).toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<List<Subscription>> getActiveSubscriptions(String userId) async {
    final subscriptions = await _loadSubscriptions();
    return subscriptions
        .where((s) => s.userId == userId && s.status == SubscriptionStatus.active)
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<Subscription?> getSubscription(String subscriptionId) async {
    final subscriptions = await _loadSubscriptions();
    try {
      return subscriptions.firstWhere((s) => s.id == subscriptionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    await _loadSubscriptions();
    _cachedSubscriptions!.add(subscription.copyWith(
      createdAt: subscription.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    await _saveSubscriptions();
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _loadSubscriptions();
    final index = _cachedSubscriptions!.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _cachedSubscriptions![index] = subscription.copyWith(updatedAt: DateTime.now());
      await _saveSubscriptions();
    }
  }

  @override
  Future<void> deleteSubscription(String subscriptionId, String userId) async {
    await _loadSubscriptions();
    await _loadReminders();
    _cachedSubscriptions!.removeWhere((s) => s.id == subscriptionId);
    _cachedReminders!.removeWhere((r) => r.subscriptionId == subscriptionId);
    await _saveSubscriptions();
    await _saveReminders();
  }

  @override
  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    await _loadSubscriptions();
    final index = _cachedSubscriptions!.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _cachedSubscriptions![index] = _cachedSubscriptions![index].copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveSubscriptions();
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, String userId) async {
    await _loadSubscriptions();
    final index = _cachedSubscriptions!.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _cachedSubscriptions![index] = _cachedSubscriptions![index].copyWith(
        status: SubscriptionStatus.paused,
        updatedAt: DateTime.now(),
      );
      await _saveSubscriptions();
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId, String userId) async {
    await _loadSubscriptions();
    final index = _cachedSubscriptions!.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _cachedSubscriptions![index] = _cachedSubscriptions![index].copyWith(
        status: SubscriptionStatus.active,
        updatedAt: DateTime.now(),
      );
      await _saveSubscriptions();
    }
  }

  @override
  Future<List<Subscription>> getSubscriptionsDueSoon(String userId, int days) async {
    final subscriptions = await _loadSubscriptions();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return subscriptions
        .where((s) =>
            s.userId == userId &&
            s.status == SubscriptionStatus.active &&
            s.nextBillingDate.isAfter(now.subtract(const Duration(days: 1))) &&
            s.nextBillingDate.isBefore(futureDate))
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<double> getTotalMonthlyCost(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);
    return subscriptions.fold<double>(0.0, (sum, sub) => sum + sub.monthlyCost);
  }

  @override
  Future<double> getTotalYearlyCost(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);
    return subscriptions.fold<double>(0.0, (sum, sub) => sum + sub.yearlyCost);
  }

  @override
  Future<List<Subscription>> getSubscriptionsByCategory(
    String userId,
    SubscriptionCategory category,
  ) async {
    final subscriptions = await _loadSubscriptions();
    return subscriptions
        .where((s) => s.userId == userId && s.category == category)
        .toList();
  }

  @override
  Future<Map<SubscriptionCategory, double>> getSpendingByCategory(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);
    final Map<SubscriptionCategory, double> spending = {};

    for (final sub in subscriptions) {
      spending[sub.category] = (spending[sub.category] ?? 0) + sub.monthlyCost;
    }

    return spending;
  }

  @override
  Stream<List<Subscription>> subscriptionsStream(String userId) async* {
    // For local storage, we return a single snapshot
    // In a real implementation, this would be a live stream
    yield await getSubscriptions(userId);
  }

  // Bill Reminders
  @override
  Future<List<BillReminder>> getUpcomingReminders(String userId, int days) async {
    final reminders = await _loadReminders();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return reminders
        .where((r) =>
            r.userId == userId &&
            r.status == ReminderStatus.pending &&
            r.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
            r.dueDate.isBefore(futureDate))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<List<BillReminder>> getReminders(String userId) async {
    final reminders = await _loadReminders();
    return reminders.where((r) => r.userId == userId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<void> createReminder(BillReminder reminder) async {
    await _loadReminders();
    _cachedReminders!.add(reminder);
    await _saveReminders();
  }

  @override
  Future<void> updateReminderStatus(String reminderId, ReminderStatus status) async {
    await _loadReminders();
    final index = _cachedReminders!.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _cachedReminders![index] = _cachedReminders![index].copyWith(status: status);
      await _saveReminders();
    }
  }

  @override
  Future<void> dismissReminder(String reminderId) async {
    await updateReminderStatus(reminderId, ReminderStatus.dismissed);
  }

  @override
  Future<void> snoozeReminder(String reminderId, Duration snoozeDuration) async {
    await _loadReminders();
    final index = _cachedReminders!.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _cachedReminders![index] = _cachedReminders![index].copyWith(
        status: ReminderStatus.snoozed,
        snoozeUntil: DateTime.now().add(snoozeDuration),
      );
      await _saveReminders();
    }
  }

  @override
  Future<void> generateUpcomingReminders(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);
    await _loadReminders();

    final now = DateTime.now();
    final reminderWindow = now.add(const Duration(days: 7));

    for (final sub in subscriptions) {
      if (!sub.reminderEnabled) continue;

      final reminderDate = sub.nextBillingDate.subtract(
        Duration(days: sub.reminderDaysBefore),
      );

      if (reminderDate.isBefore(reminderWindow) && reminderDate.isAfter(now)) {
        // Check if reminder already exists
        final existingReminder = _cachedReminders!.any(
          (r) => r.subscriptionId == sub.id &&
                 r.dueDate.year == sub.nextBillingDate.year &&
                 r.dueDate.month == sub.nextBillingDate.month &&
                 r.dueDate.day == sub.nextBillingDate.day,
        );

        if (!existingReminder) {
          _cachedReminders!.add(BillReminder(
            id: '${sub.id}_${sub.nextBillingDate.millisecondsSinceEpoch}',
            userId: userId,
            subscriptionId: sub.id,
            subscriptionName: sub.name,
            amount: sub.amount,
            currency: sub.currency,
            dueDate: sub.nextBillingDate,
            reminderDate: reminderDate,
            status: ReminderStatus.pending,
          ));
        }
      }
    }

    await _saveReminders();
  }

  // Subscription Analysis
  @override
  Future<SubscriptionSummary> analyzeSubscriptions(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);
    final spending = await getSpendingByCategory(userId);
    final totalMonthly = await getTotalMonthlyCost(userId);
    final totalYearly = await getTotalYearlyCost(userId);

    // Convert SubscriptionCategory map to String map for spendByCategory
    final Map<String, double> spendByCategory = {};
    for (final entry in spending.entries) {
      spendByCategory[entry.key.name] = entry.value;
    }

    return SubscriptionSummary(
      userId: userId,
      totalSubscriptions: subscriptions.length,
      totalMonthlySpend: totalMonthly,
      totalYearlySpend: totalYearly,
      potentialMonthlySavings: 0.0, // Would need more logic for this
      potentialYearlySavings: 0.0,
      subscriptionsToReview: 0,
      subscriptionsToCancel: 0,
      spendByCategory: spendByCategory,
      analyses: [],
      lastAnalyzedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Subscription>> getUnusedSubscriptions(String userId, int thresholdDays) async {
    // For now, return empty list - would need usage tracking
    return [];
  }

  @override
  Future<void> markSubscriptionUsed(String subscriptionId) async {
    // Would need to track last used date
    await _loadSubscriptions();
    final index = _cachedSubscriptions!.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _cachedSubscriptions![index] = _cachedSubscriptions![index].copyWith(
        updatedAt: DateTime.now(),
      );
      await _saveSubscriptions();
    }
  }

  /// Clear cache to force reload from storage
  void clearCache() {
    _cachedSubscriptions = null;
    _cachedReminders = null;
  }
}

