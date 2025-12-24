/// Budget Goal model for managing spending limits by category
/// Helps users set and track monthly spending goals
import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters/timestamp_converter.dart';

part 'budget_goal.freezed.dart';
part 'budget_goal.g.dart';

/// Budget period type
enum BudgetPeriod {
  @JsonValue('weekly')
  weekly,
  @JsonValue('biweekly')
  biweekly,
  @JsonValue('monthly')
  monthly,
}

/// Budget status
enum BudgetStatus {
  @JsonValue('on_track')
  onTrack, // Under 80% of limit
  @JsonValue('warning')
  warning, // 80-100% of limit
  @JsonValue('exceeded')
  exceeded, // Over limit
}

@freezed
class BudgetGoal with _$BudgetGoal {
  const BudgetGoal._();

  const factory BudgetGoal({
    required String id,
    required String userId,
    required String categoryId,
    required String categoryName,
    required String categoryEmoji,
    required double limitAmount,
    required double spentAmount,
    required BudgetPeriod period,
    @Default(true) bool isActive,
    @Default(true) bool notifyOnWarning,
    @Default(80) int warningThreshold, // Percentage
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  }) = _BudgetGoal;

  factory BudgetGoal.fromJson(Map<String, dynamic> json) =>
      _$BudgetGoalFromJson(json);

  /// Calculate remaining amount
  double get remainingAmount => (limitAmount - spentAmount).clamp(0, limitAmount);

  /// Calculate percentage used
  double get percentageUsed {
    if (limitAmount <= 0) return 0;
    return (spentAmount / limitAmount * 100).clamp(0, 200);
  }

  /// Get current status
  BudgetStatus get status {
    if (percentageUsed >= 100) return BudgetStatus.exceeded;
    if (percentageUsed >= warningThreshold) return BudgetStatus.warning;
    return BudgetStatus.onTrack;
  }

  /// Check if should notify
  bool get shouldNotify => notifyOnWarning && percentageUsed >= warningThreshold;

  /// Get status text
  String get statusText {
    switch (status) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.warning:
        return 'Almost at limit';
      case BudgetStatus.exceeded:
        return 'Over budget';
    }
  }

  /// Get status emoji
  String get statusEmoji {
    switch (status) {
      case BudgetStatus.onTrack:
        return '✅';
      case BudgetStatus.warning:
        return '⚠️';
      case BudgetStatus.exceeded:
        return '🚨';
    }
  }
}

/// Predefined budget templates for quick setup
class BudgetTemplates {
  static List<Map<String, dynamic>> get templates => [
    // 50/30/20 Rule
    {
      'name': '50/30/20 Rule',
      'description': '50% needs, 30% wants, 20% savings',
      'categories': [
        {'category': 'Housing', 'percentage': 25, 'emoji': '🏠'},
        {'category': 'Food & Groceries', 'percentage': 15, 'emoji': '🛒'},
        {'category': 'Transportation', 'percentage': 10, 'emoji': '🚗'},
        {'category': 'Entertainment', 'percentage': 10, 'emoji': '🎬'},
        {'category': 'Shopping', 'percentage': 10, 'emoji': '🛍️'},
        {'category': 'Dining Out', 'percentage': 10, 'emoji': '🍽️'},
        {'category': 'Savings', 'percentage': 20, 'emoji': '💰'},
      ],
    },
    // Zero-Based Budget
    {
      'name': 'Zero-Based Budget',
      'description': 'Every dollar has a purpose',
      'categories': [
        {'category': 'Housing', 'percentage': 30, 'emoji': '🏠'},
        {'category': 'Food', 'percentage': 15, 'emoji': '🛒'},
        {'category': 'Transportation', 'percentage': 10, 'emoji': '🚗'},
        {'category': 'Utilities', 'percentage': 10, 'emoji': '💡'},
        {'category': 'Insurance', 'percentage': 10, 'emoji': '🛡️'},
        {'category': 'Personal', 'percentage': 10, 'emoji': '👤'},
        {'category': 'Savings', 'percentage': 15, 'emoji': '💰'},
      ],
    },
    // Minimalist Budget
    {
      'name': 'Minimalist',
      'description': 'Focus on essentials and saving',
      'categories': [
        {'category': 'Essentials', 'percentage': 50, 'emoji': '📦'},
        {'category': 'Lifestyle', 'percentage': 20, 'emoji': '✨'},
        {'category': 'Savings', 'percentage': 30, 'emoji': '💰'},
      ],
    },
  ];
}
