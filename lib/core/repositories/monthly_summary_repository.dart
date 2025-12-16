/// Monthly Summary Repository Interface
/// Manages monthly financial summaries and leftover allocations
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/budget_goal.dart';

abstract class MonthlySummaryRepository {
  /// Get summary for a specific month
  Future<MonthlySummary?> getMonthlySummary(String oderId, int year, int month);

  /// Get all summaries for a year
  Future<List<MonthlySummary>> getYearlySummaries(String oderId, int year);

  /// Get last N monthly summaries
  Future<List<MonthlySummary>> getRecentSummaries(String oderId, int count);

  /// Create or update monthly summary
  Future<void> saveMonthlySummary(MonthlySummary summary);

  /// Finalize monthly summary (mark as complete)
  Future<void> finalizeSummary(String summaryId);

  /// Record leftover allocation decision
  Future<void> recordLeftoverAllocation(LeftoverAllocation allocation);

  /// Get leftover allocations for a summary
  Future<List<LeftoverAllocation>> getLeftoverAllocations(String summaryId);

  // Budget Goals
  /// Get all budget goals for user
  Future<List<BudgetGoal>> getBudgetGoals(String oderId);

  /// Get budget goal by category
  Future<BudgetGoal?> getBudgetGoalByCategory(String oderId, String categoryId);

  /// Create or update budget goal
  Future<void> saveBudgetGoal(BudgetGoal goal);

  /// Delete budget goal
  Future<void> deleteBudgetGoal(String goalId);

  /// Update spent amount for a budget goal
  Future<void> updateBudgetSpent(String goalId, double amount);

  /// Reset all budget goals for new period
  Future<void> resetBudgetGoals(String oderId);

  /// Get yearly statistics
  Future<YearlyStatistics> getYearlyStatistics(String oderId, int year);
}

/// Yearly statistics summary
class YearlyStatistics {
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double totalSaved;
  final double averageMonthlyExpenses;
  final double averageSavingsRate;
  final Map<String, double> expensesByCategory;
  final int monthsTracked;
  final String bestMonth; // Month with highest savings
  final String worstMonth; // Month with lowest savings

  const YearlyStatistics({
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSaved,
    required this.averageMonthlyExpenses,
    required this.averageSavingsRate,
    required this.expensesByCategory,
    required this.monthsTracked,
    required this.bestMonth,
    required this.worstMonth,
  });
}

