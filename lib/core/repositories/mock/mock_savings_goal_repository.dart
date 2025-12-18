/// Mock implementation of SavingsGoalRepository for UI testing
import 'dart:async';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';

class MockSavingsGoalRepository implements SavingsGoalRepository {
  // In-memory storage
  final List<SavingsGoal> _goals = [];
  final _streamController = StreamController<List<SavingsGoal>>.broadcast();

  @override
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _goals.where((g) => g.userId == userId).toList()
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

  void _notifyListeners() {
    _streamController.add(_goals);
  }

  @override
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _goals.add(goal);
    _notifyListeners();
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _notifyListeners();
    }
  }

  @override
  Future<void> deleteSavingsGoal(String goalId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _goals.removeWhere((g) => g.id == goalId);
    _notifyListeners();
  }

  @override
  Future<void> addMoneyToGoal(String goalId, double amount, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      _notifyListeners();
    }
  }

  @override
  Future<void> withdrawMoneyFromGoal(String goalId, double amount, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final newAmount = (goal.currentAmount - amount).clamp(0.0, double.infinity);
      _goals[index] = goal.copyWith(currentAmount: newAmount);
      _notifyListeners();
    }
  }

  void dispose() {
    _streamController.close();
  }
}

