/// Repository interface for transaction operations
import 'package:payday_flutter/core/models/transaction.dart';

abstract class TransactionRepository {
  /// Get all transactions for a user
  Future<List<Transaction>> getTransactions(String userId);

  /// Get transactions for current pay cycle
  Future<List<Transaction>> getTransactionsForCurrentCycle(
    String userId,
    DateTime payCycleStart,
  );

  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction);

  /// Update a transaction
  Future<void> updateTransaction(Transaction transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId);

  /// Get total expenses for current cycle
  Future<double> getTotalExpensesForCycle(
    String userId,
    DateTime payCycleStart,
  );

  /// Delete transactions older than specified date (for storage optimization)
  Future<int> deleteTransactionsOlderThan(String userId, DateTime date);

  /// Get transaction count for a user
  Future<int> getTransactionCount(String userId);
}

