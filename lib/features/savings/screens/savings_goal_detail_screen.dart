/// Savings Goal Detail Screen - View and manage individual goal
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/savings/providers/savings_providers.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:payday/core/services/currency_service.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

class SavingsGoalDetailScreen extends ConsumerStatefulWidget {
  final SavingsGoal goal;

  const SavingsGoalDetailScreen({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<SavingsGoalDetailScreen> createState() =>
      _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends ConsumerState<SavingsGoalDetailScreen> {
  late SavingsGoal _currentGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
  }

  Future<void> _addMoney() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _AddMoneyDialog(controller: controller),
    );

    if (result != null && result > 0) {
      setState(() => _isLoading = true);
      try {
        final savingsRepository = ref.read(savingsGoalRepositoryProvider);
        final transactionManager = ref.read(transactionManagerServiceProvider);

        // STEP 1: Add money to the savings goal (this changes the savings balance)
        await savingsRepository.addMoneyToGoal(
          _currentGoal.id,
          result,
          _currentGoal.userId,
        );

        try {
          // STEP 2: Create an expense transaction to deduct from budget
          // If this fails, we need to rollback the savings update
          final transaction = Transaction(
            id: const Uuid().v4(),
            userId: _currentGoal.userId,
            amount: result,
            categoryId: AppConstants.savingsCategoryId,
            categoryName: 'Savings Transfer',
            categoryEmoji: _currentGoal.emoji,
            date: DateTime.now(),
            note: 'Transfer to ${_currentGoal.name}',
            isExpense: true, // Budget'ten düş
            relatedGoalId: _currentGoal.id,
          );

          // TransactionManager: hem transaction kaydı hem bakiye güncellemesi
          await transactionManager.processTransaction(
            userId: _currentGoal.userId,
            transaction: transaction,
          );

          // SUCCESS: Both operations completed, update UI
          ref.invalidate(currentCycleTransactionsProvider);
          ref.invalidate(userSettingsProvider);

          setState(() {
            _currentGoal = _currentGoal.copyWith(
              currentAmount: _currentGoal.currentAmount + result,
            );
          });

          if (mounted) {
            // 3️⃣ REKLAM GÖSTERİMİ (Premium Değilse)
            if (!ref.read(isPremiumProvider)) {
              AdService().showInterstitial(3);
            }

            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${_formatCurrency(result)} added to savings'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (transactionError) {
          // ROLLBACK: Transaction creation failed, undo the savings update
          print('⚠️ Transaction creation failed, rolling back savings update...');
          try {
            await savingsRepository.withdrawMoneyFromGoal(
              _currentGoal.id,
              result,
              _currentGoal.userId,
            );
            print('✅ Rollback successful');
          } catch (rollbackError) {
            print('❌ CRITICAL: Rollback failed! Data inconsistency possible: $rollbackError');
          }
          throw transactionError;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: Failed to add money. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        print('Error in _addMoney: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _withdrawMoney() async {
    // Get the latest goal data for max amount
    final goalsAsync = ref.read(savingsGoalsProvider);
    final currentGoalData = goalsAsync.whenOrNull(
          data: (goals) {
            try {
              return goals.firstWhere((g) => g.id == widget.goal.id);
            } catch (e) {
              return _currentGoal;
            }
          },
        ) ??
        _currentGoal;

    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _WithdrawMoneyDialog(
        controller: controller,
        maxAmount: currentGoalData.currentAmount,
      ),
    );

    if (result != null && result > 0) {
      setState(() => _isLoading = true);
      try {
        final savingsRepository = ref.read(savingsGoalRepositoryProvider);
        final transactionManager = ref.read(transactionManagerServiceProvider);

        // STEP 1: Withdraw money from the savings goal
        await savingsRepository.withdrawMoneyFromGoal(
          _currentGoal.id,
          result,
          _currentGoal.userId,
        );

        try {
          // STEP 2: Create an income transaction to add back to budget
          // If this fails, we need to rollback the savings update
          final transaction = Transaction(
            id: const Uuid().v4(),
            userId: _currentGoal.userId,
            amount: result,
            categoryId: AppConstants.savingsCategoryId,
            categoryName: 'Savings Transfer',
            categoryEmoji: _currentGoal.emoji,
            date: DateTime.now(),
            note: 'Withdrawal from ${_currentGoal.name}',
            isExpense: false, // Budget'e geri ekle
            relatedGoalId: _currentGoal.id,
          );

          // TransactionManager: hem transaction kaydı hem bakiye güncellemesi
          await transactionManager.processTransaction(
            userId: _currentGoal.userId,
            transaction: transaction,
          );

          // SUCCESS: Both operations completed, update UI
          ref.invalidate(currentCycleTransactionsProvider);
          ref.invalidate(userSettingsProvider);

          setState(() {
            _currentGoal = _currentGoal.copyWith(
              currentAmount: _currentGoal.currentAmount - result,
            );
          });

          if (mounted) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${_formatCurrency(result)} withdrawn'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        } catch (transactionError) {
          // ROLLBACK: Transaction creation failed, undo the savings withdrawal
          print('⚠️ Transaction creation failed, rolling back savings withdrawal...');
          try {
            await savingsRepository.addMoneyToGoal(
              _currentGoal.id,
              result,
              _currentGoal.userId,
            );
            print('✅ Rollback successful');
          } catch (rollbackError) {
            print('❌ CRITICAL: Rollback failed! Data inconsistency possible: $rollbackError');
          }
          throw transactionError;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: Failed to withdraw money. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        print('Error in _withdrawMoney: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete this goal?\n\nAccumulated amount: ${_formatCurrency(_currentGoal.currentAmount)}\n\n(This amount will be returned to your budget)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete & Refund'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final repository = ref.read(savingsGoalRepositoryProvider);
        final transactionManager = ref.read(transactionManagerServiceProvider);

        // ADIM 1: Eğer hedefte para varsa, önce bunu bütçeye geri ekle (Transaction oluştur)
        if (_currentGoal.currentAmount > 0) {
          final refundTransaction = Transaction(
            id: const Uuid().v4(),
            userId: _currentGoal.userId,
            amount: _currentGoal.currentAmount,
            categoryId: AppConstants.savingsCategoryId,
            categoryName: 'Savings Closure',
            categoryEmoji: _currentGoal.emoji,
            date: DateTime.now(),
            note: 'Refund from deleted goal: ${_currentGoal.name}',
            isExpense: false, // Gelir olarak ekle (Bütçeye geri dönüş)
            relatedGoalId: _currentGoal.id,
          );

          // Use TransactionManager - Bakiye otomatik güncellenecek
          await transactionManager.processTransaction(
            userId: _currentGoal.userId,
            transaction: refundTransaction,
          );
        }

        // ADIM 2: Hedefi sil
        await repository.deleteSavingsGoal(_currentGoal.id, _currentGoal.userId);

        // Ana sayfadaki işlem listesini yenile
        ref.invalidate(currentCycleTransactionsProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goal deleted and ${_formatCurrency(_currentGoal.currentAmount)} returned to budget'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch the savings goals provider to get live updates
    final goalsAsync = ref.watch(savingsGoalsProvider);

    // Find the current goal from the live data, fallback to _currentGoal if not found
    final liveGoal = goalsAsync.whenOrNull(
      data: (goals) {
        try {
          return goals.firstWhere((g) => g.id == widget.goal.id);
        } catch (e) {
          // Goal might be deleted or not found
          return _currentGoal;
        }
      },
    ) ?? _currentGoal;

    // Use liveGoal instead of _currentGoal for rendering
    // This ensures UI is always in sync with the repository

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _deleteGoal,
            color: AppColors.error,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: liveGoal.isCompleted
                  ? AppColors.successGradient
                  : AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: (liveGoal.isCompleted
                      ? AppColors.success
                      : AppColors.primaryPink)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Emoji
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      liveGoal.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  liveGoal.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (liveGoal.isCompleted) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.celebration_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Congratulations! Goal reached',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                // Current Amount
                Text(
                  'Current Amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatCurrency(liveGoal.currentAmount),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Target: ${_formatCurrency(liveGoal.targetAmount)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Progress
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${liveGoal.progressPercentage.toStringAsFixed(0)}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!liveGoal.isCompleted)
                          Text(
                            '${_formatCurrency(liveGoal.remainingAmount)} left',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: liveGoal.progressPercentage / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

          const SizedBox(height: AppSpacing.lg),

          // Auto-transfer Info
          if (liveGoal.autoTransferEnabled && !liveGoal.isCompleted)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Transfer Active',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCurrency(liveGoal.autoTransferAmount)} will be automatically transferred on every payday',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

          if (liveGoal.autoTransferEnabled && !liveGoal.isCompleted)
            const SizedBox(height: AppSpacing.md),

          // Target Date
          if (liveGoal.targetDate != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Target Date: ${_formatDate(liveGoal.targetDate!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, end: 0),

          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          if (!liveGoal.isCompleted) ...[
            Row(
              children: [
                Expanded(
                  child: PaydayButton(
                    text: 'Add Money',
                    onPressed: _isLoading ? null : _addMoney,
                    style: PaydayButtonStyle.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PaydayButton(
                    text: 'Withdraw',
                    onPressed: _isLoading ? null : _withdrawMoney,
                    style: PaydayButtonStyle.secondary,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
          ],

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final currency = userSettingsAsync.when(
      data: (settings) => settings?.currency ?? 'USD',
      loading: () => 'USD',
      error: (_, __) => 'USD',
    );

    final currencyService = CurrencyUtilityService();
    return currencyService.formatAmountWithSeparators(amount, currency, decimals: 0);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _AddMoneyDialog extends ConsumerWidget {
  final TextEditingController controller;

  const _AddMoneyDialog({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final currency = userSettingsAsync.when(
      data: (settings) => settings?.currency ?? 'USD',
      loading: () => 'USD',
      error: (_, __) => 'USD',
    );
    final currencyService = CurrencyUtilityService();
    final currencySymbol = currencyService.getSymbol(currency);

    return AlertDialog(
      title: const Text('Add Money'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Amount',
          prefixText: currencySymbol,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(controller.text);
            Navigator.pop(context, amount);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _WithdrawMoneyDialog extends ConsumerWidget {
  final TextEditingController controller;
  final double maxAmount;

  const _WithdrawMoneyDialog({
    required this.controller,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final currency = userSettingsAsync.when(
      data: (settings) => settings?.currency ?? 'USD',
      loading: () => 'USD',
      error: (_, __) => 'USD',
    );
    final currencyService = CurrencyUtilityService();
    final formattedMax = currencyService.formatAmountWithSeparators(maxAmount, currency);

    return AlertDialog(
      title: const Text('Withdraw Money'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Maximum: $formattedMax',
            style: const TextStyle(color: AppColors.mediumGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Amount',
              prefixText: currencyService.getSymbol(currency),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(controller.text);
            if (amount != null && amount <= maxAmount) {
              Navigator.pop(context, amount);
            }
          },
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}

