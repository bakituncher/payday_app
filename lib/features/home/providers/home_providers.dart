/// Home screen state and providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/pay_period.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/date_cycle_service.dart';

/// User Settings Provider - Auto-updates payday if it has passed
final userSettingsProvider = FutureProvider<UserSettings?>((ref) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  var settings = await repository.getUserSettings(userId);

  if (settings != null) {
    // Check if payday has passed and needs updating
    final calculatedNextPayday = DateCycleService.calculateNextPayday(
      settings.nextPayday,
      settings.payCycle,
    );

    // If payday was updated, save the new date AND process auto-transfers
    if (calculatedNextPayday != settings.nextPayday) {
      print('💰 Payday has passed! Processing payday actions...');

      // Add income to current balance
      final newBalance = settings.currentBalance + settings.incomeAmount;

      // Update both payday and balance
      final updatedSettings = settings.copyWith(
        nextPayday: calculatedNextPayday,
        currentBalance: newBalance,
        updatedAt: DateTime.now(),
      );

      await repository.saveUserSettings(updatedSettings);
      settings = updatedSettings;

      print('💰 Income added to balance: ${settings.incomeAmount} -> New balance: $newBalance');

      // Process auto-transfers to savings goals
      try {
        final autoTransferService = ref.read(autoTransferServiceProvider);
        final result = await autoTransferService.processAutoTransfers(userId);

        if (result.success && result.transferCount > 0) {
          print('💰 Auto-transfers completed: ${result.transferCount} goals, Total: ${result.totalAmount}');
        }
      } catch (e) {
        print('❌ Error processing auto-transfers: $e');
        // Don't fail the whole provider if auto-transfers fail
      }

      // Process subscription payments (NEW)
      try {
        final subscriptionProcessor = ref.read(subscriptionProcessorServiceProvider);
        final result = await subscriptionProcessor.checkAndProcessDueSubscriptions(
          userId,
          processHistorical: true, // Geçmiş ödemeleri de işle
        );

        if (result.success && result.processedCount > 0) {
          print('💳 Subscription payments processed: ${result.processedCount} subscriptions, Total: ${result.totalAmount}');
        }
      } catch (e) {
        print('❌ Error processing subscriptions: $e');
        // Don't fail the whole provider if subscription processing fails
      }

      // CRITICAL FIX: Stale Data Sorunu
      // Transferler ve abonelikler bakiyeyi değiştirdi (veritabanında).
      // Elimizdeki 'settings' değişkeni hala sadece maaşın yattığı hali (transferler ve ödemeler düşülmemiş).
      // Veritabanından son güncel halini çekip UI'a doğru bakiyeyi göstermeliyiz.
      print('🔄 Refreshing settings after payday operations...');
      final freshSettings = await repository.getUserSettings(userId);
      if (freshSettings != null) {
        settings = freshSettings;
        print('✅ Settings refreshed - Current balance: ${settings.currentBalance}');
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

  // Protect against division by zero
  if (settings.currentBalance <= 0) {
    return BudgetHealth.unknown;
  }

  final spentPercentage = (totalExpenses / settings.currentBalance) * 100;

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
