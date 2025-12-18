// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsGoalImpl _$$SavingsGoalImplFromJson(Map<String, dynamic> json) =>
    _$SavingsGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyContribution: (json['monthlyContribution'] as num?)?.toDouble() ?? 0.0,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
    );

Map<String, dynamic> _$$SavingsGoalImplToJson(_$SavingsGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'monthlyContribution': instance.monthlyContribution,
      'emoji': instance.emoji,
      'createdAt': instance.createdAt.toIso8601String(),
      'targetDate': instance.targetDate?.toIso8601String(),
    };
