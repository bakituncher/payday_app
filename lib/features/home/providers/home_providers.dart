/// Home screen state and providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/models/transaction.dart';
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

  // Use DateCycleService to calculate cycle boundaries consistently
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final nextPayday = DateTime(
    settings.nextPayday.year,
    settings.nextPayday.month,
    settings.nextPayday.day,
  );

  // Calculate the start of current pay cycle
  DateTime cycleStart;

  // If payday is today or in the future, calculate when the cycle started
  if (nextPayday.isAfter(today) || nextPayday.isAtSameMomentAs(today)) {
    cycleStart = _getPreviousPayday(nextPayday, settings.payCycle);
  } else {
    // Payday has passed, this shouldn't happen as userSettingsProvider should update it
    // But as a fallback, calculate the next payday and get its cycle start
    final actualNextPayday = DateCycleService.calculateNextPayday(
      settings.nextPayday,
      settings.payCycle,
    );
    cycleStart = _getPreviousPayday(actualNextPayday, settings.payCycle);
  }

  return repository.getTransactionsForCurrentCycle(userId, cycleStart);
});

/// Get the previous payday (start of current cycle) from next payday
DateTime _getPreviousPayday(DateTime nextPayday, String payCycle) {
  switch (payCycle) {
    case 'Weekly':
      return nextPayday.subtract(const Duration(days: 7));
    case 'Bi-Weekly':
    case 'Fortnightly':
      return nextPayday.subtract(const Duration(days: 14));
    case 'Monthly':
      return _subtractOneMonth(nextPayday);
    default:
      return _subtractOneMonth(nextPayday);
  }
}

/// Subtract one month from a date, handling edge cases
DateTime _subtractOneMonth(DateTime date) {
  int year = date.year;
  int month = date.month - 1;
  int day = date.day;

  // Handle year rollover
  if (month < 1) {
    month = 12;
    year--;
  }

  // Get the last day of the previous month
  final lastDayOfPrevMonth = DateTime(year, month + 1, 0).day;

  // If the day doesn't exist in previous month, use the last day
  if (day > lastDayOfPrevMonth) {
    day = lastDayOfPrevMonth;
  }


  return DateTime(year, month, day);
}

/// Total Expenses for Current Cycle Provider
final totalExpensesProvider = FutureProvider<double>((ref) async {
  final transactions = await ref.watch(currentCycleTransactionsProvider.future);
  return transactions
      .where((t) => t.isExpense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Daily Allowable Spend Provider
final dailyAllowableSpendProvider = FutureProvider<double>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  final totalExpenses = await ref.watch(totalExpensesProvider.future);

  if (settings == null) return 0.0;

  // Protect against invalid income
  if (settings.incomeAmount <= 0) return 0.0;

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

  final remainingBudget = settings.incomeAmount - totalExpenses;

  // If over budget, return 0 instead of negative value
  if (remainingBudget <= 0) {
    return 0.0;
  }

  return remainingBudget / daysRemaining;
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

