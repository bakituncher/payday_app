/// Repository interface for savings goal operations
import 'package:payday/core/models/savings_goal.dart';

abstract class SavingsGoalRepository {
  /// Get all savings goals for a user
  Future<List<SavingsGoal>> getSavingsGoals(String userId);

  /// Add a new savings goal
  Future<void> addSavingsGoal(SavingsGoal goal);

  /// Update a savings goal
  Future<void> updateSavingsGoal(SavingsGoal goal);

  /// Delete a savings goal
  Future<void> deleteSavingsGoal(String goalId);

  /// Add money to a savings goal
  Future<void> addMoneyToGoal(String goalId, double amount);

  /// Withdraw money from a savings goal
  Future<void> withdrawMoneyFromGoal(String goalId, double amount);
}

