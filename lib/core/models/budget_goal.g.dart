// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetGoalImpl _$$BudgetGoalImplFromJson(Map<String, dynamic> json) =>
    _$BudgetGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryEmoji: json['categoryEmoji'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      period: $enumDecode(_$BudgetPeriodEnumMap, json['period']),
      isActive: json['isActive'] as bool? ?? true,
      notifyOnWarning: json['notifyOnWarning'] as bool? ?? true,
      warningThreshold: (json['warningThreshold'] as num?)?.toInt() ?? 80,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BudgetGoalImplToJson(_$BudgetGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryEmoji': instance.categoryEmoji,
      'limitAmount': instance.limitAmount,
      'spentAmount': instance.spentAmount,
      'period': _$BudgetPeriodEnumMap[instance.period]!,
      'isActive': instance.isActive,
      'notifyOnWarning': instance.notifyOnWarning,
      'warningThreshold': instance.warningThreshold,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$BudgetPeriodEnumMap = {
  BudgetPeriod.weekly: 'weekly',
  BudgetPeriod.biweekly: 'biweekly',
  BudgetPeriod.monthly: 'monthly',
};
