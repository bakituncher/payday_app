/// Savings providers for managing savings goals
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';

/// Provider for all savings goals
final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid;

  if (userId == null) {
    yield [];
    return;
  }

  final repository = ref.watch(savingsGoalRepositoryProvider);

  // For Firebase, we'd use a stream. For now, periodic refresh
  while (true) {
    try {
      final goals = await repository.getSavingsGoals(userId);
      yield goals;
    } catch (e) {
      yield [];
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

/// Provider for total savings amount across all goals
final totalSavingsProvider = Provider<double>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);
  return goalsAsync.when(
    data: (goals) => goals.fold(0.0, (sum, goal) => sum + goal.currentAmount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for total target amount across all goals
final totalTargetProvider = Provider<double>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);
  return goalsAsync.when(
    data: (goals) => goals.fold(0.0, (sum, goal) => sum + goal.targetAmount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider for active (non-completed) savings goals
final activeSavingsGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);
  return goalsAsync.when(
    data: (goals) => goals.where((g) => !g.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for completed savings goals
final completedSavingsGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);
  return goalsAsync.when(
    data: (goals) => goals.where((g) => g.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for total auto-transfer amount per payday
final totalAutoTransferAmountProvider = Provider<double>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);
  return goalsAsync.when(
    data: (goals) => goals
        .where((g) => g.autoTransferEnabled && !g.isCompleted)
        .fold(0.0, (sum, goal) => sum + goal.autoTransferAmount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

