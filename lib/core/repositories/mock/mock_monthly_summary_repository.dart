/// Mock implementation of MonthlySummaryRepository
/// For development and testing - data persists in memory only
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/budget_goal.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';

class MockMonthlySummaryRepository implements MonthlySummaryRepository {
  final Map<String, MonthlySummary> _summaries = {};
  final List<LeftoverAllocation> _allocations = [];
  final List<BudgetGoal> _budgetGoals = [];

  @override
  Future<MonthlySummary?> getMonthlySummary(String userId, int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final key = '${userId}_${year}_$month';
    return _summaries[key];
  }

  @override
  Future<List<MonthlySummary>> getYearlySummaries(String userId, int year) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _summaries.values
        .where((s) => s.userId == userId && s.year == year)
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  @override
  Future<List<MonthlySummary>> getRecentSummaries(String userId, int count) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userSummaries = _summaries.values
        .where((s) => s.userId == userId)
        .toList()
      ..sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.month.compareTo(a.month);
      });
    return userSummaries.take(count).toList();
  }

  @override
  Future<void> saveMonthlySummary(MonthlySummary summary) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final key = '${summary.userId}_${summary.year}_${summary.month}';
    _summaries[key] = summary;
  }

  @override
  Future<void> finalizeSummary(String summaryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_summaries.containsKey(summaryId)) {
      _summaries[summaryId] = _summaries[summaryId]!.copyWith(
        finalizedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> recordLeftoverAllocation(LeftoverAllocation allocation) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _allocations.add(allocation);
  }

  @override
  Future<List<LeftoverAllocation>> getLeftoverAllocations(String summaryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allocations.where((a) => a.summaryId == summaryId).toList();
  }

  // Budget Goals
  @override
  Future<List<BudgetGoal>> getBudgetGoals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _budgetGoals.where((g) => g.userId == userId && g.isActive).toList();
  }

  @override
  Future<BudgetGoal?> getBudgetGoalByCategory(String userId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _budgetGoals.firstWhere(
        (g) => g.userId == userId && g.categoryId == categoryId && g.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBudgetGoal(BudgetGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _budgetGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _budgetGoals[index] = goal.copyWith(updatedAt: DateTime.now());
    } else {
      _budgetGoals.add(goal.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> deleteBudgetGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _budgetGoals.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<void> updateBudgetSpent(String goalId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _budgetGoals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _budgetGoals[index] = _budgetGoals[index].copyWith(
        spentAmount: _budgetGoals[index].spentAmount + amount,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> resetBudgetGoals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _budgetGoals.length; i++) {
      if (_budgetGoals[i].userId == userId) {
        _budgetGoals[i] = _budgetGoals[i].copyWith(
          spentAmount: 0,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<YearlyStatistics> getYearlyStatistics(String userId, int year) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final yearlySummaries = await getYearlySummaries(userId, year);

    if (yearlySummaries.isEmpty) {
      return YearlyStatistics(
        year: year,
        totalIncome: 0,
        totalExpenses: 0,
        totalSaved: 0,
        averageMonthlyExpenses: 0,
        averageSavingsRate: 0,
        expensesByCategory: {},
        monthsTracked: 0,
        bestMonth: '',
        worstMonth: '',
      );
    }

    final totalIncome = yearlySummaries.fold<double>(0, (sum, s) => sum + s.totalIncome);
    final totalExpenses = yearlySummaries.fold<double>(0, (sum, s) => sum + s.totalExpenses);
    final totalSaved = totalIncome - totalExpenses;

    // Aggregate expenses by category
    final expensesByCategory = <String, double>{};
    for (final summary in yearlySummaries) {
      for (final entry in summary.expensesByCategory.entries) {
        expensesByCategory[entry.key] = (expensesByCategory[entry.key] ?? 0) + entry.value;
      }
    }

    // Find best and worst months
    final sortedByLeftover = List<MonthlySummary>.from(yearlySummaries)
      ..sort((a, b) => b.leftoverAmount.compareTo(a.leftoverAmount));

    return YearlyStatistics(
      year: year,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalSaved: totalSaved,
      averageMonthlyExpenses: totalExpenses / yearlySummaries.length,
      averageSavingsRate: totalIncome > 0 ? (totalSaved / totalIncome * 100) : 0,
      expensesByCategory: expensesByCategory,
      monthsTracked: yearlySummaries.length,
      bestMonth: sortedByLeftover.first.monthName,
      worstMonth: sortedByLeftover.last.monthName,
    );
  }
}

