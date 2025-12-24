/// Repository interface for transaction operations
import 'package:payday/core/models/transaction.dart';

abstract class TransactionRepository {
  /// Get all transactions for a user
  Future<List<Transaction>> getTransactions(String userId);

  /// Get transactions for current pay cycle
  Future<List<Transaction>> getTransactionsForCurrentCycle(
    String userId,
    DateTime payCycleStart,
  );

  /// Get transactions within a date range
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction);

  /// Update a transaction
  Future<void> updateTransaction(Transaction transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId, String userId);

  /// Get total expenses for current cycle
  Future<double> getTotalExpensesForCycle(
    String userId,
    DateTime payCycleStart,
  );

  /// Delete transactions older than specified date (for storage optimization)
  Future<int> deleteTransactionsOlderThan(String userId, DateTime date);

  /// Get transaction count for a user
  Future<int> getTransactionCount(String userId);

  /// Delete all transactions for a user
  Future<void> deleteAllUserTransactions(String userId);
}

