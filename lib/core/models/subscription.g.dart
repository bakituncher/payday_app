// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
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
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 2,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      trialEndsAt: json['trialEndsAt'] == null
          ? null
          : DateTime.parse(json['trialEndsAt'] as String),
      pausedAt: json['pausedAt'] == null
          ? null
          : DateTime.parse(json['pausedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
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
      'reminderEnabled': instance.reminderEnabled,
      'reminderDaysBefore': instance.reminderDaysBefore,
      'startDate': instance.startDate?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
      'pausedAt': instance.pausedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
