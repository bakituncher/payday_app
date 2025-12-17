/// Subscription feature providers
/// Industry-grade state management with Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/core/models/bill_reminder.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/date_cycle_service.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';

/// All subscriptions for current user
final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getSubscriptions(userId);
});

/// Active subscriptions only - Auto-updates billing dates if passed
final activeSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  final subscriptions = await repository.getActiveSubscriptions(userId);

  // Check and update any subscriptions with passed billing dates
  final updatedSubscriptions = <Subscription>[];
  for (final sub in subscriptions) {
    final calculatedNextBilling = DateCycleService.calculateNextBillingDate(
      sub.nextBillingDate,
      sub.frequency,
    );

    if (calculatedNextBilling != sub.nextBillingDate) {
      // Billing date passed, update it
      final updatedSub = sub.copyWith(nextBillingDate: calculatedNextBilling);
      await repository.updateSubscription(updatedSub);
      updatedSubscriptions.add(updatedSub);
    } else {
      updatedSubscriptions.add(sub);
    }
  }

  return updatedSubscriptions;
});

/// Subscriptions due within 7 days
final subscriptionsDueSoonProvider = FutureProvider<List<Subscription>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getSubscriptionsDueSoon(userId, 7);
});

/// Total monthly subscription cost
final totalMonthlyCostProvider = FutureProvider<double>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getTotalMonthlyCost(userId);
});

/// Total yearly subscription cost
final totalYearlyCostProvider = FutureProvider<double>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getTotalYearlyCost(userId);
});

/// Spending breakdown by category
final spendingByCategoryProvider = FutureProvider<Map<SubscriptionCategory, double>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getSpendingByCategory(userId);
});

/// Upcoming bill reminders (next 7 days)
final upcomingRemindersProvider = FutureProvider<List<BillReminder>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getUpcomingReminders(userId, 7);
});

/// All reminders for current user
final allRemindersProvider = FutureProvider<List<BillReminder>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getReminders(userId);
});

/// Subscription analysis summary
final subscriptionAnalysisProvider = FutureProvider<SubscriptionSummary>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.analyzeSubscriptions(userId);
});

/// Selected category filter
final selectedCategoryFilterProvider = StateProvider<SubscriptionCategory?>((ref) => null);

/// Filtered subscriptions based on selected category
final filteredSubscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryFilterProvider);
  final allSubscriptions = await ref.watch(activeSubscriptionsProvider.future);

  if (selectedCategory == null) {
    return allSubscriptions;
  }

  return allSubscriptions.where((s) => s.category == selectedCategory).toList();
});

/// Selected subscription for detail view
final selectedSubscriptionIdProvider = StateProvider<String?>((ref) => null);

/// Selected subscription details
final selectedSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final subscriptionId = ref.watch(selectedSubscriptionIdProvider);
  if (subscriptionId == null) return null;

  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getSubscription(subscriptionId);
});

/// Subscription state notifier for mutations
class SubscriptionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SubscriptionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> addSubscription(Subscription subscription) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.addSubscription(subscription);

      // Schedule notification for the subscription
      try {
        final notificationService = _ref.read(notificationServiceProvider);
        await notificationService.scheduleSubscriptionDueNotification(subscription);
      } catch (notificationError) {
        // Log notification error but don't fail the whole operation
        print('Warning: Failed to schedule notification: $notificationError');
      }

      // Invalidate cached data
      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);
      _ref.invalidate(totalMonthlyCostProvider);
      _ref.invalidate(totalYearlyCostProvider);
      _ref.invalidate(subscriptionsDueSoonProvider);
      _ref.invalidate(currentMonthlySummaryProvider); // Update monthly summary

      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('Error adding subscription: $e');
      print('Stack trace: $st');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.updateSubscription(subscription);

      // Invalidate cached data
      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);
      _ref.invalidate(totalMonthlyCostProvider);
      _ref.invalidate(totalYearlyCostProvider);
      _ref.invalidate(selectedSubscriptionProvider);
      _ref.invalidate(currentMonthlySummaryProvider); // Update monthly summary

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.deleteSubscription(subscriptionId, userId);

      // Cancel notification
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelNotification('sub_$subscriptionId');

      // Invalidate cached data
      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);
      _ref.invalidate(totalMonthlyCostProvider);
      _ref.invalidate(totalYearlyCostProvider);
      _ref.invalidate(subscriptionsDueSoonProvider);
      _ref.invalidate(currentMonthlySummaryProvider); // Update monthly summary

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.cancelSubscription(subscriptionId, userId);

      // Cancel notification
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelNotification('sub_$subscriptionId');

      // Invalidate cached data
      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);
      _ref.invalidate(totalMonthlyCostProvider);
      _ref.invalidate(subscriptionAnalysisProvider);
      _ref.invalidate(currentMonthlySummaryProvider); // Update monthly summary

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pauseSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.pauseSubscription(subscriptionId, userId);

      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resumeSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.resumeSubscription(subscriptionId, userId);

      _ref.invalidate(subscriptionsProvider);
      _ref.invalidate(activeSubscriptionsProvider);
      _ref.invalidate(filteredSubscriptionsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.dismissReminder(reminderId);

      _ref.invalidate(upcomingRemindersProvider);
      _ref.invalidate(allRemindersProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.snoozeReminder(reminderId, duration);

      _ref.invalidate(upcomingRemindersProvider);
      _ref.invalidate(allRemindersProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateReminders() async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(currentUserIdProvider);
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.generateUpcomingReminders(userId);

      _ref.invalidate(upcomingRemindersProvider);
      _ref.invalidate(allRemindersProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Subscription notifier provider
final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<void>>((ref) {
  return SubscriptionNotifier(ref);
});
