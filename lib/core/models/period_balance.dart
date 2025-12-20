import 'package:freezed_annotation/freezed_annotation.dart';

part 'period_balance.freezed.dart';

@freezed
class PeriodBalance with _$PeriodBalance {
  const PeriodBalance._();

  const factory PeriodBalance({
    required DateTime periodStart,
    required DateTime periodEnd,
    required double openingBalance,
    required double income,
    required double expensesGross,
    required double savingsWithdrawals,
    required double expensesNet,
    required double closingBalance,
  }) = _PeriodBalance;
}

