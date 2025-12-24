// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BillReminderImpl _$$BillReminderImplFromJson(
  Map<String, dynamic> json,
) => _$BillReminderImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  subscriptionId: json['subscriptionId'] as String,
  subscriptionName: json['subscriptionName'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  dueDate: DateTime.parse(json['dueDate'] as String),
  reminderDate: DateTime.parse(json['reminderDate'] as String),
  status:
      $enumDecodeNullable(_$ReminderStatusEnumMap, json['status']) ??
      ReminderStatus.pending,
  priority:
      $enumDecodeNullable(_$ReminderPriorityEnumMap, json['priority']) ??
      ReminderPriority.medium,
  note: json['note'] as String? ?? '',
  emoji: json['emoji'] as String? ?? '💳',
  sentAt: const TimestampDateTimeConverter().fromJson(json['sentAt']),
  dismissedAt: const TimestampDateTimeConverter().fromJson(json['dismissedAt']),
  snoozeUntil: const TimestampDateTimeConverter().fromJson(json['snoozeUntil']),
  createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$$BillReminderImplToJson(
  _$BillReminderImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'subscriptionId': instance.subscriptionId,
  'subscriptionName': instance.subscriptionName,
  'amount': instance.amount,
  'currency': instance.currency,
  'dueDate': instance.dueDate.toIso8601String(),
  'reminderDate': instance.reminderDate.toIso8601String(),
  'status': _$ReminderStatusEnumMap[instance.status]!,
  'priority': _$ReminderPriorityEnumMap[instance.priority]!,
  'note': instance.note,
  'emoji': instance.emoji,
  'sentAt': const TimestampDateTimeConverter().toJson(instance.sentAt),
  'dismissedAt': const TimestampDateTimeConverter().toJson(
    instance.dismissedAt,
  ),
  'snoozeUntil': const TimestampDateTimeConverter().toJson(
    instance.snoozeUntil,
  ),
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
};

const _$ReminderStatusEnumMap = {
  ReminderStatus.pending: 'pending',
  ReminderStatus.sent: 'sent',
  ReminderStatus.dismissed: 'dismissed',
  ReminderStatus.snoozed: 'snoozed',
};

const _$ReminderPriorityEnumMap = {
  ReminderPriority.low: 'low',
  ReminderPriority.medium: 'medium',
  ReminderPriority.high: 'high',
  ReminderPriority.urgent: 'urgent',
};
