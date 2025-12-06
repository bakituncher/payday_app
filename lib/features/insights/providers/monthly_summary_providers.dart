/// Monthly Summary Providers
/// State management for monthly financial summaries
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/models/monthly_summary.dart';
import 'package:payday_flutter/core/models/budget_goal.dart';
import 'package:payday_flutter/core/models/transaction.dart';
import 'package:payday_flutter/core/providers/repository_providers.dart';
import 'package:payday_flutter/core/repositories/monthly_summary_repository.dart';
import 'package:payday_flutter/core/services/financial_insights_service.dart';
import 'package:payday_flutter/features/home/providers/home_providers.dart';
import 'package:payday_flutter/features/subscriptions/providers/subscription_providers.dart';

/// Current month summary provider
final currentMonthlySummaryProvider = FutureProvider<MonthlySummary?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(monthlySummaryRepositoryProvider);
  final now = DateTime.now();

  // Try to get existing summary
  var summary = await repository.getMonthlySummary(userId, now.year, now.month);

  // If no summary exists, generate one from current data
  if (summary == null) {
    final userSettings = await ref.watch(userSettingsProvider.future);
    final transactions = await ref.watch(currentCycleTransactionsProvider.future);
    final subscriptions = await ref.watch(activeSubscriptionsProvider.future);

    if (userSettings != null) {
      summary = FinancialInsightsService.generateMonthlySummary(
        userId: userId,
        year: now.year,
        month: now.month,
        totalIncome: userSettings.incomeAmount,
        transactions: transactions,
        subscriptions: subscriptions,
      );

      // Save the generated summary
      await repository.saveMonthlySummary(summary);
    }
  }

  return summary;
});

/// Recent monthly summaries (last 6 months)
final recentSummariesProvider = FutureProvider<List<MonthlySummary>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(monthlySummaryRepositoryProvider);
  return repository.getRecentSummaries(userId, 6);
});

/// Yearly statistics provider
final yearlyStatisticsProvider = FutureProvider.family<YearlyStatistics, int>((ref, year) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(monthlySummaryRepositoryProvider);
  return repository.getYearlyStatistics(userId, year);
});

/// Current year statistics
final currentYearStatisticsProvider = FutureProvider<YearlyStatistics>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(yearlyStatisticsProvider(year).future);
});

/// Budget goals provider
final budgetGoalsProvider = FutureProvider<List<BudgetGoal>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(monthlySummaryRepositoryProvider);
  return repository.getBudgetGoals(userId);
});

/// Selected leftover action provider
final selectedLeftoverActionProvider = StateProvider<LeftoverAction?>((ref) => null);

/// Monthly Summary Notifier for mutations
class MonthlySummaryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MonthlySummaryNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Allocate leftover money
  Future<void> allocateLeftover({
    required String summaryId,
    required LeftoverAction action,
    required double amount,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(currentUserIdProvider);
      final repository = _ref.read(monthlySummaryRepositoryProvider);

      final allocation = LeftoverAllocation(
        id: '${summaryId}_${action.name}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        summaryId: summaryId,
        action: action,
        amount: amount,
        allocatedAt: DateTime.now(),
        note: note ?? '',
      );

      await repository.recordLeftoverAllocation(allocation);

      // Invalidate to refresh
      _ref.invalidate(currentMonthlySummaryProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Finalize current month summary
  Future<void> finalizeCurrentMonth() async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(currentUserIdProvider);
      final repository = _ref.read(monthlySummaryRepositoryProvider);
      final now = DateTime.now();

      final summaryId = '${userId}_${now.year}_${now.month}';
      await repository.finalizeSummary(summaryId);

      _ref.invalidate(currentMonthlySummaryProvider);
      _ref.invalidate(recentSummariesProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create budget goal
  Future<void> createBudgetGoal(BudgetGoal goal) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(monthlySummaryRepositoryProvider);
      await repository.saveBudgetGoal(goal);

      _ref.invalidate(budgetGoalsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update budget goal
  Future<void> updateBudgetGoal(BudgetGoal goal) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(monthlySummaryRepositoryProvider);
      await repository.saveBudgetGoal(goal);

      _ref.invalidate(budgetGoalsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete budget goal
  Future<void> deleteBudgetGoal(String goalId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(monthlySummaryRepositoryProvider);
      await repository.deleteBudgetGoal(goalId);

      _ref.invalidate(budgetGoalsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Monthly summary notifier provider
final monthlySummaryNotifierProvider = StateNotifierProvider<MonthlySummaryNotifier, AsyncValue<void>>((ref) {
  return MonthlySummaryNotifier(ref);
});

