/// Monthly Summary model for end-of-month financial overview
/// Tracks spending, savings, and provides actionable insights
import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters/timestamp_converter.dart';

part 'monthly_summary.freezed.dart';
part 'monthly_summary.g.dart';

/// What to do with leftover money
enum LeftoverAction {
  @JsonValue('save')
  save, // Add to savings
  @JsonValue('invest')
  invest, // Investment recommendation
  @JsonValue('emergency')
  emergency, // Emergency fund
  @JsonValue('debt')
  debt, // Pay off debt
  @JsonValue('rollover')
  rollover, // Roll over to next month
  @JsonValue('treat')
  treat, // Treat yourself (small reward)
}

/// Spending trend direction
enum SpendingTrend {
  @JsonValue('increasing')
  increasing,
  @JsonValue('decreasing')
  decreasing,
  @JsonValue('stable')
  stable,
}

/// Financial health status
enum FinancialHealth {
  @JsonValue('excellent')
  excellent, // Spending < 50% of income
  @JsonValue('good')
  good, // Spending 50-70% of income
  @JsonValue('fair')
  fair, // Spending 70-90% of income
  @JsonValue('poor')
  poor, // Spending 90-100% of income
  @JsonValue('critical')
  critical, // Overspending
}

@freezed
class MonthlySummary with _$MonthlySummary {
  const MonthlySummary._();

  const factory MonthlySummary({
    required String id,
    required String userId,
    required int year,
    required int month,
    required double totalIncome,
    required double totalExpenses,
    required double totalSubscriptions,
    required double leftoverAmount,
    required FinancialHealth healthStatus,
    required SpendingTrend trend,
    @Default({}) Map<String, double> expensesByCategory,
    @Default([]) List<SpendingInsight> insights,
    @Default([]) List<LeftoverSuggestion> leftoverSuggestions,
    @Default(0) double savingsGoalProgress,
    @Default(0) double emergencyFundProgress,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? finalizedAt,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);

  /// Calculate savings rate
  double get savingsRate {
    if (totalIncome <= 0) return 0;
    return ((totalIncome - totalExpenses) / totalIncome * 100).clamp(0, 100);
  }

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Check if month is finalized
  bool get isFinalized => finalizedAt != null;

  /// Get health status text
  String get healthStatusText {
    switch (healthStatus) {
      case FinancialHealth.excellent:
        return 'Excellent! You\'re saving a lot.';
      case FinancialHealth.good:
        return 'Good job! Healthy spending habits.';
      case FinancialHealth.fair:
        return 'Fair. Consider reducing some expenses.';
      case FinancialHealth.poor:
        return 'Be careful. You\'re spending most of your income.';
      case FinancialHealth.critical:
        return 'Warning! You\'re overspending.';
    }
  }

  /// Get health status emoji
  String get healthStatusEmoji {
    switch (healthStatus) {
      case FinancialHealth.excellent:
        return '🌟';
      case FinancialHealth.good:
        return '✅';
      case FinancialHealth.fair:
        return '⚠️';
      case FinancialHealth.poor:
        return '🔴';
      case FinancialHealth.critical:
        return '🚨';
    }
  }
}

/// Spending insight for the month
@freezed
class SpendingInsight with _$SpendingInsight {
  const factory SpendingInsight({
    required String id,
    required String title,
    required String description,
    required String emoji,
    required InsightType type,
    @Default(0) double amount,
    @Default('') String category,
    @Default('') String actionText,
  }) = _SpendingInsight;

  factory SpendingInsight.fromJson(Map<String, dynamic> json) =>
      _$SpendingInsightFromJson(json);
}

enum InsightType {
  @JsonValue('positive')
  positive,
  @JsonValue('warning')
  warning,
  @JsonValue('tip')
  tip,
  @JsonValue('achievement')
  achievement,
}

/// Suggestion for leftover money
@freezed
class LeftoverSuggestion with _$LeftoverSuggestion {
  const LeftoverSuggestion._();

  const factory LeftoverSuggestion({
    required String id,
    required LeftoverAction action,
    required String title,
    required String description,
    required double suggestedAmount,
    required int priority, // 1 = highest
    @Default('💰') String emoji,
    @Default(false) bool isSelected,
  }) = _LeftoverSuggestion;

  factory LeftoverSuggestion.fromJson(Map<String, dynamic> json) =>
      _$LeftoverSuggestionFromJson(json);

  /// Get action text for button
  String get actionButtonText {
    switch (action) {
      case LeftoverAction.save:
        return 'Add to Savings';
      case LeftoverAction.invest:
        return 'Start Investing';
      case LeftoverAction.emergency:
        return 'Build Emergency Fund';
      case LeftoverAction.debt:
        return 'Pay Down Debt';
      case LeftoverAction.rollover:
        return 'Roll Over';
      case LeftoverAction.treat:
        return 'Treat Yourself';
    }
  }
}

/// User's leftover allocation decision
@freezed
class LeftoverAllocation with _$LeftoverAllocation {
  const factory LeftoverAllocation({
    required String id,
    required String userId,
    required String summaryId,
    required LeftoverAction action,
    required double amount,
    @TimestampDateTimeConverter() required DateTime allocatedAt,
    @Default('') String note,
  }) = _LeftoverAllocation;

  factory LeftoverAllocation.fromJson(Map<String, dynamic> json) =>
      _$LeftoverAllocationFromJson(json);
}
