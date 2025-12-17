/// Repository interface for subscription operations
/// Industry-grade implementation with Firebase support
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/core/models/bill_reminder.dart';

abstract class SubscriptionRepository {
  /// Get all subscriptions for a user
  Future<List<Subscription>> getSubscriptions(String userId);

  /// Get active subscriptions only
  Future<List<Subscription>> getActiveSubscriptions(String userId);

  /// Get subscription by ID
  Future<Subscription?> getSubscription(String subscriptionId);

  /// Add a new subscription
  Future<void> addSubscription(Subscription subscription);

  /// Update a subscription
  Future<void> updateSubscription(Subscription subscription);

  /// Delete a subscription
  Future<void> deleteSubscription(String subscriptionId, String userId);

  /// Cancel a subscription (soft delete)
  Future<void> cancelSubscription(String subscriptionId, String userId);

  /// Pause a subscription
  Future<void> pauseSubscription(String subscriptionId, String userId);

  /// Resume a paused subscription
  Future<void> resumeSubscription(String subscriptionId, String userId);

  /// Get subscriptions due within specified days
  Future<List<Subscription>> getSubscriptionsDueSoon(String userId, int days);

  /// Get total monthly subscription cost
  Future<double> getTotalMonthlyCost(String userId);

  /// Get total yearly subscription cost
  Future<double> getTotalYearlyCost(String userId);

  /// Get subscriptions by category
  Future<List<Subscription>> getSubscriptionsByCategory(
    String userId,
    SubscriptionCategory category,
  );

  /// Get subscription spending breakdown by category
  Future<Map<SubscriptionCategory, double>> getSpendingByCategory(String userId);

  /// Stream of subscriptions (real-time updates)
  Stream<List<Subscription>> subscriptionsStream(String userId);

  // Bill Reminders
  /// Get upcoming bill reminders
  Future<List<BillReminder>> getUpcomingReminders(String userId, int days);

  /// Get all reminders for a user
  Future<List<BillReminder>> getReminders(String userId);

  /// Create a bill reminder
  Future<void> createReminder(BillReminder reminder);

  /// Update reminder status
  Future<void> updateReminderStatus(String reminderId, ReminderStatus status);

  /// Dismiss a reminder
  Future<void> dismissReminder(String reminderId);

  /// Snooze a reminder
  Future<void> snoozeReminder(String reminderId, Duration snoozeDuration);

  /// Generate reminders for upcoming bills
  Future<void> generateUpcomingReminders(String userId);

  // Subscription Analysis
  /// Analyze subscriptions for potential savings
  Future<SubscriptionSummary> analyzeSubscriptions(String userId);

  /// Get unused subscriptions (not accessed in threshold days)
  Future<List<Subscription>> getUnusedSubscriptions(String userId, int thresholdDays);

  /// Mark subscription as used
  Future<void> markSubscriptionUsed(String subscriptionId);
}

