/// Local implementation of MonthlySummaryRepository using SharedPreferences
/// Data persists across app restarts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/budget_goal.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';

class LocalMonthlySummaryRepository implements MonthlySummaryRepository {
  static const String _summariesKey = 'local_monthly_summaries';
  static const String _allocationsKey = 'local_leftover_allocations';
  static const String _budgetGoalsKey = 'local_budget_goals';

  Map<String, MonthlySummary>? _cachedSummaries;
  List<LeftoverAllocation>? _cachedAllocations;
  List<BudgetGoal>? _cachedBudgetGoals;

  // Load summaries from SharedPreferences
  Future<Map<String, MonthlySummary>> _loadSummaries() async {
    if (_cachedSummaries != null) return _cachedSummaries!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_summariesKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedSummaries = {};
      return _cachedSummaries!;
    }

    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedSummaries = jsonMap.map(
        (key, value) => MapEntry(key, MonthlySummary.fromJson(value as Map<String, dynamic>)),
      );
    } catch (e) {
      _cachedSummaries = {};
    }

    return _cachedSummaries!;
  }

  Future<void> _saveSummaries() async {
    if (_cachedSummaries == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonMap = _cachedSummaries!.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_summariesKey, json.encode(jsonMap));
  }

  // Load allocations from SharedPreferences
  Future<List<LeftoverAllocation>> _loadAllocations() async {
    if (_cachedAllocations != null) return _cachedAllocations!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allocationsKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedAllocations = [];
      return _cachedAllocations!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedAllocations = jsonList
          .map((json) => LeftoverAllocation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedAllocations = [];
    }

    return _cachedAllocations!;
  }

  Future<void> _saveAllocations() async {
    if (_cachedAllocations == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedAllocations!.map((a) => a.toJson()).toList();
    await prefs.setString(_allocationsKey, json.encode(jsonList));
  }

  // Load budget goals from SharedPreferences
  Future<List<BudgetGoal>> _loadBudgetGoals() async {
    if (_cachedBudgetGoals != null) return _cachedBudgetGoals!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_budgetGoalsKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedBudgetGoals = [];
      return _cachedBudgetGoals!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedBudgetGoals = jsonList
          .map((json) => BudgetGoal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedBudgetGoals = [];
    }

    return _cachedBudgetGoals!;
  }

  Future<void> _saveBudgetGoals() async {
    if (_cachedBudgetGoals == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedBudgetGoals!.map((g) => g.toJson()).toList();
    await prefs.setString(_budgetGoalsKey, json.encode(jsonList));
  }

  @override
  Future<MonthlySummary?> getMonthlySummary(String userId, int year, int month) async {
    final summaries = await _loadSummaries();
    final key = '${userId}_${year}_$month';
    return summaries[key];
  }

  @override
  Future<List<MonthlySummary>> getYearlySummaries(String userId, int year) async {
    final summaries = await _loadSummaries();
    return summaries.values
        .where((s) => s.userId == userId && s.year == year)
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // Alias for DataMigrationService compatibility
  Future<List<MonthlySummary>> getSummariesForYear(String userId, int year) => getYearlySummaries(userId, year);

  @override
  Future<List<MonthlySummary>> getRecentSummaries(String userId, int count) async {
    final summaries = await _loadSummaries();
    final userSummaries = summaries.values
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
    await _loadSummaries();
    final key = '${summary.userId}_${summary.year}_${summary.month}';
    _cachedSummaries![key] = summary;
    await _saveSummaries();
  }

  @override
  Future<void> finalizeSummary(String summaryId) async {
    await _loadSummaries();
    if (_cachedSummaries!.containsKey(summaryId)) {
      _cachedSummaries![summaryId] = _cachedSummaries![summaryId]!.copyWith(
        finalizedAt: DateTime.now(),
      );
      await _saveSummaries();
    }
  }

  @override
  Future<void> recordLeftoverAllocation(LeftoverAllocation allocation) async {
    await _loadAllocations();
    _cachedAllocations!.add(allocation);
    await _saveAllocations();
  }

  @override
  Future<List<LeftoverAllocation>> getLeftoverAllocations(String summaryId) async {
    final allocations = await _loadAllocations();
    return allocations.where((a) => a.summaryId == summaryId).toList();
  }

  // Budget Goals
  @override
  Future<List<BudgetGoal>> getBudgetGoals(String userId) async {
    final goals = await _loadBudgetGoals();
    return goals.where((g) => g.userId == userId && g.isActive).toList();
  }

  @override
  Future<BudgetGoal?> getBudgetGoalByCategory(String userId, String categoryId) async {
    final goals = await _loadBudgetGoals();
    try {
      return goals.firstWhere(
        (g) => g.userId == userId && g.categoryId == categoryId && g.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBudgetGoal(BudgetGoal goal) async {
    await _loadBudgetGoals();
    final index = _cachedBudgetGoals!.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _cachedBudgetGoals![index] = goal.copyWith(updatedAt: DateTime.now());
    } else {
      _cachedBudgetGoals!.add(goal.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    await _saveBudgetGoals();
  }

  @override
  Future<void> deleteBudgetGoal(String goalId) async {
    await _loadBudgetGoals();
    _cachedBudgetGoals!.removeWhere((g) => g.id == goalId);
    await _saveBudgetGoals();
  }

  @override
  Future<void> updateBudgetSpent(String goalId, double amount) async {
    await _loadBudgetGoals();
    final index = _cachedBudgetGoals!.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _cachedBudgetGoals![index] = _cachedBudgetGoals![index].copyWith(
        spentAmount: _cachedBudgetGoals![index].spentAmount + amount,
        updatedAt: DateTime.now(),
      );
      await _saveBudgetGoals();
    }
  }

  @override
  Future<void> resetBudgetGoals(String userId) async {
    await _loadBudgetGoals();
    for (var i = 0; i < _cachedBudgetGoals!.length; i++) {
      if (_cachedBudgetGoals![i].userId == userId) {
        _cachedBudgetGoals![i] = _cachedBudgetGoals![i].copyWith(
          spentAmount: 0,
          updatedAt: DateTime.now(),
        );
      }
    }
    await _saveBudgetGoals();
  }

  @override
  Future<YearlyStatistics> getYearlyStatistics(String userId, int year) async {
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

    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> categoryExpenses = {};
    String bestMonth = '';
    String worstMonth = '';
    double bestSavings = double.negativeInfinity;
    double worstSavings = double.infinity;

    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    for (final summary in yearlySummaries) {
      totalIncome += summary.totalIncome;
      totalExpenses += summary.totalExpenses;

      final savings = summary.totalIncome - summary.totalExpenses;
      if (savings > bestSavings) {
        bestSavings = savings;
        bestMonth = monthNames[summary.month];
      }
      if (savings < worstSavings) {
        worstSavings = savings;
        worstMonth = monthNames[summary.month];
      }

      for (final entry in summary.expensesByCategory.entries) {
        categoryExpenses[entry.key] = (categoryExpenses[entry.key] ?? 0) + entry.value;
      }
    }

    final totalSaved = totalIncome - totalExpenses;
    final monthsTracked = yearlySummaries.length;

    return YearlyStatistics(
      year: year,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalSaved: totalSaved,
      averageMonthlyExpenses: monthsTracked > 0 ? totalExpenses / monthsTracked : 0,
      averageSavingsRate: totalIncome > 0 ? (totalSaved / totalIncome) * 100 : 0,
      expensesByCategory: categoryExpenses,
      monthsTracked: monthsTracked,
      bestMonth: bestMonth,
      worstMonth: worstMonth,
    );
  }

  /// Clear cache to force reload from storage
  void clearCache() {
    _cachedSummaries = null;
    _cachedAllocations = null;
    _cachedBudgetGoals = null;
  }
}

