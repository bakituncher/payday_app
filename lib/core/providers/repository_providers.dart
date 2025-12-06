/// Riverpod providers for dependency injection
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/repositories/user_settings_repository.dart';
import 'package:payday_flutter/core/repositories/transaction_repository.dart';
import 'package:payday_flutter/core/repositories/savings_goal_repository.dart';
import 'package:payday_flutter/core/repositories/subscription_repository.dart';
import 'package:payday_flutter/core/repositories/mock/mock_user_settings_repository.dart';
import 'package:payday_flutter/core/repositories/mock/mock_transaction_repository.dart';
import 'package:payday_flutter/core/repositories/mock/mock_savings_goal_repository.dart';
import 'package:payday_flutter/core/repositories/mock/mock_subscription_repository.dart';
import 'package:payday_flutter/core/services/notification_service.dart';

/// Repository Providers - Using mock implementations for now
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return MockUserSettingsRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return MockTransactionRepository();
});

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return MockSavingsGoalRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return MockSubscriptionRepository();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

/// Current User ID Provider (mock for now)
final currentUserIdProvider = Provider<String>((ref) {
  return 'mock-user-123'; // In production, this would come from Firebase Auth
});

