/// Mock implementation of SavingsGoalRepository for UI testing
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';

class MockSavingsGoalRepository implements SavingsGoalRepository {
  // In-memory storage
  final List<SavingsGoal> _goals = [];

  @override
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _goals.where((g) => g.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _goals.add(goal);
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  @override
  Future<void> deleteSavingsGoal(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _goals.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<void> addMoneyToGoal(String goalId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
    }
  }

  @override
  Future<void> withdrawMoneyFromGoal(String goalId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final newAmount = (goal.currentAmount - amount).clamp(0.0, double.infinity);
      _goals[index] = goal.copyWith(currentAmount: newAmount);
    }
  }
}

