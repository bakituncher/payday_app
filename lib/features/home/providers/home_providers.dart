/// Home screen state and providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/pay_period.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/date_cycle_service.dart';

// ✅ EKLENEN IMPORTLAR: Migration ve Local kontrolü için gerekli
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/core/services/data_migration_service.dart';

/// User Settings Provider - Auto-deposits salary on payday using Pool system
///
/// This provider uses AutoDepositService to:
/// 1. Check if payday has arrived
/// 2. Create an income transaction (Payday Deposit)
/// 3. Update the Pool balance via TransactionManagerService
/// 4. Advance nextPayday to next cycle
/// 5. Track lastAutoDepositDate to prevent duplicates
final userSettingsProvider = FutureProvider<UserSettings?>((ref) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  // 1. Önce mevcut depodan (Firebase veya Local) veriyi çekmeyi dene
  var settings = await repository.getUserSettings(userId);

  // 🔴 KRİTİK DÜZELTME BAŞLANGICI 🔴
  // Eğer kullanıcı giriş yapmışsa (Firebase kullanıyorsa) ama verisi NULL geliyorsa (yani Firebase boşsa),
  // Cihazda (Local) daha önceden kalmış veri var mı diye kontrol et.
  if (settings == null) {
    final user = ref.read(currentUserProvider).asData?.value;

    // Kullanıcı Anonymous DEĞİLSE (yani Google/Apple ile girmişse)
    if (user != null && !user.isAnonymous) {
      try {
        // Local repoyu manuel olarak çağır
        final localRepo = LocalUserSettingsRepository();
        // ID önemsizdir, LocalRepo zaten tek bir 'user_currency' anahtarına bakar
        final localSettings = await localRepo.getUserSettings('check_local');

        if (localSettings != null) {
          print('📥 Authentication sonrası Local veri bulundu. Firebase\'e taşınıyor... (Migration)');

          // Migration servisini bul ve çalıştır
          final migrationService = ref.read(dataMigrationServiceProvider);

          // Local'deki veriyi (localSettings.userId) -> Firebase'deki yeni ID'ye (userId) taşı
          await migrationService.migrateLocalToFirebase(userId, localSettings.userId);

          // Taşıma bitti, şimdi Firebase'den tekrar çek (Artık veri gelmeli)
          settings = await repository.getUserSettings(userId);

          if (settings != null) {
            print('✅ Migration başarılı! Veriler kurtarıldı. Bakiye: ${settings.currentBalance}');
          }
        }
      } catch (e) {
        print('❌ Otomatik migration sırasında hata: $e');
        // Hata olsa bile app çökmesin, null dönerse onboarding açılır.
      }
    }
  }
  // 🔴 KRİTİK DÜZELTME BİTİŞİ 🔴

  if (settings != null) {
    // Process automatic payday deposit using AutoDepositService
    final autoDepositService = ref.read(autoDepositServiceProvider);
    final depositResult = await autoDepositService.processPaydayDeposit(userId);

    if (depositResult.depositMade) {
      print('💰 Payday deposit processed: ${depositResult.depositAmount}');
    }

    // Refresh settings after deposit (balance may have changed)
    settings = await repository.getUserSettings(userId);

    if (settings != null) {
      // Process auto-transfers to savings goals
      try {
        final autoTransferService = ref.read(autoTransferServiceProvider);
        final result = await autoTransferService.processAutoTransfers(userId);

        if (result.success && result.transferCount > 0) {
          print('💰 Auto-transfers completed: ${result.transferCount} goals, Total: ${result.totalAmount}');
        }
      } catch (e) {
        print('❌ Error processing auto-transfers: $e');
      }

      // Process subscription payments
      try {
        final subscriptionProcessor = ref.read(subscriptionProcessorServiceProvider);
        final result = await subscriptionProcessor.checkAndProcessDueSubscriptions(
          userId,
          processHistorical: true,
        );

        if (result.success && result.processedCount > 0) {
          print('💳 Subscription payments processed: ${result.processedCount} subscriptions, Total: ${result.totalAmount}');
        }
      } catch (e) {
        print('❌ Error processing subscriptions: $e');
      }

      // Refresh settings after payday operations (auto transfers/subscriptions may change balance)
      // Sadece değişiklik olduysa logla, gereksiz çağrıdan kaçınmak için
      // (Burada repository zaten cacheliyor olabilir ama Firestore ise maliyet olabilir)
      // Ancak Balance değiştiği için mecburuz.
      final freshSettings = await repository.getUserSettings(userId);
      if (freshSettings != null) {
        settings = freshSettings;
      }
    }
  }

  return settings;
});

/// Current Pay Cycle Transactions Provider
final currentCycleTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final settings = await ref.watch(userSettingsProvider.future);

  if (settings == null) return [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final normalizedNextPayday = DateTime(
    settings.nextPayday.year,
    settings.nextPayday.month,
    settings.nextPayday.day,
  );

  final nextPayday = (normalizedNextPayday.isAfter(today) || normalizedNextPayday.isAtSameMomentAs(today))
      ? normalizedNextPayday
      : DateCycleService.calculateNextPayday(settings.nextPayday, settings.payCycle);

  final PayPeriod period = DateCycleService.getCurrentPayPeriod(
    nextPayday: nextPayday,
    payCycle: settings.payCycle,
  );

  return repository.getTransactionsForCurrentCycle(userId, period.start);
});

/// Total Expenses for Current Cycle Provider (DÜZELTİLMİŞ VERSİYON)
final totalExpensesProvider = FutureProvider<double>((ref) async {
  final transactions = await ref.watch(currentCycleTransactionsProvider.future);

  // 1. Toplam Harcamaları Hesapla (Cüzdandan çıkanlar)
  final grossExpenses = transactions
      .where((t) => t.isExpense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  // 2. Tasarruftan Geri Çekilenleri Hesapla (Bütçeye geri dönenler)
  // Mantık: Eğer bir işlem 'Gelir' ise (!isExpense) VE bir tasarruf hedefine bağlıysa (relatedGoalId != null),
  // bu işlem aslında bir harcama iadesidir.
  final savingsWithdrawals = transactions
      .where((t) => !t.isExpense && t.relatedGoalId != null)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  // 3. Net Harcamayı Bul (Toplam Harcama - Geri Çekilenler)
  // Örnek: 100 TL yatırdın (Harcama: 100). 20 TL geri çektin (İade: 20). Net Harcama: 80.
  double netExpenses = grossExpenses - savingsWithdrawals;

  // Negatif çıkarsa 0 döndür (Çok nadir durumlarda)
  return netExpenses < 0 ? 0.0 : netExpenses;
});

/// Daily Allowable Spend Provider
final dailyAllowableSpendProvider = FutureProvider<double>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);

  if (settings == null) return 0.0;

  // Protect against invalid balance
  if (settings.currentBalance <= 0) return 0.0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final nextPayday = DateTime(
    settings.nextPayday.year,
    settings.nextPayday.month,
    settings.nextPayday.day,
  );

  // Calculate days remaining (including today)
  int daysRemaining = nextPayday.difference(today).inDays + 1;

  // If payday has passed, recalculate (shouldn't happen as userSettingsProvider auto-updates)
  if (daysRemaining <= 0) {
    final actualNextPayday = DateCycleService.calculateNextPayday(
      settings.nextPayday,
      settings.payCycle,
    );
    daysRemaining = actualNextPayday.difference(today).inDays + 1;
  }

  // Ensure at least 1 day to prevent division by zero
  if (daysRemaining < 1) {
    daysRemaining = 1;
  }

  // Simply divide current balance by remaining days
  // No need to subtract expenses since currentBalance is already up-to-date
  return settings.currentBalance / daysRemaining;
});

/// Budget Health Status Provider
final budgetHealthProvider = FutureProvider<BudgetHealth>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  final totalExpenses = await ref.watch(totalExpensesProvider.future);

  if (settings == null) {
    return BudgetHealth.unknown;
  }

  // currentBalance net bakiye. Toplam başlangıç bütçesi = net bakiye + harcama.
  final totalBudget = settings.currentBalance + totalExpenses;

  // Protect against invalid totals
  if (totalBudget <= 0) {
    return BudgetHealth.unknown;
  }

  final spentPercentage = (totalExpenses / totalBudget) * 100;

  if (spentPercentage < 50) {
    return BudgetHealth.excellent;
  } else if (spentPercentage < 75) {
    return BudgetHealth.good;
  } else if (spentPercentage < 90) {
    return BudgetHealth.warning;
  } else {
    return BudgetHealth.danger;
  }
});

enum BudgetHealth {
  excellent,
  good,
  warning,
  danger,
  unknown,
}