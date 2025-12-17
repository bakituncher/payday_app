/// Firebase implementation of SavingsGoalRepository
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';

class FirebaseSavingsGoalRepository implements SavingsGoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('savings_goals');
  }

  @override
  Future<List<SavingsGoal>> getSavingsGoals(String userId) async {
    final snapshot = await _getCollection(userId).get();
    return snapshot.docs.map((d) => SavingsGoal.fromJson(d.data())).toList();
  }

  @override
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await _getCollection(goal.userId).doc(goal.id).set(goal.toJson());
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await _getCollection(goal.userId).doc(goal.id).update(goal.toJson());
  }

  @override
  Future<void> deleteSavingsGoal(String goalId, String userId) async {
    await _getCollection(userId).doc(goalId).delete();
  }

  @override
  Future<void> addMoneyToGoal(String goalId, double amount, String userId) async {
     // Transaction support recommended
     final doc = _getCollection(userId).doc(goalId);
     await _firestore.runTransaction((transaction) async {
       final snapshot = await transaction.get(doc);
       if (!snapshot.exists) return;
       final goal = SavingsGoal.fromJson(snapshot.data()!);
       final newCurrentAmount = goal.currentAmount + amount;
       transaction.update(doc, {'currentAmount': newCurrentAmount});
     });
  }

  @override
  Future<void> withdrawMoneyFromGoal(String goalId, double amount, String userId) async {
     final doc = _getCollection(userId).doc(goalId);
     await _firestore.runTransaction((transaction) async {
       final snapshot = await transaction.get(doc);
       if (!snapshot.exists) return;
       final goal = SavingsGoal.fromJson(snapshot.data()!);
       final newCurrentAmount = goal.currentAmount - amount;
       if (newCurrentAmount < 0) return; // Or throw error
       transaction.update(doc, {'currentAmount': newCurrentAmount});
     });
  }
}
