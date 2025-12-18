/// Savings Goal model
import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

@freezed
class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required String id,
    required String userId,
    required String name,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    @Default(0.0) double monthlyContribution,
    required String emoji,
    required DateTime createdAt,
    DateTime? targetDate,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}

extension SavingsGoalExtension on SavingsGoal {
  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = (currentAmount / targetAmount) * 100;
    return progress.clamp(0.0, 100.0);
  }

  /// Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  /// Calculate remaining amount
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }
}
