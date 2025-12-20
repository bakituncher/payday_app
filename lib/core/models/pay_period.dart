import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_period.freezed.dart';

/// Simple value object for a pay period (start inclusive, end exclusive)
@freezed
class PayPeriod with _$PayPeriod {
  const PayPeriod._();

  const factory PayPeriod({
    required DateTime start,
    required DateTime end,
  }) = _PayPeriod;

  int get days => end.difference(start).inDays;

  bool contains(DateTime date) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) && date.isBefore(end);
  }
}

