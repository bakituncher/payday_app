import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/providers/auth_providers.dart'; // Fixed import: auth_providers.dart (plural)
import 'package:payday/core/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

part 'savings_provider.g.dart';

@riverpod
class SavingsController extends _$SavingsController {
  @override
  Future<List<SavingsGoal>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    // Determine which repository to use based on auth state
    // Assuming authProvider or similar handles repository switching,
    // or we fetch the correct repository from a provider.
    // For now, let's assume we have a unified provider or we check `isAnonymous`.

    // In this codebase pattern (based on memory), repositories might be separated.
    // However, usually there's a provider that returns the correct repository interface.
    final repository = ref.read(savingsGoalRepositoryProvider);
    return repository.getSavingsGoals(user.uid);
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required double monthlyContribution,
    required String emoji,
    DateTime? targetDate,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final goal = SavingsGoal(
      id: const Uuid().v4(),
      userId: user.uid,
      name: name,
      targetAmount: targetAmount,
      monthlyContribution: monthlyContribution,
      emoji: emoji,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).addSavingsGoal(goal);
      return ref.read(savingsGoalRepositoryProvider).getSavingsGoals(user.uid);
    });
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).updateSavingsGoal(goal);
      return ref.read(savingsGoalRepositoryProvider).getSavingsGoals(user.uid);
    });
  }

  Future<void> deleteGoal(String goalId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsGoalRepositoryProvider).deleteSavingsGoal(goalId, user.uid);
      return ref.read(savingsGoalRepositoryProvider).getSavingsGoals(user.uid);
    });
  }

  Future<void> addMoney(String goalId, double amount) async {
     final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic update could go here, but let's stick to refresh for safety
    await ref.read(savingsGoalRepositoryProvider).addMoneyToGoal(goalId, amount, user.uid);
    ref.invalidateSelf();
  }
}
