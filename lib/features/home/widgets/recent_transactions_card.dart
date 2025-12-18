/// Recent Transactions Card - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/transactions/screens/all_transactions_screen.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecentTransactionsCard extends ConsumerWidget {
  final String currency;

  const RecentTransactionsCard({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(currentCycleTransactionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondaryPurple.withValues(alpha: 0.15),
                            AppColors.primaryPink.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.secondaryPurple,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Recent',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllTransactionsScreen(currency: currency),
                      ),
                    );
                  },
                  child: Text(
                    'See All',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Transactions List
            transactionsAsync.when(
              loading: () => _buildShimmerList(context),
              error: (error, stack) => _buildError(theme),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return _buildEmptyState(context, theme);
                }

                // Show only last 3 transactions for compact view
                final recentTransactions = transactions.take(3).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return _TransactionTile(
                      transaction: transaction,
                      currency: currency,
                      onDelete: () => _deleteTransaction(context, ref, transaction),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 20,
            color: AppColors.getTextSecondary(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'No transactions yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 14,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      )),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.getBorder(context));
  }

  Widget _buildError(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Error loading',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Delete Transaction?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this ${transaction.categoryName} expense of ${CurrencyFormatter.format(transaction.amount, currency)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.mediumGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(transactionRepositoryProvider);
        // Pass userId from transaction object
        await repository.deleteTransaction(transaction.id, transaction.userId);

        // Update current balance - add back the deleted expense
        final settingsRepo = ref.read(userSettingsRepositoryProvider);
        final currentSettings = await ref.read(userSettingsProvider.future);
        if (currentSettings != null && transaction.isExpense) {
          final updatedSettings = currentSettings.copyWith(
            currentBalance: currentSettings.currentBalance + transaction.amount,
            updatedAt: DateTime.now(),
          );
          await settingsRepo.saveUserSettings(updatedSettings);
        }

        // Refresh data
        ref.invalidate(userSettingsProvider);
        ref.invalidate(currentCycleTransactionsProvider);
        ref.invalidate(totalExpensesProvider);
        ref.invalidate(dailyAllowableSpendProvider);
        ref.invalidate(budgetHealthProvider);
        ref.invalidate(currentMonthlySummaryProvider);

        if (context.mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('${transaction.categoryEmoji} Transaction deleted'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Let onDelete handle the actual deletion
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ),
      child: GestureDetector(
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Emoji Icon - Compact
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    transaction.categoryEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Details - Compact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.categoryName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      _formatDate(transaction.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount - Compact
              Text(
                '-${CurrencyFormatter.format(transaction.amount, currency)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

