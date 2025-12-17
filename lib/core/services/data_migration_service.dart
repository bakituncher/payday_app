import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/repositories/local/local_transaction_repository.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/core/repositories/local/local_monthly_summary_repository.dart';
import 'package:payday/core/repositories/local/local_savings_goal_repository.dart';
import 'package:payday/core/repositories/local/local_subscription_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_transaction_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_user_settings_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_monthly_summary_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_savings_goal_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_subscription_repository.dart';

import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';

/// Service responsible for migrating data from Local Storage to Firestore
/// This is called when an Anonymous user converts to a Google/Apple account.
class DataMigrationService {
  final Ref ref;

  DataMigrationService(this.ref);

  Future<void> migrateLocalToFirebase(String userId) async {
    print('Starting migration for user: $userId');

    // 1. Migrate User Settings
    try {
      // Direct instantiation to avoid provider state conflict
      final localSettingsRepo = LocalUserSettingsRepository();
      // We read from the "local_user" ID because that's where the anonymous data is stored
      final settings = await localSettingsRepo.getUserSettings('local_user');

      if (settings != null) {
        // Create a copy with the new userId
        final newSettings = settings.copyWith(userId: userId);

        final firebaseSettingsRepo = FirebaseUserSettingsRepository();
        await firebaseSettingsRepo.saveUserSettings(newSettings);
        print('Migrated User Settings');
      }
    } catch (e) {
      print('Error migrating settings: $e');
    }

    // 2. Migrate Transactions
    try {
      final localTxRepo = LocalTransactionRepository();
      final transactions = await localTxRepo.getTransactions('local_user');

      if (transactions.isNotEmpty) {
        final firebaseTxRepo = FirebaseTransactionRepository();
        for (final tx in transactions) {
          final newTx = tx.copyWith(userId: userId);
          await firebaseTxRepo.addTransaction(newTx);
        }
        print('Migrated ${transactions.length} transactions');
      }
    } catch (e) {
      print('Error migrating transactions: $e');
    }

    // 3. Migrate Savings Goals
    try {
      final localSavingsRepo = LocalSavingsGoalRepository();
      final goals = await localSavingsRepo.getSavingsGoals('local_user');

      if (goals.isNotEmpty) {
        final firebaseSavingsRepo = FirebaseSavingsGoalRepository();
        for (final goal in goals) {
          final newGoal = goal.copyWith(userId: userId);
          await firebaseSavingsRepo.addSavingsGoal(newGoal);
        }
        print('Migrated ${goals.length} savings goals');
      }
    } catch (e) {
      print('Error migrating savings goals: $e');
    }

    // 4. Migrate Subscriptions
    try {
      final localSubRepo = LocalSubscriptionRepository();
      final subscriptions = await localSubRepo.getSubscriptions('local_user');

      if (subscriptions.isNotEmpty) {
        final firebaseSubRepo = FirebaseSubscriptionRepository();
        for (final sub in subscriptions) {
          final newSub = sub.copyWith(userId: userId);
          await firebaseSubRepo.addSubscription(newSub);
        }
        print('Migrated ${subscriptions.length} subscriptions');
      }
    } catch (e) {
      print('Error migrating subscriptions: $e');
    }

    // 5. Migrate Monthly Summaries
    try {
      final localSummaryRepo = LocalMonthlySummaryRepository();
      // Note: Local repo doesn't expose getAllSummaries easily in interface but let's assume we fetch meaningful years.
      // Or we iterate current year.
      final now = DateTime.now();
      final summaries = await localSummaryRepo.getSummariesForYear('local_user', now.year);
      // Also check previous year just in case
      final prevSummaries = await localSummaryRepo.getSummariesForYear('local_user', now.year - 1);

      final allSummaries = [...summaries, ...prevSummaries];

      if (allSummaries.isNotEmpty) {
        final firebaseSummaryRepo = FirebaseMonthlySummaryRepository();
        for (final summary in allSummaries) {
          final newSummary = summary.copyWith(userId: userId);
          await firebaseSummaryRepo.saveSummary(newSummary);
        }
        print('Migrated ${allSummaries.length} monthly summaries');
      }
    } catch (e) {
      print('Error migrating monthly summaries: $e');
    }
  }
}

final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  return DataMigrationService(ref);
});
