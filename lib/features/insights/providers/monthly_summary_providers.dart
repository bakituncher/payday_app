/// Monthly Summary Providers
/// State management for monthly financial summaries
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/budget_goal.dart';
import 'package:payday/core/models/summary_period.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';
import 'package:payday/core/services/financial_insights_service.dart';
import 'package:payday/core/services/leftover_allocation_service.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
// Note: currentCycleTransactionsProvider is exported by home_providers.dart
// Note: activeSubscriptionsProvider is exported by subscription_providers.dart

/// Leftover Allocation Service Provider
final leftoverAllocationServiceProvider = Provider<LeftoverAllocationService>((ref) {
  return LeftoverAllocationService(
    savingsGoalRepository: ref.watch(savingsGoalRepositoryProvider),
    monthlySummaryRepository: ref.watch(monthlySummaryRepositoryProvider),
    userSettingsRepository: ref.watch(userSettingsRepositoryProvider),
  );
});

/// Savings Goals Provider
final savingsGoalsProvider = FutureProvider<List<dynamic>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(savingsGoalRepositoryProvider);
  return repository.getSavingsGoals(userId);
});

/// NEW: Selected Summary Period Provider
final summaryPeriodProvider = StateProvider<SummaryPeriod>((ref) => SummaryPeriod.monthly);

/// Current summary provider - Calculates based on selected period
final currentSummaryProvider = FutureProvider<MonthlySummary?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  // final repository = ref.watch(monthlySummaryRepositoryProvider); // Not caching arbitrary periods yet
  final period = ref.watch(summaryPeriodProvider);

  final userSettings = await ref.watch(userSettingsProvider.future);

  // Note: currentCycleTransactionsProvider currently fetches Month data.
  // For true weekly/bi-weekly accuracy across months, we might need a broader fetch,
  // but for now, assuming users look at current month's context is safe or we use what we have.
  // Ideally, we'd have a 'transactionService.getTransactions(startDate, endDate)' provider.
  // For this implementation, we will use the existing transaction provider which gives us
  // the current cycle transactions, which should be sufficient for "current week" if it's in the cycle.
  // If the week straddles months, this might miss data.
  // FIXME: Improve transaction fetching to be date-range aware.
  final transactions = await ref.watch(currentCycleTransactionsProvider.future);
  final subscriptions = await ref.watch(activeSubscriptionsProvider.future);

  if (userSettings == null) {
    return null;
  }

  // Calculate previous period expenses for trend
  // This is a simplified fetch - ideally we'd query the DB for the exact previous range
  // For now, we will pass null or 0 to avoid complex DB queries in this iteration
  double? previousPeriodExpenses;
  // TODO: Implement fetching previous period transactions for accurate trend

  // Generate fresh summary with current data
  final summary = FinancialInsightsService.generateSummary(
    userId: userId,
    period: period,
    totalIncome: userSettings.incomeAmount,
    transactions: transactions,
    subscriptions: subscriptions,
    previousPeriodExpenses: previousPeriodExpenses,
  );

  return summary;
});


/// Current month summary provider - Legacy support / Specific for monthly view persistence
final currentMonthlySummaryProvider = FutureProvider<MonthlySummary?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(monthlySummaryRepositoryProvider);
  final now = DateTime.now();

  // Always generate fresh summary from current data
  final userSettings = await ref.watch(userSettingsProvider.future);
  final transactions = await ref.watch(currentCycleTransactionsProvider.future);
  final subscriptions = await ref.watch(activeSubscriptionsProvider.future);

  if (userSettings == null) {
    return null;
  }

  // Get previous month's expenses for trend comparison
  double? previousMonthExpenses;
  final prevSummary = await repository.getMonthlySummary(
    userId,
    now.month == 1 ? now.year - 1 : now.year,
    now.month == 1 ? 12 : now.month - 1,
  );
  if (prevSummary != null) {
    previousMonthExpenses = prevSummary.totalExpenses;
  }

  // Generate fresh summary with current data
  final summary = FinancialInsightsService.generateMonthlySummary(
    userId: userId,
    year: now.year,
    month: now.month,
    totalIncome: userSettings.incomeAmount,
    transactions: transactions,
    subscriptions: subscriptions,
    previousMonthExpenses: previousMonthExpenses,
  );

  // Save the generated summary for historical tracking
  await repository.saveMonthlySummary(summary);

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

/// Allocation loading state
final allocationLoadingProvider = StateProvider<bool>((ref) => false);

/// Monthly Summary Notifier for mutations
class MonthlySummaryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MonthlySummaryNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Allocate leftover money - ACTUALLY PROCESSES THE ALLOCATION
  Future<AllocationResult> allocateLeftover({
    required String summaryId,
    required LeftoverAction action,
    required double amount,
    String? targetGoalId,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    _ref.read(allocationLoadingProvider.notifier).state = true;

    try {
      final userId = _ref.read(currentUserIdProvider);
      final allocationService = _ref.read(leftoverAllocationServiceProvider);
      final repository = _ref.read(monthlySummaryRepositoryProvider);

      // Process the actual allocation (creates/updates savings goals)
      final result = await allocationService.processAllocation(
        userId: userId,
        summaryId: summaryId,
        action: action,
        amount: amount,
        targetGoalId: targetGoalId,
        note: note,
      );

      if (result.success) {
        // Record the allocation in summary repository
        final allocation = LeftoverAllocation(
          id: '${summaryId}_${action.name}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          summaryId: summaryId,
          action: action,
          amount: amount,
          allocatedAt: DateTime.now(),
          note: note ?? result.message,
        );

        await repository.recordLeftoverAllocation(allocation);

        // Refresh all related data
        _ref.invalidate(currentMonthlySummaryProvider);
        _ref.invalidate(savingsGoalsProvider);
      }

      state = const AsyncValue.data(null);
      _ref.read(allocationLoadingProvider.notifier).state = false;

      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(allocationLoadingProvider.notifier).state = false;

      return AllocationResult(
        success: false,
        message: 'Error: ${e.toString()}',
        action: action,
        amount: amount,
        error: e.toString(),
      );
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
