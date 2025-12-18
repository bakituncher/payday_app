/// Auto Transfer Service
/// Handles automatic transfers to savings goals on payday
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';
import 'package:payday/core/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class AutoTransferService {
  final SavingsGoalRepository _savingsGoalRepository;
  final TransactionRepository _transactionRepository;

  AutoTransferService({
    required SavingsGoalRepository savingsGoalRepository,
    required TransactionRepository transactionRepository,
  })  : _savingsGoalRepository = savingsGoalRepository,
        _transactionRepository = transactionRepository;

  /// Process auto-transfers for all goals on payday
  /// Returns the total amount transferred
  Future<AutoTransferResult> processAutoTransfers(String userId) async {
    try {
      print('💰 Auto-Transfer: Starting for user $userId');

      // Get all savings goals
      final goals = await _savingsGoalRepository.getSavingsGoals(userId);
      print('💰 Auto-Transfer: Found ${goals.length} total goals');

      // Filter goals with auto-transfer enabled and not completed
      final eligibleGoals = goals.where(
        (g) => g.autoTransferEnabled && !g.isCompleted
      ).toList();

      print('💰 Auto-Transfer: ${eligibleGoals.length} eligible goals');

      if (eligibleGoals.isEmpty) {
        return AutoTransferResult(
          success: true,
          totalAmount: 0.0,
          transferCount: 0,
          goalNames: [],
        );
      }

      double totalTransferred = 0.0;
      final transferredGoals = <String>[];

      // Process each eligible goal
      for (final goal in eligibleGoals) {
        try {
          final transferAmount = goal.autoTransferAmount;
          print('💰 Auto-Transfer: Processing ${goal.name} - Amount: $transferAmount');

          // Add money to the savings goal
          await _savingsGoalRepository.addMoneyToGoal(
            goal.id,
            transferAmount,
            userId,
          );

          // Create an expense transaction to deduct from budget
          final transaction = Transaction(
            id: const Uuid().v4(),
            userId: userId,
            amount: transferAmount,
            categoryId: 'savings',
            categoryName: 'Savings',
            categoryEmoji: goal.emoji,
            date: DateTime.now(),
            note: 'Auto-transfer to ${goal.name}',
            isExpense: true, // This is an expense - money leaving the budget
          );

          await _transactionRepository.addTransaction(transaction);

          totalTransferred += transferAmount;
          transferredGoals.add(goal.name);
          print('💰 Auto-Transfer: Success for ${goal.name} - Transaction created');
        } catch (e) {
          print('❌ Auto-Transfer: Failed for ${goal.name}: $e');
          // Continue with other goals even if one fails
        }
      }

      print('💰 Auto-Transfer: Complete - Total: $totalTransferred, Count: ${transferredGoals.length}');

      return AutoTransferResult(
        success: true,
        totalAmount: totalTransferred,
        transferCount: transferredGoals.length,
        goalNames: transferredGoals,
      );
    } catch (e) {
      print('❌ Auto-Transfer: Error: $e');
      return AutoTransferResult(
        success: false,
        totalAmount: 0.0,
        transferCount: 0,
        goalNames: [],
        error: e.toString(),
      );
    }
  }
}

/// Result of auto-transfer operation
class AutoTransferResult {
  final bool success;
  final double totalAmount;
  final int transferCount;
  final List<String> goalNames;
  final String? error;

  const AutoTransferResult({
    required this.success,
    required this.totalAmount,
    required this.transferCount,
    required this.goalNames,
    this.error,
  });
}

