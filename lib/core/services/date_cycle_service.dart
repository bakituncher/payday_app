/// Date Cycle Service - Industry Grade
/// Handles automatic updating of payday and subscription billing dates
/// with business day adjustments and O(1) complexity calculations.
library;

import 'package:payday/core/models/subscription.dart';

class DateCycleService {
  /// Calculate next payday optimized without loops
  /// Returns current payday if it's today (for "It's Payday!" UI experience)
  /// FIXED: "Skip Today Bug" - Now correctly returns today if it's a payday
  static DateTime calculateNextPayday(DateTime currentPayday, String payCycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize current payday to remove time components for comparison
    DateTime basePayday = DateTime(currentPayday.year, currentPayday.month, currentPayday.day);

    // If payday is in the future, return it with weekend adjustment
    if (basePayday.isAfter(today)) {
      return _adjustForWeekend(basePayday);
    }

    // If payday is today, return it immediately (for "It's Payday!" celebration UI)
    if (_isSameDay(basePayday, today)) {
      return _adjustForWeekend(basePayday);
    }

    DateTime nextDate;

    switch (payCycle) {
      case 'Weekly':
        nextDate = _calculateNextPeriodicDate(basePayday, today, 7);
        break;
      case 'Bi-Weekly':
      case 'Fortnightly':
        nextDate = _calculateNextPeriodicDate(basePayday, today, 14);
        break;
      case 'Semi-Monthly': // NEW: Twice per month (e.g., 15th and Last day)
        nextDate = _calculateNextSemiMonthlyDate(basePayday, today);
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

  /// Industry Standard: Semi-Monthly (Usually 15th and Last Day of Month)
  /// Common in US corporate payroll: twice per month on fixed dates
  /// This implementation uses a 15-day cycle as approximation
  /// Note: Production systems typically store two separate anchor dates in UserSettings
  static DateTime _calculateNextSemiMonthlyDate(DateTime startDate, DateTime today) {
    // Simple implementation: Use 15-day periodic cycle
    // More sophisticated approach: Track two anchor dates (e.g., 15th and 30th)
    // For now, treat as 15-day recurring cycle
    return _calculateNextPeriodicDate(startDate, today, 15);
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
  static DateTime calculateNextBillingDate(
    DateTime currentBillingDate,
    RecurrenceFrequency frequency,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime baseBilling = DateTime(currentBillingDate.year, currentBillingDate.month, currentBillingDate.day);

    // If billing date is in the future, return it
    if (baseBilling.isAfter(today)) {
      return baseBilling;
    }

    // If billing date is today, return it (valid billing day)
    if (_isSameDay(baseBilling, today)) {
      return baseBilling;
    }

    switch (frequency) {
      case RecurrenceFrequency.daily:
        return today.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return _calculateNextPeriodicDate(baseBilling, today, 7);
      case RecurrenceFrequency.biweekly:
        return _calculateNextPeriodicDate(baseBilling, today, 14);
      case RecurrenceFrequency.monthly:
        return _calculateNextMonthlyDate(baseBilling, today);
      case RecurrenceFrequency.quarterly:
        // Quarterly: Every 3 months from anchor date
        int monthDiff = _calculateMonthDiff(baseBilling, today);
        int cyclesPassed = (monthDiff / 3).floor();
        DateTime candidate = _addMonthsSafely(baseBilling, cyclesPassed * 3);

        if (candidate.isBefore(today)) {
          return _addMonthsSafely(baseBilling, (cyclesPassed + 1) * 3);
        }
        return candidate;
      case RecurrenceFrequency.yearly:
        // Yearly: Same date next year
        int yearsPassed = today.year - baseBilling.year;
        DateTime candidate = _addMonthsSafely(baseBilling, yearsPassed * 12);

        if (candidate.isBefore(today)) {
          return _addMonthsSafely(baseBilling, (yearsPassed + 1) * 12);
        }
        return candidate;
    }
  }

  /// Helper to calculate difference in months
  static int _calculateMonthDiff(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
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
}

