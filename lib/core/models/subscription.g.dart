// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
  category: $enumDecode(_$SubscriptionCategoryEnumMap, json['category']),
  nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
  description: json['description'] as String? ?? '',
  logoUrl: json['logoUrl'] as String? ?? '',
  emoji: json['emoji'] as String? ?? '💳',
  status:
      $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
      SubscriptionStatus.active,
  autoRenew: json['autoRenew'] as bool? ?? true,
  reminderEnabled: json['reminderEnabled'] as bool? ?? true,
  reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 2,
  startDate: const TimestampDateTimeConverter().fromJson(json['startDate']),
  cancelledAt: const TimestampDateTimeConverter().fromJson(json['cancelledAt']),
  trialEndsAt: const TimestampDateTimeConverter().fromJson(json['trialEndsAt']),
  pausedAt: const TimestampDateTimeConverter().fromJson(json['pausedAt']),
  createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$$SubscriptionImplToJson(
  _$SubscriptionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'amount': instance.amount,
  'currency': instance.currency,
  'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
  'category': _$SubscriptionCategoryEnumMap[instance.category]!,
  'nextBillingDate': instance.nextBillingDate.toIso8601String(),
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'emoji': instance.emoji,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'autoRenew': instance.autoRenew,
  'reminderEnabled': instance.reminderEnabled,
  'reminderDaysBefore': instance.reminderDaysBefore,
  'startDate': const TimestampDateTimeConverter().toJson(instance.startDate),
  'cancelledAt': const TimestampDateTimeConverter().toJson(
    instance.cancelledAt,
  ),
  'trialEndsAt': const TimestampDateTimeConverter().toJson(
    instance.trialEndsAt,
  ),
  'pausedAt': const TimestampDateTimeConverter().toJson(instance.pausedAt),
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampDateTimeConverter().toJson(instance.updatedAt),
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.biweekly: 'biweekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.quarterly: 'quarterly',
  RecurrenceFrequency.yearly: 'yearly',
};

const _$SubscriptionCategoryEnumMap = {
  SubscriptionCategory.streaming: 'streaming',
  SubscriptionCategory.productivity: 'productivity',
  SubscriptionCategory.cloudStorage: 'cloud_storage',
  SubscriptionCategory.fitness: 'fitness',
  SubscriptionCategory.gaming: 'gaming',
  SubscriptionCategory.newsMedia: 'news_media',
  SubscriptionCategory.foodDelivery: 'food_delivery',
  SubscriptionCategory.shopping: 'shopping',
  SubscriptionCategory.finance: 'finance',
  SubscriptionCategory.education: 'education',
  SubscriptionCategory.utilities: 'utilities',
  SubscriptionCategory.other: 'other',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.paused: 'paused',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.trial: 'trial',
};
