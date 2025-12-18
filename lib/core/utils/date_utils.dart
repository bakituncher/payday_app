/// Utility functions for date calculations
library;

import 'package:intl/intl.dart';

class DateUtils {
  /// Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  /// Calculate hours between two dates
  static int hoursBetween(DateTime from, DateTime to) {
    return to.difference(from).inHours;
  }

  /// Calculate minutes between two dates
  static int minutesBetween(DateTime from, DateTime to) {
    return to.difference(from).inMinutes;
  }

  /// Calculate seconds between two dates
  static int secondsBetween(DateTime from, DateTime to) {
    return to.difference(from).inSeconds;
  }

  /// Format date as "MMM dd, yyyy"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date as "EEEE, MMM dd"
  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMM dd').format(date);
  }

  /// Format time as "h:mm a"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format datetime as "MMM dd, h:mm a"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, h:mm a').format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }


  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get the start of the current week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// Get the end of the current week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return DateTime(date.year, date.month, date.day)
        .add(Duration(days: daysToSunday));
  }

  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = getStartOfWeek(now);
    final endOfWeek = getEndOfWeek(now);
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get relative time string with smart formatting
  /// Works perfectly for weekly, bi-weekly, and monthly pay periods
  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(now, date);

    // Past dates
    if (difference < 0) {
      final absDiff = -difference;
      if (absDiff == 1) return 'Yesterday';
      if (absDiff <= 7) return '$absDiff days ago';
      if (absDiff <= 14) {
        final weeks = (absDiff / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      }
      if (absDiff <= 60) {
        final weeks = (absDiff / 7).floor();
        return '$weeks weeks ago';
      }
      final months = (absDiff / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }

    // Today
    if (difference == 0) return 'Today';

    // Future dates
    if (difference == 1) return 'Tomorrow';
    if (difference <= 7) return 'In $difference days';
    if (difference <= 14) {
      final weeks = (difference / 7).floor();
      final remainingDays = difference % 7;
      if (remainingDays == 0) {
        return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
      }
      return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
    }
    if (difference <= 60) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
    }
    final months = (difference / 30).floor();
    return months == 1 ? 'In 1 month' : 'In $months months';
  }

  /// Get compact summary for pay period (optimized for weekly/bi-weekly/monthly)
  static String getPayPeriodSummary(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(now, date);

    // Today
    if (difference == 0) return 'Today';

    // Tomorrow
    if (difference == 1) return 'Tomorrow';

    // This week (2-7 days)
    if (difference > 1 && difference <= 7) {
      return DateFormat('EEEE').format(date); // Day name (e.g., "Friday")
    }

    // Next week (8-14 days)
    if (difference > 7 && difference <= 14) {
      return 'Next ${DateFormat('EEEE').format(date)}';
    }

    // This month (15-30 days)
    if (difference > 14 && difference <= 30 && isThisMonth(date)) {
      return DateFormat('MMM dd').format(date); // e.g., "Dec 25"
    }

    // Next month or beyond
    if (difference > 30 || !isThisMonth(date)) {
      return DateFormat('MMM dd').format(date); // e.g., "Jan 05"
    }

    // Past dates
    if (difference < 0) {
      if (difference == -1) return 'Yesterday';
      if (difference >= -7) return DateFormat('EEEE').format(date);
      return DateFormat('MMM dd').format(date);
    }

    return DateFormat('MMM dd').format(date);
  }

  /// Get countdown text for payday (e.g., "3 days", "2 weeks", "1 month")
  static String getCountdownText(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(now, date);

    if (difference < 0) return 'Passed';
    if (difference == 0) return 'Today';
    if (difference == 1) return '1 day';
    if (difference <= 7) return '$difference days';
    if (difference <= 14) {
      final weeks = (difference / 7).ceil();
      return weeks == 1 ? '1 week' : '$weeks weeks';
    }
    if (difference <= 60) {
      final weeks = (difference / 7).ceil();
      return '$weeks weeks';
    }
    final months = (difference / 30).ceil();
    return months == 1 ? '1 month' : '$months months';
  }

  /// Format remaining time with precision (e.g., "2 days 5 hours")
  static String getDetailedCountdown(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) return 'Passed';
    if (difference.inSeconds < 60) return 'Less than a minute';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes';
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return minutes > 0 ? '$hours hours $minutes min' : '$hours hours';
    }
    if (difference.inDays < 7) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      return hours > 0 ? '$days days $hours hours' : '$days days';
    }
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final days = difference.inDays % 7;
      return days > 0 ? '$weeks weeks $days days' : '$weeks weeks';
    }
    final months = (difference.inDays / 30).floor();
    final days = difference.inDays % 30;
    return days > 0 ? '$months months $days days' : '$months months';
  }
}

