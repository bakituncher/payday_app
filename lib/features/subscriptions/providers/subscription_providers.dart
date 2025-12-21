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
  final allSubscriptions = await ref.watch(subscriptionsProvider.future);
  final visible = allSubscriptions.where((s) => s.status != SubscriptionStatus.cancelled).toList();

  if (selectedCategory == null) {
    return visible;
  }

  return visible.where((s) => s.category == selectedCategory).toList();
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

      try {
        final notificationService = _ref.read(notificationServiceProvider);
        await notificationService.scheduleSubscriptionDueNotification(subscription);
      } catch (notificationError) {
        // Keep silent for notification scheduling issues
        print('Warning: Failed to schedule notification: $notificationError');
      }

      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('Error adding subscription: $e');
      print('Stack trace: $st');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> editSubscription(Subscription originalSub, Subscription updatedSub) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.updateSubscription(updatedSub.copyWith(updatedAt: DateTime.now()));
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.updateSubscription(subscription);
      _invalidateProviders();
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

      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelNotification('sub_$subscriptionId');

      _invalidateProviders();
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

      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelNotification('sub_$subscriptionId');

      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pauseSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      final subscription = await repository.getSubscription(subscriptionId);
      if (subscription == null) throw Exception('Subscription not found');
      if (subscription.status == SubscriptionStatus.paused) {
        state = const AsyncValue.data(null);
        return;
      }

      final updatedSub = subscription.copyWith(
        status: SubscriptionStatus.paused,
        pausedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.updateSubscription(updatedSub);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resumeSubscription(String subscriptionId, String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      final subscription = await repository.getSubscription(subscriptionId);
      if (subscription == null) throw Exception('Subscription not found');

      DateTime newBillingDate = subscription.nextBillingDate;
      if (subscription.pausedAt != null) {
        final pauseDuration = DateTime.now().difference(subscription.pausedAt!);
        newBillingDate = subscription.nextBillingDate.add(pauseDuration);
      }

      if (newBillingDate.isBefore(DateTime.now())) {
        newBillingDate = DateTime.now().add(const Duration(days: 1));
      }

      final updatedSub = subscription.copyWith(
        status: SubscriptionStatus.active,
        pausedAt: null,
        nextBillingDate: newBillingDate,
        updatedAt: DateTime.now(),
      );

      await repository.updateSubscription(updatedSub);
      _invalidateProviders();
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

  void _invalidateProviders() {
    _ref.invalidate(subscriptionsProvider);
    _ref.invalidate(activeSubscriptionsProvider);
    _ref.invalidate(filteredSubscriptionsProvider);
    _ref.invalidate(totalMonthlyCostProvider);
    _ref.invalidate(totalYearlyCostProvider);
    _ref.invalidate(subscriptionsDueSoonProvider);
    _ref.invalidate(selectedSubscriptionProvider);
    _ref.invalidate(currentMonthlySummaryProvider);
  }
}

/// Subscription notifier provider
final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<void>>((ref) {
  return SubscriptionNotifier(ref);
});
