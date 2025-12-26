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
    await _getCollection(subscription.userId).doc(subscription.id).set({
      ...subscription.toJson(),
      'nextBillingDate': Timestamp.fromDate(subscription.nextBillingDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _getCollection(subscription.userId).doc(subscription.id).update({
      ...subscription.toJson(),
      'nextBillingDate': Timestamp.fromDate(subscription.nextBillingDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteSubscription(String subscriptionId, String userId) async {
    await _getCollection(userId).doc(subscriptionId).delete();
  }

  @override
  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    // Soft cancel: disable auto-renew; processor will stop billing and mark cancelled at period end.
    await _getCollection(userId).doc(subscriptionId).update({
      'autoRenew': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, String userId) async {
    await _getCollection(userId).doc(subscriptionId).update({
      'status': 'paused',
      'pausedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> resumeSubscription(String subscriptionId, String userId) async {
    // No-op: smart resume handled in notifier to adjust nextBillingDate.
    await _getCollection(userId).doc(subscriptionId).update({
      'status': 'active',
      'pausedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Implementing other required methods with basic logic or throw unimplemented for now if complex
  @override
  Future<List<Subscription>> getActiveSubscriptions(String userId) async {
    final snapshot = await _getCollection(userId)
        .where('status', whereIn: ['active', 'trial'])
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
        .where('status', whereIn: ['active', 'trial'])
        .where('nextBillingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('nextBillingDate', isLessThanOrEqualTo: Timestamp.fromDate(futureDate))
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
    final subscriptions = await getActiveSubscriptions(userId);
    final Map<SubscriptionCategory, double> spending = {};

    for (final sub in subscriptions) {
      spending[sub.category] = (spending[sub.category] ?? 0.0) + sub.monthlyCost;
    }

    return spending;
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

  // Analysis Implementation
  @override
  Future<SubscriptionSummary> analyzeSubscriptions(String userId) async {
    final subscriptions = await getActiveSubscriptions(userId);

    if (subscriptions.isEmpty) {
      return SubscriptionSummary(
        userId: userId,
        totalSubscriptions: 0,
        totalMonthlySpend: 0,
        totalYearlySpend: 0,
        potentialMonthlySavings: 0,
        potentialYearlySavings: 0,
        subscriptionsToReview: 0,
        subscriptionsToCancel: 0,
        spendByCategory: {},
        analyses: [],
        lastAnalyzedAt: DateTime.now(),
      );
    }

    final analyses = <SubscriptionAnalysis>[];
    double potentialMonthlySavings = 0;
    int toReview = 0;
    int toCancel = 0;

    final Map<String, double> spendByCategory = {};

    for (final sub in subscriptions) {
      final categoryName = sub.category.name;
      spendByCategory[categoryName] = (spendByCategory[categoryName] ?? 0) + sub.monthlyCost;

      UsageLevel usageLevel;
      RecommendationType recommendation;
      double savings = 0;
      List<String> reasons = [];
      List<String> alternatives = [];

      // Smart analysis based on subscription characteristics
      if (sub.category == SubscriptionCategory.streaming && sub.monthlyCost > 15) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.review;
        reasons.add('Higher than average streaming cost');
        alternatives.add('Consider ad-supported tier');
        savings = sub.monthlyCost * 0.3;
        toReview++;
      } else if (sub.category == SubscriptionCategory.productivity && sub.monthlyCost > 50) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.downgrade;
        reasons.add('Premium productivity software');
        reasons.add('Check if all features are being used');
        alternatives.add('Consider individual app plans');
        alternatives.add('Look for student/educator discounts');
        savings = sub.monthlyCost * 0.4;
        toReview++;
      } else if (sub.monthlyCost > 30) {
        usageLevel = UsageLevel.medium;
        recommendation = RecommendationType.review;
        reasons.add('Higher cost subscription');
        savings = sub.monthlyCost * 0.2;
        toReview++;
      } else {
        usageLevel = UsageLevel.high;
        recommendation = RecommendationType.keep;
        reasons.add('Good value subscription');
      }

      potentialMonthlySavings += savings;

      analyses.add(SubscriptionAnalysis(
        id: 'analysis_${sub.id}',
        userId: userId,
        subscriptionId: sub.id,
        subscriptionName: sub.name,
        monthlyAmount: sub.monthlyCost,
        usageLevel: usageLevel,
        recommendation: recommendation,
        potentialSavings: savings,
        reasons: reasons,
        alternatives: alternatives,
        usageScore: usageLevel == UsageLevel.high ? 85 : 60,
        analyzedAt: DateTime.now(),
      ));
    }

    return SubscriptionSummary(
      userId: userId,
      totalSubscriptions: subscriptions.length,
      totalMonthlySpend: subscriptions.fold<double>(0, (sum, s) => sum + s.monthlyCost),
      totalYearlySpend: subscriptions.fold<double>(0, (sum, s) => sum + s.yearlyCost),
      potentialMonthlySavings: potentialMonthlySavings,
      potentialYearlySavings: potentialMonthlySavings * 12,
      subscriptionsToReview: toReview,
      subscriptionsToCancel: toCancel,
      spendByCategory: spendByCategory,
      analyses: analyses,
      lastAnalyzedAt: DateTime.now(),
    );
  }
  @override
  Future<List<Subscription>> getUnusedSubscriptions(String userId, int thresholdDays) async => [];
  @override
  Future<void> markSubscriptionUsed(String subscriptionId) async {}

}
