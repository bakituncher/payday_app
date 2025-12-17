/// Local implementation of SavingsGoalRepository using SharedPreferences
/// Data persists across app restarts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';

class LocalSavingsGoalRepository implements SavingsGoalRepository {
  static const String _storageKey = 'local_savings_goals';

  List<SavingsGoal>? _cachedGoals;

  Future<List<SavingsGoal>> _loadGoals() async {
    if (_cachedGoals != null) return _cachedGoals!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedGoals = [];
      return _cachedGoals!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedGoals = jsonList
          .map((json) => SavingsGoal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedGoals = [];
    }

    return _cachedGoals!;
  }

  Future<void> _saveGoals() async {
    if (_cachedGoals == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedGoals!.map((g) => g.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  @override
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    final goals = await _loadGoals();
    return goals.where((g) => g.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await _loadGoals();
    _cachedGoals!.add(goal);
    await _saveGoals();
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await _loadGoals();
    final index = _cachedGoals!.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _cachedGoals![index] = goal;
      await _saveGoals();
    }
  }

  @override
  Future<void> deleteSavingsGoal(String goalId) async {
    await _loadGoals();
    _cachedGoals!.removeWhere((g) => g.id == goalId);
    await _saveGoals();
  }

  @override
  Future<void> addMoneyToGoal(String goalId, double amount) async {
    await _loadGoals();
    final index = _cachedGoals!.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _cachedGoals![index];
      _cachedGoals![index] = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      await _saveGoals();
    }
  }

  @override
  Future<void> withdrawMoneyFromGoal(String goalId, double amount) async {
    await _loadGoals();
    final index = _cachedGoals!.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _cachedGoals![index];
      final newAmount = (goal.currentAmount - amount).clamp(0.0, double.infinity);
      _cachedGoals![index] = goal.copyWith(currentAmount: newAmount);
      await _saveGoals();
    }
  }

  /// Clear cache to force reload from storage
  void clearCache() {
    _cachedGoals = null;
  }
}

