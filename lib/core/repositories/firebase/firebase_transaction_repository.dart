/// Firebase implementation of TransactionRepository
/// Data is stored in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payday/core/models/transaction.dart' as model;
import 'package:payday/core/repositories/transaction_repository.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  @override
  Future<List<model.Transaction>> getTransactions(String userId) async {
    final snapshot = await _getCollection(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<model.Transaction>> getTransactionsForCurrentCycle(
    String userId,
    DateTime payCycleStart,
  ) async {
    final snapshot = await _getCollection(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(payCycleStart))
        .get();

    final transactions = snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data()))
        .toList();

    // Sort manually since we might get data out of order if we don't have a composite index
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<List<model.Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _getCollection(userId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final transactions = snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data()))
        .toList();

    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<void> addTransaction(model.Transaction transaction) async {
    await _getCollection(transaction.userId)
        .doc(transaction.id)
        .set({
          ...transaction.toJson(),
          'date': Timestamp.fromDate(transaction.date),
          'createdAt': transaction.createdAt != null
              ? Timestamp.fromDate(transaction.createdAt!)
              : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateTransaction(model.Transaction transaction) async {
    await _getCollection(transaction.userId)
        .doc(transaction.id)
        .update({
          ...transaction.toJson(),
          'date': Timestamp.fromDate(transaction.date),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> deleteTransaction(String transactionId, String userId) async {
    await _getCollection(userId).doc(transactionId).delete();
  }

  // Workaround: Overload or use a different strategy.
  // Actually, let's check the interface definition.

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
    final snapshot = await _getCollection(userId)
        .where('date', isLessThan: Timestamp.fromDate(date))
        .get();

    int deletedCount = 0;
    // Chunk into batches of 500
    for (var i = 0; i < snapshot.docs.length; i += 500) {
      final chunk = snapshot.docs.sublist(i, i + 500 > snapshot.docs.length ? snapshot.docs.length : i + 500);
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      deletedCount += chunk.length;
    }

    return deletedCount;
  }

  @override
  Future<int> getTransactionCount(String userId) async {
    final snapshot = await _getCollection(userId).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> deleteAllUserTransactions(String userId) async {
    final snapshot = await _getCollection(userId).get();

    for (var i = 0; i < snapshot.docs.length; i += 500) {
      final chunk = snapshot.docs.sublist(i, i + 500 > snapshot.docs.length ? snapshot.docs.length : i + 500);
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
