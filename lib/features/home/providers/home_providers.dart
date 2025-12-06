/// Home screen state and providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/models/user_settings.dart';
import 'package:payday_flutter/core/models/transaction.dart';
import 'package:payday_flutter/core/providers/repository_providers.dart';
import 'package:payday_flutter/core/utils/date_utils.dart' as app_date_utils;

/// User Settings Provider
final userSettingsProvider = FutureProvider<UserSettings?>((ref) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repository.getUserSettings(userId);
});

/// Current Pay Cycle Transactions Provider
final currentCycleTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final settings = await ref.watch(userSettingsProvider.future);

  if (settings == null) return [];

  // Calculate the start of current pay cycle
  final today = DateTime.now();
  final payday = settings.nextPayday;

  // Get the previous payday (start of current cycle)
  DateTime cycleStart;
  if (payday.isAfter(today)) {
    // We're in a cycle, find when it started
    switch (settings.payCycle) {
      case 'Weekly':
        cycleStart = payday.subtract(const Duration(days: 7));
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        cycleStart = payday.subtract(const Duration(days: 14));
        break;
      case 'Monthly':
        cycleStart = DateTime(payday.year, payday.month - 1, payday.day);
        break;
      default:
        cycleStart = payday.subtract(const Duration(days: 30));
    }
  } else {
    cycleStart = payday;
  }

  return repository.getTransactionsForCurrentCycle(userId, cycleStart);
});

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

  final now = DateTime.now();
  final payday = settings.nextPayday;
  final daysRemaining = app_date_utils.DateUtils.daysBetween(now, payday);

  // Avoid division by zero
  if (daysRemaining <= 0) return 0.0;

  final remainingBudget = settings.incomeAmount - totalExpenses;
  return remainingBudget / daysRemaining;
});

/// Budget Health Status Provider
final budgetHealthProvider = FutureProvider<BudgetHealth>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  final totalExpenses = await ref.watch(totalExpensesProvider.future);

  if (settings == null) {
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

