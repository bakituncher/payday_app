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
        .where('date', isGreaterThanOrEqualTo: payCycleStart.toIso8601String())
        .get();

    final transactions = snapshot.docs
        .map((doc) => model.Transaction.fromJson(doc.data()))
        .toList();

    // Sort manually since we might get data out of order if we don't have a composite index
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<void> addTransaction(model.Transaction transaction) async {
    await _getCollection(transaction.userId)
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  @override
  Future<void> updateTransaction(model.Transaction transaction) async {
    await _getCollection(transaction.userId)
        .doc(transaction.id)
        .update(transaction.toJson());
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
        .where('date', isLessThan: date.toIso8601String())
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return snapshot.docs.length;
  }

  @override
  Future<int> getTransactionCount(String userId) async {
    final snapshot = await _getCollection(userId).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> deleteAllUserTransactions(String userId) async {
    final snapshot = await _getCollection(userId).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
