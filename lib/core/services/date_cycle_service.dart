/// Date Cycle Service
/// Handles automatic updating of payday and subscription billing dates
import 'package:payday/core/models/subscription.dart';

class DateCycleService {
  /// Check if payday has passed and calculate next payday
  static DateTime calculateNextPayday(DateTime currentPayday, String payCycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paydayDate = DateTime(currentPayday.year, currentPayday.month, currentPayday.day);

    // If payday hasn't passed yet, return as is
    if (paydayDate.isAfter(today)) {
      return currentPayday;
    }

    // Payday has passed or is today, calculate next one
    DateTime nextPayday = paydayDate;

    // Safety limit to prevent infinite loops (max 520 iterations = 10 years of weekly pay)
    int iterations = 0;
    const maxIterations = 520;

    while (iterations < maxIterations) {
      iterations++;

      switch (payCycle) {
        case 'Weekly':
          nextPayday = nextPayday.add(const Duration(days: 7));
          break;
        case 'Bi-Weekly':
        case 'Fortnightly':
          nextPayday = nextPayday.add(const Duration(days: 14));
          break;
        case 'Monthly':
          nextPayday = _addMonth(nextPayday, 1);
          break;
        default:
          // Default to monthly if unknown cycle
          nextPayday = _addMonth(nextPayday, 1);
      }

      // Check if we've found a future payday
      if (nextPayday.isAfter(today)) {
        break;
      }
    }

    // If we hit the limit, just set payday to next occurrence from now
    if (iterations >= maxIterations) {
      switch (payCycle) {
        case 'Weekly':
          nextPayday = today.add(const Duration(days: 7));
          break;
        case 'Bi-Weekly':
        case 'Fortnightly':
          nextPayday = today.add(const Duration(days: 14));
          break;
        case 'Monthly':
        default:
          nextPayday = _addMonth(today, 1);
      }
    }

    return nextPayday;
  }

  /// Check if subscription billing date has passed and calculate next billing date
  static DateTime calculateNextBillingDate(
    DateTime currentBillingDate,
    RecurrenceFrequency frequency,
  ) {
    final now = DateTime.now();

    // If billing date hasn't passed yet, return as is
    if (currentBillingDate.isAfter(now)) {
      return currentBillingDate;
    }

    // Billing date has passed, calculate next one
    DateTime nextBilling = currentBillingDate;

    // Safety limit to prevent infinite loops
    int iterations = 0;
    const maxIterations = 3650; // 10 years of daily billing

    while ((nextBilling.isBefore(now) || _isSameDay(nextBilling, now)) && iterations < maxIterations) {
      iterations++;
      switch (frequency) {
        case RecurrenceFrequency.daily:
          nextBilling = nextBilling.add(const Duration(days: 1));
          break;
        case RecurrenceFrequency.weekly:
          nextBilling = nextBilling.add(const Duration(days: 7));
          break;
        case RecurrenceFrequency.biweekly:
          nextBilling = nextBilling.add(const Duration(days: 14));
          break;
        case RecurrenceFrequency.monthly:
          nextBilling = _addMonth(nextBilling, 1);
          break;
        case RecurrenceFrequency.quarterly:
          nextBilling = _addMonth(nextBilling, 3);
          break;
        case RecurrenceFrequency.yearly:
          nextBilling = _addMonth(nextBilling, 12);
          break;
      }
    }

    // If we hit the limit, set to next occurrence from now
    if (iterations >= maxIterations) {
      nextBilling = _addMonth(now, 1);
    }

    return nextBilling;
  }

  /// Add months to a date, handling edge cases
  static DateTime _addMonth(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;
    int day = date.day;

    // Handle year overflow
    while (month > 12) {
      month -= 12;
      year++;
    }

    // Get the last day of the target month
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;

    // If the day doesn't exist in target month, use last day
    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    return DateTime(year, month, day, date.hour, date.minute);
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

    // Return days until target (not including today if target is in future)
    final difference = target.difference(today).inDays;
    return difference >= 0 ? difference : 0;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  /// Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }
}

