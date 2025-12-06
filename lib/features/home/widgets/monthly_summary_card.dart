/// Monthly Summary Preview Card for Home Screen
/// Shows a quick snapshot of current month's financial status
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/models/monthly_summary.dart';
import 'package:payday_flutter/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday_flutter/features/insights/screens/monthly_summary_screen.dart';
import 'package:intl/intl.dart';

class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(currentMonthlySummaryProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.cardShadow,
        ),
        child: summaryAsync.when(
          loading: () => _buildLoadingState(),
          error: (_, __) => _buildErrorState(context),
          data: (summary) {
            if (summary == null) {
              return _buildEmptyState(context);
            }
            return _buildContent(context, summary, currencyFormat);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MonthlySummary summary,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.summarize_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.monthName} Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      'Tap to see details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mediumGray,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Health Status & Savings Rate
        Row(
          children: [
            // Health Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getHealthColor(summary.healthStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Text(
                      summary.healthStatusEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                          Text(
                            summary.healthStatus.name.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _getHealthColor(summary.healthStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Savings Rate
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                          Text(
                            '${summary.savingsRate.toStringAsFixed(0)}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Leftover Amount (if positive)
        if (summary.leftoverAmount > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Left over: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                  ),
                ),
                Text(
                  currencyFormat.format(summary.leftoverAmount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                Text(
                  'Allocate →',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.subtleGray,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.subtleGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Could not load summary',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.summarize_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Text(
                'Start tracking to see your summary',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.mediumGray,
        ),
      ],
    );
  }

  Color _getHealthColor(FinancialHealth health) {
    switch (health) {
      case FinancialHealth.excellent:
        return AppColors.success;
      case FinancialHealth.good:
        return AppColors.info;
      case FinancialHealth.fair:
        return AppColors.warning;
      case FinancialHealth.poor:
      case FinancialHealth.critical:
        return AppColors.error;
    }
  }
}

