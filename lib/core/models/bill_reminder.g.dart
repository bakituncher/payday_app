// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BillReminderImpl _$$BillReminderImplFromJson(Map<String, dynamic> json) =>
    _$BillReminderImpl(
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
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      dismissedAt: json['dismissedAt'] == null
          ? null
          : DateTime.parse(json['dismissedAt'] as String),
      snoozeUntil: json['snoozeUntil'] == null
          ? null
          : DateTime.parse(json['snoozeUntil'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BillReminderImplToJson(_$BillReminderImpl instance) =>
    <String, dynamic>{
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
      'sentAt': instance.sentAt?.toIso8601String(),
      'dismissedAt': instance.dismissedAt?.toIso8601String(),
      'snoozeUntil': instance.snoozeUntil?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
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
