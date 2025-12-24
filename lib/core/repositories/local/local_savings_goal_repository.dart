/// Local implementation of SavingsGoalRepository using SharedPreferences
/// Data persists across app restarts
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';

class LocalSavingsGoalRepository implements SavingsGoalRepository {
  static const String _storageKey = 'local_savings_goals';

  List<SavingsGoal>? _cachedGoals;
  final _streamController = StreamController<List<SavingsGoal>>.broadcast();

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

  Map<String, dynamic> _toEncodable(Map<String, dynamic> goalJson) {
    // Ensure date fields are stored as epoch millis for SharedPreferences
    final createdAt = goalJson['createdAt'];
    final targetDate = goalJson['targetDate'];
    return {
      ...goalJson,
      'createdAt': createdAt is DateTime ? createdAt.millisecondsSinceEpoch : createdAt,
      'targetDate': targetDate is DateTime ? targetDate.millisecondsSinceEpoch : targetDate,
    };
  }

  Future<void> _saveGoals() async {
    if (_cachedGoals == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedGoals!.map((g) => _toEncodable(g.toJson())).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));

    // Notify stream listeners
    _streamController.add(_cachedGoals!);
  }

  @override
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    final goals = await _loadGoals();
    return goals.where((g) => g.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals(String userId) async* {
    // First, yield current data
    final goals = await getSavingsGoals(userId);
    yield goals;

    // Then listen for updates
    await for (final allGoals in _streamController.stream) {
      final userGoals = allGoals.where((g) => g.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield userGoals;
    }
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
  Future<void> deleteSavingsGoal(String goalId, String userId) async {
    await _loadGoals();
    _cachedGoals!.removeWhere((g) => g.id == goalId);
    await _saveGoals();
  }

  @override
  Future<void> addMoneyToGoal(String goalId, double amount, String userId) async {
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
  Future<void> withdrawMoneyFromGoal(String goalId, double amount, String userId) async {
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

  /// Dispose stream controller
  void dispose() {
    _streamController.close();
  }
}
