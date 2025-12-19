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

/// Service responsible for migrating data from Local Storage to Firestore
/// This is called when an Anonymous user converts to a Google/Apple account.
class DataMigrationService {
  final Ref ref;

  DataMigrationService(this.ref);

  /// Local (sourceUserId) verilerini Firestore'a (targetUserId) taşır.
  /// NOT: Bu işlem mümkün olduğunca "idempotent" olmalı (aynı migration iki kez koşsa bile veri bozulmamalı).
  Future<void> migrateLocalToFirebase(String targetUserId, String sourceUserId) async {
    print('Starting migration from $sourceUserId to $targetUserId');

    final errors = <Object>[];

    // 1. Migrate User Settings
    try {
      final localSettingsRepo = LocalUserSettingsRepository();
      final settings = await localSettingsRepo.getUserSettings(sourceUserId);

      if (settings != null) {
        final newSettings = settings.copyWith(userId: targetUserId);
        final firebaseSettingsRepo = FirebaseUserSettingsRepository();
        await firebaseSettingsRepo.saveUserSettings(newSettings);
        print('Migrated User Settings');
      }
    } catch (e) {
      print('Error migrating settings: $e');
      errors.add(e);
    }

    // 2. Migrate Transactions
    try {
      final localTxRepo = LocalTransactionRepository();
      final transactions = await localTxRepo.getTransactions(sourceUserId);

      if (transactions.isNotEmpty) {
        final firebaseTxRepo = FirebaseTransactionRepository();
        for (final tx in transactions) {
          final newTx = tx.copyWith(userId: targetUserId);
          // Firebase repo'nun id stratejisi tx.id'yi koruyorsa bu upsert gibi davranır.
          // Korunmuyorsa bile en azından doğru userId ile yazılmış olur.
          await firebaseTxRepo.addTransaction(newTx);
        }
        print('Migrated ${transactions.length} transactions');
      }
    } catch (e) {
      print('Error migrating transactions: $e');
      errors.add(e);
    }

    // 3. Migrate Savings Goals
    try {
      final localSavingsRepo = LocalSavingsGoalRepository();
      final goals = await localSavingsRepo.getSavingsGoals(sourceUserId);

      if (goals.isNotEmpty) {
        final firebaseSavingsRepo = FirebaseSavingsGoalRepository();
        for (final goal in goals) {
          final newGoal = goal.copyWith(userId: targetUserId);
          await firebaseSavingsRepo.addSavingsGoal(newGoal);
        }
        print('Migrated ${goals.length} savings goals');
      }
    } catch (e) {
      print('Error migrating savings goals: $e');
      errors.add(e);
    }

    // 4. Migrate Subscriptions
    try {
      final localSubRepo = LocalSubscriptionRepository();
      final subscriptions = await localSubRepo.getSubscriptions(sourceUserId);

      if (subscriptions.isNotEmpty) {
        final firebaseSubRepo = FirebaseSubscriptionRepository();
        for (final sub in subscriptions) {
          final newSub = sub.copyWith(userId: targetUserId);
          await firebaseSubRepo.addSubscription(newSub);
        }
        print('Migrated ${subscriptions.length} subscriptions');
      }
    } catch (e) {
      print('Error migrating subscriptions: $e');
      errors.add(e);
    }

    // 5. Migrate Monthly Summaries
    try {
      final localSummaryRepo = LocalMonthlySummaryRepository();
      final now = DateTime.now();
      final summaries = await localSummaryRepo.getSummariesForYear(sourceUserId, now.year);
      final prevSummaries = await localSummaryRepo.getSummariesForYear(sourceUserId, now.year - 1);

      final allSummaries = [...summaries, ...prevSummaries];

      if (allSummaries.isNotEmpty) {
        final firebaseSummaryRepo = FirebaseMonthlySummaryRepository();
        for (final summary in allSummaries) {
          final newSummary = summary.copyWith(userId: targetUserId);
          await firebaseSummaryRepo.saveMonthlySummary(newSummary);
        }
        print('Migrated ${allSummaries.length} monthly summaries');
      }
    } catch (e) {
      print('Error migrating monthly summaries: $e');
      errors.add(e);
    }

    if (errors.isNotEmpty) {
      throw Exception('Migration completed with ${errors.length} error(s): $errors');
    }

    // Migration başarılıysa, local kaynak veriyi temizleyip yeniden kopyalama/çakışma riskini azalt.
    // Şu an LocalUserSettingsRepository için toplu temizlik API'si var.
    // Diğer local repository'lerde toplu silme metodu yok; bunu ileride ekleyebiliriz.
    try {
      await LocalUserSettingsRepository().deleteAllUserData(sourceUserId);
    } catch (_) {}
  }
}

final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  return DataMigrationService(ref);
});
