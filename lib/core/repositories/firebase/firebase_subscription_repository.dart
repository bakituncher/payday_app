/// Firebase implementation of SubscriptionRepository
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/core/models/bill_reminder.dart';
import 'package:payday/core/repositories/subscription_repository.dart';

class FirebaseSubscriptionRepository implements SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('subscriptions');
  }

  @override
  Future<List<Subscription>> getSubscriptions(String userId) async {
    final snapshot = await _getCollection(userId).get();
    return snapshot.docs.map((d) => Subscription.fromJson(d.data())).toList();
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    await _getCollection(subscription.userId).doc(subscription.id).set(subscription.toJson());
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _getCollection(subscription.userId).doc(subscription.id).update(subscription.toJson());
  }

  @override
  Future<void> deleteSubscription(String subscriptionId, String userId) async {
    await _getCollection(userId).doc(subscriptionId).delete();
  }

  @override
  Future<void> cancelSubscription(String subscriptionId, String userId) async {
     // Update status to cancelled and set cancelledAt timestamp
     await _getCollection(userId).doc(subscriptionId).update({
       'status': 'cancelled',
       'cancelledAt': FieldValue.serverTimestamp(),
     });
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, String userId) async {
      await _getCollection(userId).doc(subscriptionId).update({'status': 'paused'});
  }

  @override
  Future<void> resumeSubscription(String subscriptionId, String userId) async {
      await _getCollection(userId).doc(subscriptionId).update({'status': 'active'});
  }

  // Implementing other required methods with basic logic or throw unimplemented for now if complex
  @override
  Future<List<Subscription>> getActiveSubscriptions(String userId) async {
    final snapshot = await _getCollection(userId)
        .where('status', isEqualTo: 'active')
        .get();
    return snapshot.docs.map((d) => Subscription.fromJson(d.data())).toList();
  }

  @override
  Future<Subscription?> getSubscription(String subscriptionId) async {
     // Requires userId. Since interface doesn't have it, we try to use current user.
     final user = FirebaseAuth.instance.currentUser;
     if (user == null) return null;

     final doc = await _getCollection(user.uid).doc(subscriptionId).get();
     if (doc.exists && doc.data() != null) {
       return Subscription.fromJson(doc.data()!);
     }
     return null;
  }

  @override
  Future<List<Subscription>> getSubscriptionsDueSoon(String userId, int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    final snapshot = await _getCollection(userId)
        .where('status', isEqualTo: 'active')
        .where('nextBillingDate', isGreaterThanOrEqualTo: now)
        .where('nextBillingDate', isLessThanOrEqualTo: futureDate)
        .orderBy('nextBillingDate')
        .get();

    return snapshot.docs.map((d) => Subscription.fromJson(d.data())).toList();
  }

  @override
  Future<double> getTotalMonthlyCost(String userId) async {
      final subs = await getActiveSubscriptions(userId);
      return subs.fold<double>(0.0, (sum, sub) => sum + sub.amount);
  }

  @override
  Future<double> getTotalYearlyCost(String userId) async {
      final subs = await getActiveSubscriptions(userId);
      return subs.fold<double>(0.0, (sum, sub) => sum + (sub.amount * 12));
  }

  @override
  Future<List<Subscription>> getSubscriptionsByCategory(String userId, SubscriptionCategory category) async {
    final snapshot = await _getCollection(userId)
        .where('category', isEqualTo: category.name)
        .get();

    return snapshot.docs.map((d) => Subscription.fromJson(d.data())).toList();
  }

  @override
  Future<Map<SubscriptionCategory, double>> getSpendingByCategory(String userId) async {
      return {};
  }

  @override
  Stream<List<Subscription>> subscriptionsStream(String userId) {
      return _getCollection(userId).snapshots().map((s) => s.docs.map((d) => Subscription.fromJson(d.data())).toList());
  }

  // Bill Reminders Stubs
  @override
  Future<List<BillReminder>> getUpcomingReminders(String userId, int days) async => [];
  @override
  Future<List<BillReminder>> getReminders(String userId) async => [];
  @override
  Future<void> createReminder(BillReminder reminder) async {}
  @override
  Future<void> updateReminderStatus(String reminderId, ReminderStatus status) async {}
  @override
  Future<void> dismissReminder(String reminderId) async {}
  @override
  Future<void> snoozeReminder(String reminderId, Duration snoozeDuration) async {}
  @override
  Future<void> generateUpcomingReminders(String userId) async {}

  // Analysis Stubs
  @override
  Future<SubscriptionSummary> analyzeSubscriptions(String userId) async {
    // Return empty/dummy summary
    return SubscriptionSummary(
      userId: userId,
      totalSubscriptions: 0,
      totalMonthlySpend: 0.0,
      totalYearlySpend: 0.0,
      potentialMonthlySavings: 0.0,
      potentialYearlySavings: 0.0,
      subscriptionsToReview: 0,
      subscriptionsToCancel: 0,
    );
  }
  @override
  Future<List<Subscription>> getUnusedSubscriptions(String userId, int thresholdDays) async => [];
  @override
  Future<void> markSubscriptionUsed(String subscriptionId) async {}

}
