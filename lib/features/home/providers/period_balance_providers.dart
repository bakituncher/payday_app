import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/period_balance.dart';
import 'package:payday/core/models/pay_period.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/date_cycle_service.dart';
import 'package:payday/core/services/period_balance_service.dart';
import 'package:payday/features/home/providers/home_providers.dart';

/// Selected pay period.
/// For now we compute only the current period, but keeping this as a provider
/// makes it easy to add a period picker later (previous periods, calendar).
final selectedPayPeriodProvider = FutureProvider<PayPeriod?>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  if (settings == null) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final normalizedNext = DateTime(settings.nextPayday.year, settings.nextPayday.month, settings.nextPayday.day);
  final nextPayday = (normalizedNext.isAfter(today) || normalizedNext.isAtSameMomentAs(today))
      ? normalizedNext
      : DateCycleService.calculateNextPayday(settings.nextPayday, settings.payCycle);

  return DateCycleService.getCurrentPayPeriod(nextPayday: nextPayday, payCycle: settings.payCycle);
});

/// Period balance computed from ledger.
///
/// Opening balance strategy (safe default):
/// - Use `UserSettings.currentBalance` as *closing* snapshot of the current period.
/// - Derive opening = currentBalance - netChangeInPeriod.
///
/// This lets us show correct period totals without requiring a data migration yet.
final selectedPeriodBalanceProvider = FutureProvider<PeriodBalance?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final settings = await ref.watch(userSettingsProvider.future);
  final period = await ref.watch(selectedPayPeriodProvider.future);

  if (settings == null || period == null) return null;

  final PeriodBalanceService service = ref.watch(periodBalanceServiceProvider);

  // First compute with openingBalance=0 to get netChange.
  final tmp = await service.compute(userId: userId, period: period, openingBalance: 0.0);
  final netChange = tmp.income - tmp.expensesGross + tmp.savingsWithdrawals;

  // Derive opening from snapshot to avoid needing historical periods right now.
  final opening = settings.currentBalance - netChange;

  return service.compute(userId: userId, period: period, openingBalance: opening);
});

