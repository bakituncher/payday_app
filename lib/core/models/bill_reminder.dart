/// Bill Reminder model for scheduled payment notifications
/// Industry-grade implementation with Firebase support
import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters/timestamp_converter.dart';

part 'bill_reminder.freezed.dart';
part 'bill_reminder.g.dart';

/// Reminder status
enum ReminderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sent')
  sent,
  @JsonValue('dismissed')
  dismissed,
  @JsonValue('snoozed')
  snoozed,
}

/// Reminder priority
enum ReminderPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@freezed
class BillReminder with _$BillReminder {
  const BillReminder._();

  const factory BillReminder({
    required String id,
    required String userId,
    required String subscriptionId,
    required String subscriptionName,
    required double amount,
    @Default('USD') String currency,
    @TimestampDateTimeConverter() required DateTime dueDate,
    @TimestampDateTimeConverter() required DateTime reminderDate,
    @Default(ReminderStatus.pending) ReminderStatus status,
    @Default(ReminderPriority.medium) ReminderPriority priority,
    @Default('') String note,
    @Default('💳') String emoji,
    @TimestampDateTimeConverter() DateTime? sentAt,
    @TimestampDateTimeConverter() DateTime? dismissedAt,
    @TimestampDateTimeConverter() DateTime? snoozeUntil,
    @TimestampDateTimeConverter() DateTime? createdAt,
  }) = _BillReminder;

  factory BillReminder.fromJson(Map<String, dynamic> json) =>
      _$BillReminderFromJson(json);

  /// Check if reminder is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status == ReminderStatus.pending;
  }

  /// Check if reminder is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
           dueDate.month == now.month &&
           dueDate.day == now.day;
  }

  /// Days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get priority color name for UI
  String get priorityColorName {
    switch (priority) {
      case ReminderPriority.low:
        return 'success';
      case ReminderPriority.medium:
        return 'info';
      case ReminderPriority.high:
        return 'warning';
      case ReminderPriority.urgent:
        return 'error';
    }
  }
}
