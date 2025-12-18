// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$UserSettingsImpl(
  userId: json['userId'] as String,
  currency: json['currency'] as String,
  payCycle: json['payCycle'] as String,
  nextPayday: DateTime.parse(json['nextPayday'] as String),
  incomeAmount: (json['incomeAmount'] as num).toDouble(),
  currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
  market: json['market'] as String? ?? 'US',
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  paydayReminders: json['paydayReminders'] as bool? ?? true,
  billReminders: json['billReminders'] as bool? ?? true,
  billReminderDaysBefore:
      (json['billReminderDaysBefore'] as num?)?.toInt() ?? 2,
  subscriptionAlerts: json['subscriptionAlerts'] as bool? ?? true,
  weeklySubscriptionSummary: json['weeklySubscriptionSummary'] as bool? ?? true,
  unusedSubscriptionAlerts: json['unusedSubscriptionAlerts'] as bool? ?? true,
  unusedThresholdDays: (json['unusedThresholdDays'] as num?)?.toInt() ?? 30,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'currency': instance.currency,
      'payCycle': instance.payCycle,
      'nextPayday': instance.nextPayday.toIso8601String(),
      'incomeAmount': instance.incomeAmount,
      'currentBalance': instance.currentBalance,
      'market': instance.market,
      'notificationsEnabled': instance.notificationsEnabled,
      'paydayReminders': instance.paydayReminders,
      'billReminders': instance.billReminders,
      'billReminderDaysBefore': instance.billReminderDaysBefore,
      'subscriptionAlerts': instance.subscriptionAlerts,
      'weeklySubscriptionSummary': instance.weeklySubscriptionSummary,
      'unusedSubscriptionAlerts': instance.unusedSubscriptionAlerts,
      'unusedThresholdDays': instance.unusedThresholdDays,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
