/// Mock implementation of SubscriptionRepository for development/testing
/// Data is stored in-memory and will be cleared on app restart
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/core/models/bill_reminder.dart';
import 'package:payday/core/repositories/subscription_repository.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  // In-memory storage - starts empty, user adds their own data
  final List<Subscription> _subscriptions = [];
  final List<BillReminder> _reminders = [];

  @override
  Future<List<Subscription>> getSubscriptions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _subscriptions.where((s) => s.userId == userId).toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<List<Subscription>> getActiveSubscriptions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _subscriptions
        .where((s) => s.userId == userId && s.status == SubscriptionStatus.active)
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }

  @override
  Future<Subscription?> getSubscription(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _subscriptions.firstWhere((s) => s.id == subscriptionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subscriptions.add(subscription.copyWith(
      createdAt: subscription.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _subscriptions[index] = subscription.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteSubscription(String subscriptionId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subscriptions.removeWhere((s) => s.id == subscriptionId);
    _reminders.removeWhere((r) => r.subscriptionId == subscriptionId);
  }

  @override
  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _subscriptions[index] = _subscriptions[index].copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _subscriptions[index] = _subscriptions[index].copyWith(
        status: SubscriptionStatus.paused,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _subscriptions[index] = _subscriptions[index].copyWith(
        status: SubscriptionStatus.active,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<Subscription>> getSubscriptionsDueSoon(String userId, int days) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return _subscriptions
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
    await Future.delayed(const Duration(milliseconds: 200));
    return _subscriptions
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
    yield _subscriptions.where((s) => s.userId == userId).toList();
  }

  // Bill Reminders
  @override
  Future<List<BillReminder>> getUpcomingReminders(String userId, int days) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return _reminders
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
    await Future.delayed(const Duration(milliseconds: 200));
    return _reminders.where((r) => r.userId == userId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<void> createReminder(BillReminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _reminders.add(reminder);
  }

  @override
  Future<void> updateReminderStatus(String reminderId, ReminderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(status: status);
    }
  }

  @override
  Future<void> dismissReminder(String reminderId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        status: ReminderStatus.dismissed,
        dismissedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> snoozeReminder(String reminderId, Duration snoozeDuration) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        status: ReminderStatus.snoozed,
        snoozeUntil: DateTime.now().add(snoozeDuration),
      );
    }
  }

  @override
  Future<void> generateUpcomingReminders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final subscriptions = await getActiveSubscriptions(userId);
    final now = DateTime.now();

    for (final sub in subscriptions) {
      if (!sub.reminderEnabled) continue;

      final reminderDate = sub.nextBillingDate.subtract(
        Duration(days: sub.reminderDaysBefore),
      );

      if (reminderDate.isAfter(now)) {
        final existingReminder = _reminders.any(
          (r) => r.subscriptionId == sub.id &&
                 r.dueDate.year == sub.nextBillingDate.year &&
                 r.dueDate.month == sub.nextBillingDate.month &&
                 r.dueDate.day == sub.nextBillingDate.day,
        );

        if (!existingReminder) {
          _reminders.add(BillReminder(
            id: '${sub.id}_${sub.nextBillingDate.millisecondsSinceEpoch}',
            userId: userId,
            subscriptionId: sub.id,
            subscriptionName: sub.name,
            amount: sub.amount,
            dueDate: sub.nextBillingDate,
            reminderDate: reminderDate,
            emoji: sub.emoji,
            priority: sub.amount > 50 ? ReminderPriority.high : ReminderPriority.medium,
            createdAt: DateTime.now(),
          ));
        }
      }
    }
  }

  // Subscription Analysis
  @override
  Future<SubscriptionSummary> analyzeSubscriptions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final subscriptions = await getActiveSubscriptions(userId);

    if (subscriptions.isEmpty) {
      return SubscriptionSummary(
        userId: userId,
        totalSubscriptions: 0,
        totalMonthlySpend: 0,
        totalYearlySpend: 0,
        potentialMonthlySavings: 0,
        potentialYearlySavings: 0,
        subscriptionsToReview: 0,
        subscriptionsToCancel: 0,
        spendByCategory: {},
        analyses: [],
        lastAnalyzedAt: DateTime.now(),
      );
    }

    final analyses = <SubscriptionAnalysis>[];
    double potentialMonthlySavings = 0;
    int toReview = 0;
    int toCancel = 0;

    final Map<String, double> spendByCategory = {};

    for (final sub in subscriptions) {
      final categoryName = sub.category.name;
      spendByCategory[categoryName] = (spendByCategory[categoryName] ?? 0) + sub.monthlyCost;

      UsageLevel usageLevel;
      RecommendationType recommendation;
      double savings = 0;
      List<String> reasons = [];
      List<String> alternatives = [];

      // Smart analysis based on subscription characteristics
      if (sub.category == SubscriptionCategory.streaming && sub.monthlyCost > 15) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.review;
        reasons.add('Higher than average streaming cost');
        alternatives.add('Consider ad-supported tier');
        savings = sub.monthlyCost * 0.3;
        toReview++;
      } else if (sub.category == SubscriptionCategory.productivity && sub.monthlyCost > 50) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.downgrade;
        reasons.add('Premium productivity software');
        reasons.add('Check if all features are being used');
        alternatives.add('Consider individual app plans');
        alternatives.add('Look for student/educator discounts');
        savings = sub.monthlyCost * 0.4;
        toReview++;
      } else if (sub.monthlyCost > 30) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.review;
        reasons.add('Higher cost subscription');
        savings = sub.monthlyCost * 0.2;
        toReview++;
      } else {
        usageLevel = UsageLevel.high;
        recommendation = RecommendationType.keep;
        reasons.add('Good value subscription');
      }

      potentialMonthlySavings += savings;

      analyses.add(SubscriptionAnalysis(
        id: 'analysis_${sub.id}',
        userId: userId,
        subscriptionId: sub.id,
        subscriptionName: sub.name,
        monthlyAmount: sub.monthlyCost,
        usageLevel: usageLevel,
        recommendation: recommendation,
        potentialSavings: savings,
        reasons: reasons,
        alternatives: alternatives,
        usageScore: usageLevel == UsageLevel.high ? 85 : 60,
        analyzedAt: DateTime.now(),
      ));
    }

    return SubscriptionSummary(
      userId: userId,
      totalSubscriptions: subscriptions.length,
      totalMonthlySpend: subscriptions.fold<double>(0, (sum, s) => sum + s.monthlyCost),
      totalYearlySpend: subscriptions.fold<double>(0, (sum, s) => sum + s.yearlyCost),
      potentialMonthlySavings: potentialMonthlySavings,
      potentialYearlySavings: potentialMonthlySavings * 12,
      subscriptionsToReview: toReview,
      subscriptionsToCancel: toCancel,
      spendByCategory: spendByCategory,
      analyses: analyses,
      lastAnalyzedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Subscription>> getUnusedSubscriptions(String userId, int thresholdDays) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real implementation, this would track actual usage
    // For now, return empty list as we don't have usage data
    return [];
  }

  @override
  Future<void> markSubscriptionUsed(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real implementation, this would update lastUsedAt timestamp
  }
}

