/// Transaction model with recurring payment support
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Frequency enum for recurring transactions
enum TransactionFrequency {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('biweekly')
  biweekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

@freezed
class Transaction with _$Transaction {
  const Transaction._();

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
    // Recurring payment fields
    @Default(false) bool isRecurring,
    TransactionFrequency? frequency,
    String? subscriptionId, // Link to subscription if applicable
    DateTime? nextRecurrenceDate,
    // Savings goal link
    String? relatedGoalId, // Link to savings goal if this is a savings transaction
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Get frequency display text
  String? get frequencyText {
    if (frequency == null) return null;
    switch (frequency!) {
      case TransactionFrequency.daily:
        return 'Daily';
      case TransactionFrequency.weekly:
        return 'Weekly';
      case TransactionFrequency.biweekly:
        return 'Every 2 weeks';
      case TransactionFrequency.monthly:
        return 'Monthly';
      case TransactionFrequency.quarterly:
        return 'Quarterly';
      case TransactionFrequency.yearly:
        return 'Yearly';
    }
  }

  /// Calculate monthly equivalent amount for recurring transactions
  double get monthlyEquivalent {
    if (!isRecurring || frequency == null) return amount;
    switch (frequency!) {
      case TransactionFrequency.daily:
        return amount * 30;
      case TransactionFrequency.weekly:
        return amount * 4.33;
      case TransactionFrequency.biweekly:
        return amount * 2.17;
      case TransactionFrequency.monthly:
        return amount;
      case TransactionFrequency.quarterly:
        return amount / 3;
      case TransactionFrequency.yearly:
        return amount / 12;
    }
  }
}

