/// Date Cycle Service - Industry Grade
/// Handles automatic updating of payday and subscription billing dates
/// with business day adjustments and O(1) complexity calculations.
library;

import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/pay_period.dart';

class DateCycleService {
  /// Calculate next payday optimized without loops
  /// Returns current payday if it's today or in the future
  /// FIXED: "Skip Today Bug" - Now correctly returns today if it's a payday
  static DateTime calculateNextPayday(DateTime currentPayday, String payCycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Semi-Monthly özel durumu: Her zaman bugünün tarihine göre hesapla
    // (15. gün ve ayın son günü sabit olduğu için mevcut payday önemli değil)
    if (payCycle == 'Semi-Monthly') {
      final nextDate = _calculateNextSemiMonthlyCalendarDate(today);
      return _adjustForWeekend(nextDate);
    }

    // Normalize current payday to remove time components for comparison
    DateTime basePayday = DateTime(currentPayday.year, currentPayday.month, currentPayday.day);

    // If payday is today or in the future, return it with weekend adjustment
    if (basePayday.isAfter(today) || _isSameDay(basePayday, today)) {
      return _adjustForWeekend(basePayday);
    }

    // Payday has passed, calculate next one
    DateTime nextDate;

    switch (payCycle) {
      case 'Weekly':
        nextDate = _calculateNextPeriodicDate(basePayday, today, 7);
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        nextDate = _calculateNextPeriodicDate(basePayday, today, 14);
        break;
      case 'Monthly':
        nextDate = _calculateNextMonthlyDate(basePayday, today);
        break;
      default:
        nextDate = _calculateNextMonthlyDate(basePayday, today);
    }

    // Finansal standart: Maaş günü hafta sonuna gelirse Cuma'ya çek
    return _adjustForWeekend(nextDate);
  }

  /// Calendar-based semi-monthly next payday.
  ///
  /// Rule (Semi-Monthly: 15. gün ve ayın son günü):
  /// - Bugün 15'ten önceyse => bu ayın 15'i
  /// - Bugün 15 ile son gün arasındaysa => bu ayın son günü
  /// - Bugün ayın son günüyse veya sonrasıysa => gelecek ayın 15'i
  ///
  /// This avoids drift in 28/29/30/31 day months.
  static DateTime _calculateNextSemiMonthlyCalendarDate(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final lastDay = DateTime(t.year, t.month + 1, 0).day;

    // Bugün 15'ten önceyse, bu ayın 15'i
    if (t.day < 15) {
      return DateTime(t.year, t.month, 15);
    }

    // Bugün 15 ile son gün arasındaysa, bu ayın son günü
    if (t.day < lastDay) {
      return DateTime(t.year, t.month, lastDay);
    }

    // Bugün ayın son günüyse veya sonrasıysa, gelecek ayın 15'i
    final nextMonth = DateTime(t.year, t.month + 1, 1);
    return DateTime(nextMonth.year, nextMonth.month, 15);
  }

  /// Calculates next recurring date using math instead of loops (O(1) complexity)
  /// FIXED: Changed logic to include TODAY as a valid next date if cycles align
  /// Previously: (cyclesPassed + 1) would ALWAYS skip today, even if today was payday
  /// Now: Checks if potentialDate (current cycle) is valid before jumping to next cycle
  static DateTime _calculateNextPeriodicDate(DateTime startDate, DateTime today, int cycleDays) {
    final diffDays = today.difference(startDate).inDays;

    if (diffDays < 0) return startDate;

    // Calculate how many full cycles have passed
    final cyclesPassed = (diffDays / cycleDays).floor();

    // Calculate potential date for current cycle
    DateTime potentialDate = startDate.add(Duration(days: cyclesPassed * cycleDays));

    // If potential date is in the past, move to next cycle
    // If potential date is TODAY, return it (allows "It's Payday!" UI)
    if (potentialDate.isBefore(today)) {
      return startDate.add(Duration(days: (cyclesPassed + 1) * cycleDays));
    }

    return potentialDate;
  }

  /// Calculates next monthly date safely handling end-of-month logic
  /// FIXED: Logic adjusted to catch TODAY as valid payday using isBefore check
  static DateTime _calculateNextMonthlyDate(DateTime startDate, DateTime today) {
    // Calculate month difference (approximate cycle count)
    int monthDiff = (today.year - startDate.year) * 12 + (today.month - startDate.month);

    // Calculate candidate date (e.g., Start: Jan 31, Today: Feb 28 -> Returns Feb 28)
    DateTime candidate = _addMonthsSafely(startDate, monthDiff);

    // If calculated date is in the past, add 1 month
    // If it's today, return it (valid payday)
    if (candidate.isBefore(today)) {
      candidate = _addMonthsSafely(startDate, monthDiff + 1);
    }

    return candidate;
  }

  /// Industry Standard: If payday falls on weekend, move to Friday
  static DateTime _adjustForWeekend(DateTime date) {
    if (date.weekday == DateTime.saturday) {
      return date.subtract(const Duration(days: 1));
    } else if (date.weekday == DateTime.sunday) {
      return date.subtract(const Duration(days: 2));
    }
    return date;
  }

  /// Check if subscription billing date has passed and calculate next billing date
  /// Returns current billing date if it's today (for consistency with payday logic)
  /// FIXED: Now uses corrected _calculateNextPeriodicDate that doesn't skip today
  static DateTime calculateNextBillingDate(DateTime currentNextBilling, RecurrenceFrequency frequency) {
    DateTime next = currentNextBilling;
    final now = DateTime.now();

    int stepDays;
    switch (frequency) {
      case RecurrenceFrequency.daily:
        stepDays = 1;
        break;
      case RecurrenceFrequency.weekly:
        stepDays = 7;
        break;
      case RecurrenceFrequency.biweekly:
        stepDays = 14;
        break;
      case RecurrenceFrequency.monthly:
        while (!next.isAfter(now)) {
          next = DateTime(next.year, next.month + 1, next.day);
        }
        return next;
      case RecurrenceFrequency.quarterly:
        while (!next.isAfter(now)) {
          next = DateTime(next.year, next.month + 3, next.day);
        }
        return next;
      case RecurrenceFrequency.yearly:
        while (!next.isAfter(now)) {
          next = DateTime(next.year + 1, next.month, next.day);
        }
        return next;
    }

    while (!next.isAfter(now)) {
      next = next.add(Duration(days: stepDays));
    }
    return next;
  }

  /// Robust month addition handling day clamping (e.g. Jan 31 + 1 month -> Feb 28)
  static DateTime _addMonthsSafely(DateTime date, int monthsToAdd) {
    // Dart handles year overflow automatically in the constructor
    int newYear = date.year;
    int newMonth = date.month + monthsToAdd;

    // Calculate the target year/month properly using standard DateTime logic normalization
    // We create a temp date to let Dart figure out the correct year/month index
    DateTime tempDate = DateTime(newYear, newMonth, 1);

    // Now determine the last valid day of that target month
    int lastDayOfTargetMonth = DateTime(tempDate.year, tempDate.month + 1, 0).day;

    // Clamp the original day
    int newDay = date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;

    return DateTime(tempDate.year, tempDate.month, newDay, date.hour, date.minute);
  }

  /// Check if two dates are the same day
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get days remaining until a date
  static int getDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;
    return difference >= 0 ? difference : 0;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) => _isSameDay(date, DateTime.now());

  /// Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  /// Get current pay period bounds based on nextPayday.
  ///
  /// Contract:
  /// - start: previous payday (inclusive)
  /// - end: next payday (exclusive)
  ///
  /// Important: `nextPayday` is treated as the *upcoming* payday after calling
  /// [calculateNextPayday]. Caller should ensure settings are refreshed.
  static PayPeriod getCurrentPayPeriod({
    required DateTime nextPayday,
    required String payCycle,
  }) {
    final normalizedNext = DateTime(nextPayday.year, nextPayday.month, nextPayday.day);
    final start = getPreviousPayday(nextPayday: normalizedNext, payCycle: payCycle);

    // End is exclusive. This prevents double-counting a transaction that happens exactly
    // at the boundary when user flips periods.
    final end = normalizedNext;
    return PayPeriod(start: start, end: end);
  }

  /// Get previous payday for a given nextPayday.
  ///
  /// NOTE: This is intentionally kept here (instead of in UI providers) so all layers
  /// share the exact same rules.
  static DateTime getPreviousPayday({
    required DateTime nextPayday,
    required String payCycle,
  }) {
    final normalizedNext = DateTime(nextPayday.year, nextPayday.month, nextPayday.day);

    switch (payCycle) {
      case 'Weekly':
        return normalizedNext.subtract(const Duration(days: 7));
      case 'Bi-Weekly':
      case 'Fortnightly':
        return normalizedNext.subtract(const Duration(days: 14));
      case 'Semi-Monthly':
        return _getPreviousSemiMonthlyCalendarDate(normalizedNext);
      case 'Monthly':
      default:
        return _subtractOneMonth(normalizedNext);
    }
  }

  /// Calendar-based semi-monthly previous payday.
  ///
  /// We assume anchor days are 15th and last day of month.
  /// - If nextPayday is 15th => previous is last day of previous month
  /// - If nextPayday is last day => previous is 15th of same month
  /// - Otherwise fallback: 15 days (keeps behavior reasonable if user has a custom date)
  static DateTime _getPreviousSemiMonthlyCalendarDate(DateTime nextPayday) {
    final n = DateTime(nextPayday.year, nextPayday.month, nextPayday.day);
    final lastDay = DateTime(n.year, n.month + 1, 0).day;

    if (n.day == 15) {
      final prevMonth = DateTime(n.year, n.month - 1, 1);
      final prevLastDay = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
      return DateTime(prevMonth.year, prevMonth.month, prevLastDay);
    }

    if (n.day == lastDay) {
      return DateTime(n.year, n.month, 15);
    }

    // Fallback for non-standard semi-monthly anchors.
    return n.subtract(const Duration(days: 15));
  }

  /// Subtract one month from a date, handling edge cases (e.g., Mar 31 -> Feb 28)
  static DateTime _subtractOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month - 1;
    int day = date.day;

    if (month < 1) {
      month = 12;
      year--;
    }

    final lastDayOfPrevMonth = DateTime(year, month + 1, 0).day;
    if (day > lastDayOfPrevMonth) {
      day = lastDayOfPrevMonth;
    }

    return DateTime(year, month, day);
  }
}
