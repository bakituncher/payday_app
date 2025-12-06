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
      nextRecurrenceDate: json['nextRecurrenceDate'] == null
          ? null
          : DateTime.parse(json['nextRecurrenceDate'] as String),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
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
      'nextRecurrenceDate': instance.nextRecurrenceDate?.toIso8601String(),
    };

const _$TransactionFrequencyEnumMap = {
  TransactionFrequency.daily: 'daily',
  TransactionFrequency.weekly: 'weekly',
  TransactionFrequency.biweekly: 'biweekly',
  TransactionFrequency.monthly: 'monthly',
  TransactionFrequency.quarterly: 'quarterly',
  TransactionFrequency.yearly: 'yearly',
};
