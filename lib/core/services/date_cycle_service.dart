/// Date Cycle Service - Industry Grade
/// Handles automatic updating of payday and subscription billing dates
/// with business day adjustments and O(1) complexity calculations.
library;

import 'package:payday/core/models/subscription.dart';

class DateCycleService {
  /// Calculate next payday optimized without loops
  /// Returns current payday if it's today (for "It's Payday!" UI experience)
  static DateTime calculateNextPayday(DateTime currentPayday, String payCycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize current payday to remove time components for comparison
    DateTime basePayday = DateTime(currentPayday.year, currentPayday.month, currentPayday.day);

    // If payday is today or in the future, return it (allows "It's Payday!" celebration UI)
    if (basePayday.isAfter(today) || _isSameDay(basePayday, today)) {
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
  static DateTime _calculateNextPeriodicDate(DateTime startDate, DateTime today, int cycleDays) {
    final diffDays = today.difference(startDate).inDays;

    if (diffDays < 0) return startDate;

    // Calculate how many full cycles have passed
    final cyclesPassed = (diffDays / cycleDays).floor();

    // Jump directly to the next cycle
    // (cyclesPassed + 1) ensures we get the *next* future date
    return startDate.add(Duration(days: (cyclesPassed + 1) * cycleDays));
  }

  /// Calculates next monthly date safely handling end-of-month logic
  static DateTime _calculateNextMonthlyDate(DateTime startDate, DateTime today) {
    DateTime candidate = startDate;

    // Eğer başlangıç tarihi bugün veya geçmişteyse, bugünden sonraki ilk ayı bulana kadar ilerle.
    // Aylık döngüde matematiksel hesaplama (modüler) gün sayısı değiştiği için risklidir,
    // ancak burada sadece "yıl * 12 + ay" farkını alarak zıplayabiliriz.

    if (candidate.isBefore(today) || _isSameDay(candidate, today)) {
      int monthDiff = (today.year - startDate.year) * 12 + (today.month - startDate.month);

      // En az 1 ay ekleyerek başla
      candidate = _addMonthsSafely(startDate, monthDiff);

      // Eğer hala geçmişteyse 1 ay daha ekle
      if (!candidate.isAfter(today)) {
        candidate = _addMonthsSafely(candidate, 1);
      }
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
  static DateTime calculateNextBillingDate(
    DateTime currentBillingDate,
    RecurrenceFrequency frequency,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime baseBilling = DateTime(currentBillingDate.year, currentBillingDate.month, currentBillingDate.day);

    // If billing date is today or in the future, return it
    if (baseBilling.isAfter(today) || _isSameDay(baseBilling, today)) {
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
        return _addMonthsSafely(baseBilling, _calculateMonthDiff(baseBilling, today) + 1);
      case RecurrenceFrequency.quarterly:
        int monthsToAdd = (_calculateMonthDiff(baseBilling, today) / 3).ceil() * 3;
        return _addMonthsSafely(baseBilling, monthsToAdd);
      case RecurrenceFrequency.yearly:
        int yearsToAdd = (today.year - baseBilling.year) + 1;
        return _addMonthsSafely(baseBilling, yearsToAdd * 12);
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

