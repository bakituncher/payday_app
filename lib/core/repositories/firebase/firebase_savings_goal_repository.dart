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
    print('🔥 Firebase: Getting savings goals for user: $userId');
    final snapshot = await _getCollection(userId).get();
    print('🔥 Firebase: Found ${snapshot.docs.length} savings goals');
    return snapshot.docs.map((d) => SavingsGoal.fromJson(d.data())).toList();
  }

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals(String userId) {
    print('🔥 Firebase: Starting to watch savings goals for user: $userId');
    return _getCollection(userId).snapshots().map((snapshot) {
      print('🔥 Firebase: Stream update - ${snapshot.docs.length} savings goals');
      return snapshot.docs.map((d) => SavingsGoal.fromJson(d.data())).toList();
    });
  }

  @override
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    print('🔥 Firebase: Adding savings goal - ID: ${goal.id}, User: ${goal.userId}, Name: ${goal.name}');
    try {
      await _getCollection(goal.userId).doc(goal.id).set(goal.toJson());
      print('🔥 Firebase: Savings goal added successfully');
    } catch (e) {
      print('❌ Firebase: Error adding savings goal: $e');
      rethrow;
    }
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
