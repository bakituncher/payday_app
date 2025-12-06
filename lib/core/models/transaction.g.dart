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
    };
