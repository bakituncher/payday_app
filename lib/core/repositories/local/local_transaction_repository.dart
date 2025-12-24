/// Local implementation of TransactionRepository using SharedPreferences
/// Data persists across app restarts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/repositories/transaction_repository.dart';

// ✅ DÜZELTME: 'Transaction' ismini gizleyerek çakışmayı önledik.
// Sadece 'Timestamp' sınıfına ihtiyacımız var.
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

class LocalTransactionRepository implements TransactionRepository {
  static const String _storageKey = 'local_transactions';

  List<Transaction>? _cachedTransactions;

  Future<List<Transaction>> _loadTransactions() async {
    if (_cachedTransactions != null) return _cachedTransactions!;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      _cachedTransactions = [];
      return _cachedTransactions!;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedTransactions = jsonList
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _cachedTransactions = [];
    }

    return _cachedTransactions!;
  }

  Future<void> _saveTransactions() async {
    if (_cachedTransactions == null) return;

    final prefs = await SharedPreferences.getInstance();

    // Timestamp kontrolü ve temizleme işlemi
    final jsonList = _cachedTransactions!.map((t) {
      final Map<String, dynamic> data = t.toJson();
      final Map<String, dynamic> sanitizedData = {};

      data.forEach((key, value) {
        // Eğer değer Firestore Timestamp ise, ISO String'e çevir
        if (value is Timestamp) {
          sanitizedData[key] = value.toDate().toIso8601String();
        } else {
          sanitizedData[key] = value;
        }
      });

      return sanitizedData;
    }).toList();

    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  @override
  Future<List<Transaction>> getTransactions(String userId) async {
    final transactions = await _loadTransactions();
    return transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getTransactionsForCurrentCycle(
      String userId,
      DateTime payCycleStart,
      ) async {
    final transactions = await _loadTransactions();
    return transactions
        .where((t) =>
    t.userId == userId &&
        (t.date.isAfter(payCycleStart) ||
            t.date.isAtSameMomentAs(payCycleStart)) &&
        t.date.isBefore(DateTime.now().add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final transactions = await _loadTransactions();
    return transactions
        .where((t) =>
    t.userId == userId &&
        (t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)) &&
        (t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _loadTransactions();
    _cachedTransactions!.add(transaction);
    await _saveTransactions();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _loadTransactions();
    final index = _cachedTransactions!.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _cachedTransactions![index] = transaction;
      await _saveTransactions();
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId, String userId) async {
    await _loadTransactions();
    _cachedTransactions!.removeWhere((t) => t.id == transactionId);
    await _saveTransactions();
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
    await _loadTransactions();
    final initialCount = _cachedTransactions!.length;
    _cachedTransactions!.removeWhere(
          (t) => t.userId == userId && t.date.isBefore(date),
    );
    final deletedCount = initialCount - _cachedTransactions!.length;
    if (deletedCount > 0) {
      await _saveTransactions();
    }
    return deletedCount;
  }

  @override
  Future<int> getTransactionCount(String userId) async {
    final transactions = await _loadTransactions();
    return transactions.where((t) => t.userId == userId).length;
  }

  @override
  Future<void> deleteAllUserTransactions(String userId) async {
    await _loadTransactions();
    _cachedTransactions!.removeWhere((t) => t.userId == userId);
    await _saveTransactions();
  }

  /// Clear cache to force reload from storage
  void clearCache() {
    _cachedTransactions = null;
  }
}