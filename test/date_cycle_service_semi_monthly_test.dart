import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/services/date_cycle_service.dart';

void main() {
  group('DateCycleService Semi-Monthly calendar rules', () {
    test('previous payday for 15th is last day of previous month', () {
      final nextPayday = DateTime(2025, 4, 15);
      final prev = DateCycleService.getPreviousPayday(nextPayday: nextPayday, payCycle: 'Semi-Monthly');
      expect(prev, DateTime(2025, 3, 31));
    });

    test('previous payday for end-of-month is 15th of same month', () {
      final nextPayday = DateTime(2025, 4, 30);
      final prev = DateCycleService.getPreviousPayday(nextPayday: nextPayday, payCycle: 'Semi-Monthly');
      expect(prev, DateTime(2025, 4, 15));
    });

    test('previous payday handles leap-year Feb correctly', () {
      final nextPayday = DateTime(2024, 3, 15);
      final prev = DateCycleService.getPreviousPayday(nextPayday: nextPayday, payCycle: 'Semi-Monthly');
      expect(prev, DateTime(2024, 2, 29));
    });
  });
}

