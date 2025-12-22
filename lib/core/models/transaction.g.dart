// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryEmoji: json['categoryEmoji'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      isExpense: json['isExpense'] as bool? ?? true,
      isRecurring: json['isRecurring'] as bool? ?? false,
      frequency: $enumDecodeNullable(
        _$TransactionFrequencyEnumMap,
        json['frequency'],
      ),
      subscriptionId: json['subscriptionId'] as String?,
      nextRecurrenceDate: const TimestampDateTimeConverter().fromJson(
        json['nextRecurrenceDate'],
      ),
      relatedGoalId: json['relatedGoalId'] as String?,
      createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampDateTimeConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$TransactionImplToJson(
  _$TransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'categoryEmoji': instance.categoryEmoji,
  'date': instance.date.toIso8601String(),
  'note': instance.note,
  'isExpense': instance.isExpense,
  'isRecurring': instance.isRecurring,
  'frequency': _$TransactionFrequencyEnumMap[instance.frequency],
  'subscriptionId': instance.subscriptionId,
  'nextRecurrenceDate': const TimestampDateTimeConverter().toJson(
    instance.nextRecurrenceDate,
  ),
  'relatedGoalId': instance.relatedGoalId,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampDateTimeConverter().toJson(instance.updatedAt),
};

const _$TransactionFrequencyEnumMap = {
  TransactionFrequency.daily: 'daily',
  TransactionFrequency.weekly: 'weekly',
  TransactionFrequency.biweekly: 'biweekly',
  TransactionFrequency.monthly: 'monthly',
  TransactionFrequency.quarterly: 'quarterly',
  TransactionFrequency.yearly: 'yearly',
};
