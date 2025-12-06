/// Transaction model
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required double amount,
    required String categoryId,
    required String categoryName,
    required String categoryEmoji,
    required DateTime date,
    @Default('') String note,
    @Default(true) bool isExpense,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

