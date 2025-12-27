/// Riverpod providers for dependency injection
/// Using Local implementations with SharedPreferences for data persistence
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';
import 'package:payday/core/repositories/transaction_repository.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';
import 'package:payday/core/repositories/subscription_repository.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/core/repositories/local/local_transaction_repository.dart';
import 'package:payday/core/repositories/local/local_savings_goal_repository.dart';
import 'package:payday/core/repositories/local/local_subscription_repository.dart';
import 'package:payday/core/repositories/local/local_monthly_summary_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_user_settings_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_transaction_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_savings_goal_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_subscription_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_monthly_summary_repository.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/services/notification_service.dart';
import 'package:payday/core/services/auto_transfer_service.dart';
import 'package:payday/core/services/auto_deposit_service.dart';
import 'package:payday/core/services/transaction_manager_service.dart';
import 'package:payday/core/services/subscription_processor_service.dart';
import 'package:payday/core/services/period_balance_service.dart';

/// Repository Providers - Using Local implementations with SharedPreferences
/// Data persists across app restarts

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;

  // If user is authenticated (not null and not in guest mode), use Firebase
  if (user != null) {
    return FirebaseUserSettingsRepository();
  }
  return LocalUserSettingsRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user != null) {
    return FirebaseTransactionRepository();
  }
  return LocalTransactionRepository();
});

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user != null) {
    return FirebaseSavingsGoalRepository();
  }
  return LocalSavingsGoalRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user != null) {
    return FirebaseSubscriptionRepository();
  }
  return LocalSubscriptionRepository();
});

final monthlySummaryRepositoryProvider = Provider<MonthlySummaryRepository>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user != null) {
    return FirebaseMonthlySummaryRepository();
  }
  return LocalMonthlySummaryRepository();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Current User ID Provider
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  // If user is logged in, use their UID.
  // If no user (guest mode), use 'guest_user' as the local ID
  return user?.uid ?? 'guest_user';
});

/// Transaction Manager Service Provider
/// Merkezi işlem yöneticisi - Tüm finansal işlemler bu servisi kullanmalı
final transactionManagerServiceProvider = Provider<TransactionManagerService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final userSettingsRepository = ref.watch(userSettingsRepositoryProvider);
  return TransactionManagerService(
    transactionRepo: transactionRepository,
    settingsRepo: userSettingsRepository,
  );
});

/// Auto Transfer Service Provider (UPDATED)
/// Artık TransactionManagerService kullanıyor - Bakiye otomatik güncelleniyor
final autoTransferServiceProvider = Provider<AutoTransferService>((ref) {
  final savingsGoalRepository = ref.watch(savingsGoalRepositoryProvider);
  final transactionManager = ref.watch(transactionManagerServiceProvider);
  return AutoTransferService(
    savingsGoalRepository: savingsGoalRepository,
    transactionManager: transactionManager,
  );
});

/// Subscription Processor Service Provider
/// Abonelikleri otomatik işler - Uygulama açılışında çağrılmalı
final subscriptionProcessorServiceProvider = Provider<SubscriptionProcessorService>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final transactionManager = ref.watch(transactionManagerServiceProvider);
  return SubscriptionProcessorService(
    subscriptionRepo: subscriptionRepository,
    transactionManager: transactionManager,
  );
});

final periodBalanceServiceProvider = Provider<PeriodBalanceService>((ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  return PeriodBalanceService(transactionRepository: txRepo);
});

/// Auto Deposit Service Provider
/// Handles automatic salary deposits on payday (Piggy Bank / Pool system)
final autoDepositServiceProvider = Provider<AutoDepositService>((ref) {
  final settingsRepo = ref.watch(userSettingsRepositoryProvider);
  final transactionManager = ref.watch(transactionManagerServiceProvider);
  return AutoDepositService(
    settingsRepo: settingsRepo,
    transactionManager: transactionManager,
  );
});
