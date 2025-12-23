// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsGoalImpl _$$SavingsGoalImplFromJson(
  Map<String, dynamic> json,
) => _$SavingsGoalImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
  emoji: json['emoji'] as String,
  createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt'])!,
  targetDate: const TimestampDateTimeConverter().fromJson(json['targetDate']),
  autoTransferEnabled: json['autoTransferEnabled'] as bool? ?? false,
  autoTransferAmount: (json['autoTransferAmount'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$SavingsGoalImplToJson(
  _$SavingsGoalImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'targetAmount': instance.targetAmount,
  'currentAmount': instance.currentAmount,
  'emoji': instance.emoji,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
  'targetDate': const TimestampDateTimeConverter().toJson(instance.targetDate),
  'autoTransferEnabled': instance.autoTransferEnabled,
  'autoTransferAmount': instance.autoTransferAmount,
};
