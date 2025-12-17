/// Firebase implementation of MonthlySummaryRepository
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/budget_goal.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';

class FirebaseMonthlySummaryRepository implements MonthlySummaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('monthly_summaries');
  }

  CollectionReference<Map<String, dynamic>> _getBudgetGoalsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('budget_goals');
  }

  @override
  Future<MonthlySummary?> getMonthlySummary(String userId, int year, int month) async {
    final snapshot = await _getCollection(userId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return MonthlySummary.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<List<MonthlySummary>> getYearlySummaries(String userId, int year) async {
    final snapshot = await _getCollection(userId)
        .where('year', isEqualTo: year)
        .get();

    return snapshot.docs.map((d) => MonthlySummary.fromJson(d.data())).toList();
  }

  @override
  Future<List<MonthlySummary>> getRecentSummaries(String userId, int count) async {
    final snapshot = await _getCollection(userId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .limit(count)
        .get();

    return snapshot.docs.map((d) => MonthlySummary.fromJson(d.data())).toList();
  }

  @override
  Future<void> saveMonthlySummary(MonthlySummary summary) async {
    // Assuming summary.id is set, or we construct it
    await _getCollection(summary.userId).doc(summary.id).set(summary.toJson());
  }

  @override
  Future<void> finalizeSummary(String summaryId) async {
     final userId = FirebaseAuth.instance.currentUser?.uid;
     if (userId != null) {
        await _getCollection(userId).doc(summaryId).update({'isFinalized': true});
     }
  }

  @override
  Future<void> recordLeftoverAllocation(LeftoverAllocation allocation) async {
     // This is a sub-collection of monthly_summaries or a field
     // Let's assume field update for now
     final userId = FirebaseAuth.instance.currentUser?.uid;
     if (userId != null) {
        await _getCollection(userId).doc(allocation.summaryId).update({
          'allocations': FieldValue.arrayUnion([allocation.toJson()])
        });
     }
  }

  @override
  Future<List<LeftoverAllocation>> getLeftoverAllocations(String summaryId) async {
     final userId = FirebaseAuth.instance.currentUser?.uid;
     if (userId != null) {
        final doc = await _getCollection(userId).doc(summaryId).get();
        if (doc.exists && doc.data()!.containsKey('allocations')) {
           final list = doc.data()!['allocations'] as List;
           return list.map((e) => LeftoverAllocation.fromJson(e)).toList();
        }
     }
     return [];
  }

  // Budget Goals
  @override
  Future<List<BudgetGoal>> getBudgetGoals(String userId) async {
    final snapshot = await _getBudgetGoalsCollection(userId).get();
    return snapshot.docs.map((d) => BudgetGoal.fromJson(d.data())).toList();
  }

  @override
  Future<BudgetGoal?> getBudgetGoalByCategory(String userId, String categoryId) async {
    final snapshot = await _getBudgetGoalsCollection(userId)
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return BudgetGoal.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<void> saveBudgetGoal(BudgetGoal goal) async {
    await _getBudgetGoalsCollection(goal.userId).doc(goal.id).set(goal.toJson());
  }

  @override
  Future<void> deleteBudgetGoal(String goalId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _getBudgetGoalsCollection(userId).doc(goalId).delete();
    }
  }

  @override
  Future<void> updateBudgetSpent(String goalId, double amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _getBudgetGoalsCollection(userId).doc(goalId).update({'currentAmount': amount});
    }
  }

  @override
  Future<void> resetBudgetGoals(String userId) async {
    final snapshot = await _getBudgetGoalsCollection(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'currentAmount': 0});
    }
    await batch.commit();
  }

  @override
  Future<YearlyStatistics> getYearlyStatistics(String userId, int year) async {
    // Mock implementation for now to satisfy interface
    return YearlyStatistics(
      year: year,
      totalIncome: 0,
      totalExpenses: 0,
      totalSaved: 0,
      averageMonthlyExpenses: 0,
      averageSavingsRate: 0,
      expensesByCategory: {},
      monthsTracked: 0,
      bestMonth: '',
      worstMonth: '',
    );
  }
}
