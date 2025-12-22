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
  /// GÜVENLİK GÜNCELLEMESİ: Hedef hesapta veri varsa KESİNLİKLE yazmaz.
  Future<void> migrateLocalToFirebase(String targetUserId, String sourceUserId) async {
    print('Starting migration check from $sourceUserId to $targetUserId');

    final firebaseSettingsRepo = FirebaseUserSettingsRepository();

    // 🔴 1. ADIM: HEDEF HESAP KONTROLÜ (Check Remote Existence)
    // Eğer hedef hesapta (targetUserId) zaten UserSettings varsa, bu eski bir kullanıcıdır.
    // ONUN VERİSİNİ EZMEMELİYİZ. Migration'ı iptal et.
    try {
      final existingRemoteSettings = await firebaseSettingsRepo.getUserSettings(targetUserId);
      if (existingRemoteSettings != null) {
        print('⚠️ CRITICAL: Target user already has data (Balance: ${existingRemoteSettings.currentBalance}).');
        print('🛑 Migration ABORTED to prevent data loss. Keeping existing account data.');
        return; // Fonksiyondan çık, yazma yapma!
      }
    } catch (e) {
      print('⚠️ Error checking remote data: $e');
      // Bağlantı hatası varsa risk almamak için yine durabiliriz veya devam edebiliriz.
      // Güvenli olan durmaktır.
      print('🛑 Migration ABORTED due to connection error (Safety First).');
      return;
    }

    // Buraya geldiysek hedef hesap BOŞ demektir. Güvenle taşıyabiliriz.
    print('✅ Target account is empty. Proceeding with migration...');

    final errors = <Object>[];

    // 2. Migrate User Settings
    try {
      final localSettingsRepo = LocalUserSettingsRepository();
      final settings = await localSettingsRepo.getUserSettings(sourceUserId);

      if (settings != null) {
        final newSettings = settings.copyWith(userId: targetUserId);
        // Repo zaten yukarıda tanımlı
        await firebaseSettingsRepo.saveUserSettings(newSettings);
        print('Migrated User Settings');
      }
    } catch (e) {
      print('Error migrating settings: $e');
      errors.add(e);
    }

    // 3. Migrate Transactions
    try {
      final localTxRepo = LocalTransactionRepository();
      final transactions = await localTxRepo.getTransactions(sourceUserId);

      if (transactions.isNotEmpty) {
        final firebaseTxRepo = FirebaseTransactionRepository();
        for (final tx in transactions) {
          final newTx = tx.copyWith(userId: targetUserId);
          await firebaseTxRepo.addTransaction(newTx);
        }
        print('Migrated ${transactions.length} transactions');
      }
    } catch (e) {
      print('Error migrating transactions: $e');
      errors.add(e);
    }

    // 4. Migrate Savings Goals
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

    // 5. Migrate Subscriptions
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

    // 6. Migrate Monthly Summaries
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
      // Hata varsa bile kısmi veri taşındı
      print('Migration completed with ${errors.length} error(s): $errors');
    } else {
      print('Migration completed successfully.');
    }

    // ❌ DELETE REMOVED: Yerel veriyi silmiyoruz.
  }
}

final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  return DataMigrationService(ref);
});