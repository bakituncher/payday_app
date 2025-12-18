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
      print('💰 Payday has passed! Processing auto-transfers...');

      // Save the new payday first
      await repository.updateNextPayday(userId, calculatedNextPayday);
      settings = settings.copyWith(nextPayday: calculatedNextPayday);

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

  // Calculate the start of current pay cycle
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final payday = DateTime(settings.nextPayday.year, settings.nextPayday.month, settings.nextPayday.day);

  // Get the previous payday (start of current cycle)
  DateTime cycleStart;

  if (payday.isAfter(today) || payday.isAtSameMomentAs(today)) {
    // We're in a cycle before payday, find when it started
    switch (settings.payCycle) {
      case 'Weekly':
        cycleStart = payday.subtract(const Duration(days: 7));
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        cycleStart = payday.subtract(const Duration(days: 14));
        break;
      case 'Monthly':
        // Use proper month calculation - go back exactly one month
        cycleStart = _subtractOneMonth(payday);
        break;
      default:
        // Default to monthly for unknown cycles
        cycleStart = _subtractOneMonth(payday);
    }
  } else {
    // Payday has passed, we need to calculate when the NEXT payday would be
    // and then go back one cycle from that
    DateTime nextPayday;
    switch (settings.payCycle) {
      case 'Weekly':
        // Find next weekly payday
        nextPayday = payday.add(const Duration(days: 7));
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = nextPayday.add(const Duration(days: 7));
        }
        cycleStart = nextPayday.subtract(const Duration(days: 7));
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        // Find next bi-weekly payday
        nextPayday = payday.add(const Duration(days: 14));
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = nextPayday.add(const Duration(days: 14));
        }
        cycleStart = nextPayday.subtract(const Duration(days: 14));
        break;
      case 'Monthly':
        // Find next monthly payday
        nextPayday = _addOneMonth(payday);
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = _addOneMonth(nextPayday);
        }
        cycleStart = _subtractOneMonth(nextPayday);
        break;
      default:
        // Default to monthly
        nextPayday = _addOneMonth(payday);
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = _addOneMonth(nextPayday);
        }
        cycleStart = _subtractOneMonth(nextPayday);
    }
  }

  // Ensure cycleStart is not in the future (safety check)
  if (cycleStart.isAfter(today)) {
    cycleStart = today;
  }

  return repository.getTransactionsForCurrentCycle(userId, cycleStart);
});

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

/// Add one month to a date, handling edge cases
DateTime _addOneMonth(DateTime date) {
  int year = date.year;
  int month = date.month + 1;
  int day = date.day;

  // Handle year rollover
  if (month > 12) {
    month = 1;
    year++;
  }

  // Get the last day of the target month
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;

  // If the day doesn't exist in target month, use the last day
  if (day > lastDayOfMonth) {
    day = lastDayOfMonth;
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
  final payday = DateTime(settings.nextPayday.year, settings.nextPayday.month, settings.nextPayday.day);

  // Calculate days remaining (including today)
  int daysRemaining = payday.difference(today).inDays + 1;

  // If payday has passed or is today
  if (daysRemaining <= 0) {
    // Calculate when the next cycle should start based on pay cycle
    DateTime nextPayday;
    switch (settings.payCycle) {
      case 'Weekly':
        nextPayday = payday.add(const Duration(days: 7));
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = nextPayday.add(const Duration(days: 7));
        }
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        nextPayday = payday.add(const Duration(days: 14));
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = nextPayday.add(const Duration(days: 14));
        }
        break;
      case 'Monthly':
        nextPayday = _addOneMonth(payday);
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = _addOneMonth(nextPayday);
        }
        break;
      default:
        nextPayday = _addOneMonth(payday);
        while (nextPayday.isBefore(today) || nextPayday.isAtSameMomentAs(today)) {
          nextPayday = _addOneMonth(nextPayday);
        }
    }
    daysRemaining = nextPayday.difference(today).inDays + 1;
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
  if (settings.incomeAmount <= 0) {
    return BudgetHealth.unknown;
  }

  final spentPercentage = (totalExpenses / settings.incomeAmount) * 100;

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

