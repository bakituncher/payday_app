// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      userId: json['userId'] as String,
      currency: json['currency'] as String,
      payCycle: json['payCycle'] as String,
      nextPayday: DateTime.parse(json['nextPayday'] as String),
      incomeAmount: (json['incomeAmount'] as num).toDouble(),
      market: json['market'] as String? ?? 'US',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      paydayReminders: json['paydayReminders'] as bool? ?? true,
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
      'market': instance.market,
      'notificationsEnabled': instance.notificationsEnabled,
      'paydayReminders': instance.paydayReminders,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
