/// Mock implementation of TransactionRepository for UI testing
import 'package:payday_flutter/core/models/transaction.dart';
import 'package:payday_flutter/core/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  // In-memory storage
  final List<Transaction> _transactions = [];

  @override
  Future<List<Transaction>> getTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getTransactionsForCurrentCycle(
    String userId,
    DateTime payCycleStart,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions
        .where((t) =>
            t.userId == userId &&
            t.date.isAfter(payCycleStart) &&
            t.date.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.removeWhere((t) => t.id == transactionId);
  }

  @override
  Future<double> getTotalExpensesForCycle(
    String userId,
    DateTime payCycleStart,
  ) async {
    final transactions = await getTransactionsForCurrentCycle(userId, payCycleStart);
    return transactions
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> deleteTransactionsOlderThan(String userId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final initialCount = _transactions.length;
    _transactions.removeWhere(
      (t) => t.userId == userId && t.date.isBefore(date),
    );
    return initialCount - _transactions.length;
  }

  @override
  Future<int> getTransactionCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _transactions.where((t) => t.userId == userId).length;
  }
}

