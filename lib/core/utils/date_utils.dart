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


  /// Get relative time string (e.g., "in 5 days", "tomorrow", "today")
  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(now, date);

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'in $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}

