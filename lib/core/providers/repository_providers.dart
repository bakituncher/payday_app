/// Riverpod providers for dependency injection
/// Using Local implementations with SharedPreferences for data persistence
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/repositories/user_settings_repository.dart';
import 'package:payday_flutter/core/repositories/transaction_repository.dart';
import 'package:payday_flutter/core/repositories/savings_goal_repository.dart';
import 'package:payday_flutter/core/repositories/subscription_repository.dart';
import 'package:payday_flutter/core/repositories/monthly_summary_repository.dart';
import 'package:payday_flutter/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday_flutter/core/repositories/local/local_transaction_repository.dart';
import 'package:payday_flutter/core/repositories/local/local_savings_goal_repository.dart';
import 'package:payday_flutter/core/repositories/local/local_subscription_repository.dart';
import 'package:payday_flutter/core/repositories/local/local_monthly_summary_repository.dart';
import 'package:payday_flutter/core/services/notification_service.dart';

/// Repository Providers - Using Local implementations with SharedPreferences
/// Data persists across app restarts

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return LocalUserSettingsRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return LocalTransactionRepository();
});

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return LocalSavingsGoalRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return LocalSubscriptionRepository();
});

final monthlySummaryRepositoryProvider = Provider<MonthlySummaryRepository>((ref) {
  return LocalMonthlySummaryRepository();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

/// Current User ID Provider
/// Uses 'local_user' for local storage - will be replaced with Firebase Auth in production
final currentUserIdProvider = Provider<String>((ref) {
  return 'local_user';
});

