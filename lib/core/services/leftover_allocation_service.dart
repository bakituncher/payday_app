/// Leftover Allocation Service
/// Handles the actual allocation of leftover money to different purposes
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/repositories/savings_goal_repository.dart';
import 'package:payday/core/repositories/monthly_summary_repository.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';

class LeftoverAllocationService {
  final SavingsGoalRepository _savingsGoalRepository;
  // ignore: unused_field - Will be used for monthly summary finalization in future
  final MonthlySummaryRepository _monthlySummaryRepository;
  final UserSettingsRepository _userSettingsRepository;

  LeftoverAllocationService({
    required SavingsGoalRepository savingsGoalRepository,
    required MonthlySummaryRepository monthlySummaryRepository,
    required UserSettingsRepository userSettingsRepository,
  })  : _savingsGoalRepository = savingsGoalRepository,
        _monthlySummaryRepository = monthlySummaryRepository,
        _userSettingsRepository = userSettingsRepository;

  /// Process leftover allocation based on action type
  Future<AllocationResult> processAllocation({
    required String userId,
    required String summaryId,
    required LeftoverAction action,
    required double amount,
    String? targetGoalId,
    String? note,
  }) async {
    try {
      switch (action) {
        case LeftoverAction.save:
          return await _allocateToSavings(userId, amount, targetGoalId);

        case LeftoverAction.emergency:
          return await _allocateToEmergencyFund(userId, amount);

        case LeftoverAction.invest:
          return await _allocateToInvestment(userId, amount);

        case LeftoverAction.debt:
          return await _allocateToDebt(userId, amount);

        case LeftoverAction.rollover:
          return await _rolloverToNextMonth(userId, amount);

        case LeftoverAction.treat:
          return await _allocateToTreat(userId, amount);
      }
    } catch (e) {
      return AllocationResult(
        success: false,
        message: 'Failed to allocate: ${e.toString()}',
        action: action,
        amount: amount,
      );
    }
  }

  /// Allocate to general savings or specific savings goal
  Future<AllocationResult> _allocateToSavings(
    String userId,
    double amount,
    String? targetGoalId,
  ) async {
    if (targetGoalId != null) {
      // Add to specific savings goal
      await _savingsGoalRepository.addMoneyToGoal(targetGoalId, amount, userId);
      return AllocationResult(
        success: true,
        message: 'Added \$${amount.toStringAsFixed(2)} to your savings goal',
        action: LeftoverAction.save,
        amount: amount,
      );
    } else {
      // Create a general savings entry or add to default savings goal
      final goals = await _savingsGoalRepository.getSavingsGoals(userId);

      if (goals.isEmpty) {
        // Create a default savings goal
        final newGoal = SavingsGoal(
          id: 'savings_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          name: 'General Savings',
          targetAmount: 10000, // Default target
          currentAmount: amount,
          emoji: '💰',
          createdAt: DateTime.now(),
        );
        await _savingsGoalRepository.addSavingsGoal(newGoal);
        return AllocationResult(
          success: true,
          message: 'Created savings goal with \$${amount.toStringAsFixed(2)}',
          action: LeftoverAction.save,
          amount: amount,
          createdGoalId: newGoal.id,
        );
      } else {
        // Add to first (most recent) savings goal
        await _savingsGoalRepository.addMoneyToGoal(goals.first.id, amount, userId);
        return AllocationResult(
          success: true,
          message: 'Added \$${amount.toStringAsFixed(2)} to ${goals.first.name}',
          action: LeftoverAction.save,
          amount: amount,
        );
      }
    }
  }

  /// Allocate to emergency fund
  Future<AllocationResult> _allocateToEmergencyFund(
    String userId,
    double amount,
  ) async {
    // Look for existing emergency fund goal
    final goals = await _savingsGoalRepository.getSavingsGoals(userId);
    final emergencyFund = goals.where(
      (g) => g.name.toLowerCase().contains('emergency'),
    ).firstOrNull;

    if (emergencyFund != null) {
      await _savingsGoalRepository.addMoneyToGoal(emergencyFund.id, amount, userId);
      return AllocationResult(
        success: true,
        message: 'Added \$${amount.toStringAsFixed(2)} to Emergency Fund',
        action: LeftoverAction.emergency,
        amount: amount,
      );
    } else {
      // Create emergency fund goal (target: 6 months of expenses)
      final settings = await _userSettingsRepository.getUserSettings(userId);
      final targetAmount = (settings?.incomeAmount ?? 3000) * 6;

      final newGoal = SavingsGoal(
        id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: 'Emergency Fund',
        targetAmount: targetAmount,
        currentAmount: amount,
        emoji: '🛡️',
        createdAt: DateTime.now(),
      );
      await _savingsGoalRepository.addSavingsGoal(newGoal);
      return AllocationResult(
        success: true,
        message: 'Created Emergency Fund with \$${amount.toStringAsFixed(2)}',
        action: LeftoverAction.emergency,
        amount: amount,
        createdGoalId: newGoal.id,
      );
    }
  }

  /// Allocate to investment
  Future<AllocationResult> _allocateToInvestment(
    String userId,
    double amount,
  ) async {
    // Look for existing investment goal
    final goals = await _savingsGoalRepository.getSavingsGoals(userId);
    final investmentGoal = goals.where(
      (g) => g.name.toLowerCase().contains('invest'),
    ).firstOrNull;

    if (investmentGoal != null) {
      await _savingsGoalRepository.addMoneyToGoal(investmentGoal.id, amount, userId);
      return AllocationResult(
        success: true,
        message: 'Added \$${amount.toStringAsFixed(2)} to Investment Fund',
        action: LeftoverAction.invest,
        amount: amount,
      );
    } else {
      // Create investment goal
      final newGoal = SavingsGoal(
        id: 'invest_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: 'Investment Fund',
        targetAmount: 50000, // Default target
        currentAmount: amount,
        emoji: '📈',
        createdAt: DateTime.now(),
      );
      await _savingsGoalRepository.addSavingsGoal(newGoal);
      return AllocationResult(
        success: true,
        message: 'Created Investment Fund with \$${amount.toStringAsFixed(2)}',
        action: LeftoverAction.invest,
        amount: amount,
        createdGoalId: newGoal.id,
      );
    }
  }

  /// Allocate to debt payment tracking
  Future<AllocationResult> _allocateToDebt(
    String userId,
    double amount,
  ) async {
    // Look for existing debt payoff goal
    final goals = await _savingsGoalRepository.getSavingsGoals(userId);
    final debtGoal = goals.where(
      (g) => g.name.toLowerCase().contains('debt'),
    ).firstOrNull;

    if (debtGoal != null) {
      await _savingsGoalRepository.addMoneyToGoal(debtGoal.id, amount, userId);
      return AllocationResult(
        success: true,
        message: 'Allocated \$${amount.toStringAsFixed(2)} to Debt Payoff',
        action: LeftoverAction.debt,
        amount: amount,
      );
    } else {
      // Create debt payoff tracking goal
      final newGoal = SavingsGoal(
        id: 'debt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: 'Debt Payoff Fund',
        targetAmount: 5000, // Default, user should update
        currentAmount: amount,
        emoji: '💳',
        createdAt: DateTime.now(),
      );
      await _savingsGoalRepository.addSavingsGoal(newGoal);
      return AllocationResult(
        success: true,
        message: 'Created Debt Payoff Fund with \$${amount.toStringAsFixed(2)}',
        action: LeftoverAction.debt,
        amount: amount,
        createdGoalId: newGoal.id,
      );
    }
  }

  /// Roll over to next month budget
  Future<AllocationResult> _rolloverToNextMonth(
    String userId,
    double amount,
  ) async {
    // Yeni mantık: hiçbir transfer veya SavingsGoal işlemi yapma.
    // Para cüzdanda kalır ve ledger/PeriodBalanceService ile otomatik devreder.
    return AllocationResult(
      success: true,
      message: '${amount.toStringAsFixed(2)} bir sonraki aya devredildi.',
      action: LeftoverAction.rollover,
      amount: amount,
    );
  }

  /// Allocate as treat/reward
  Future<AllocationResult> _allocateToTreat(
    String userId,
    double amount,
  ) async {
    // Look for existing fun/treat fund
    final goals = await _savingsGoalRepository.getSavingsGoals(userId);
    final treatGoal = goals.where(
      (g) => g.name.toLowerCase().contains('treat') ||
             g.name.toLowerCase().contains('fun') ||
             g.name.toLowerCase().contains('reward'),
    ).firstOrNull;

    if (treatGoal != null) {
      await _savingsGoalRepository.addMoneyToGoal(treatGoal.id, amount, userId);
      return AllocationResult(
        success: true,
        message: 'Added \$${amount.toStringAsFixed(2)} to Fun Fund',
        action: LeftoverAction.treat,
        amount: amount,
      );
    } else {
      final newGoal = SavingsGoal(
        id: 'treat_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: 'Treat Yourself Fund',
        targetAmount: 500, // Small fun fund
        currentAmount: amount,
        emoji: '🎁',
        createdAt: DateTime.now(),
      );
      await _savingsGoalRepository.addSavingsGoal(newGoal);
      return AllocationResult(
        success: true,
        message: 'Created Fun Fund with \$${amount.toStringAsFixed(2)}',
        action: LeftoverAction.treat,
        amount: amount,
        createdGoalId: newGoal.id,
      );
    }
  }
}

/// Result of an allocation operation
class AllocationResult {
  final bool success;
  final String message;
  final LeftoverAction action;
  final double amount;
  final String? createdGoalId;
  final String? error;

  const AllocationResult({
    required this.success,
    required this.message,
    required this.action,
    required this.amount,
    this.createdGoalId,
    this.error,
  });
}
