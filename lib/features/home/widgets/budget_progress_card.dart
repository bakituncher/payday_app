/// Budget Progress Card - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/utils/currency_formatter.dart';
import 'package:payday_flutter/features/home/providers/home_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BudgetProgressCard extends ConsumerWidget {
  final String currency;
  final double incomeAmount;

  const BudgetProgressCard({
    super.key,
    required this.currency,
    required this.incomeAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalExpensesAsync = ref.watch(totalExpensesProvider);
    final budgetHealthAsync = ref.watch(budgetHealthProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: totalExpensesAsync.when(
          loading: () => _buildShimmer(),
          error: (error, stack) => _buildError(theme),
          data: (totalExpenses) {
            final remaining = incomeAmount - totalExpenses;
            final progressPercentage = (totalExpenses / incomeAmount).clamp(0.0, 1.0);
            final budgetHealth = budgetHealthAsync.value ?? BudgetHealth.unknown;

            return Column(
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
                                AppColors.primaryPink.withOpacity(0.15),
                                AppColors.secondaryPurple.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.pie_chart_rounded,
                            color: AppColors.primaryPink,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Budget',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    _buildHealthBadge(budgetHealth, theme),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Progress Bar with Glow
                _AnimatedProgressBar(
                  progress: progressPercentage,
                  health: budgetHealth,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Percentage indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progressPercentage * 100).toInt()}% used',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(100 - progressPercentage * 100).toInt()}% left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getProgressColor(budgetHealth),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Stats - Compact inline
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Spent',
                        CurrencyFormatter.format(totalExpenses, currency),
                        AppColors.primaryPink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Left',
                        CurrencyFormatter.format(remaining.abs(), currency),
                        remaining > 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.subtleGray,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(BudgetHealth health, ThemeData theme) {
    String text;
    Color color;

    switch (health) {
      case BudgetHealth.excellent:
        text = '✓ Great';
        color = AppColors.success;
        break;
      case BudgetHealth.good:
        text = '✓ Good';
        color = AppColors.info;
        break;
      case BudgetHealth.warning:
        text = '⚠ Caution';
        color = AppColors.warning;
        break;
      case BudgetHealth.danger:
        text = '! Over';
        color = AppColors.error;
        break;
      case BudgetHealth.unknown:
        text = '—';
        color = AppColors.mediumGray;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getProgressColor(BudgetHealth health) {
    switch (health) {
      case BudgetHealth.excellent:
        return AppColors.success;
      case BudgetHealth.good:
        return AppColors.info;
      case BudgetHealth.warning:
        return AppColors.warning;
      case BudgetHealth.danger:
        return AppColors.error;
      case BudgetHealth.unknown:
        return AppColors.mediumGray;
    }
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.subtleGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 18,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.subtleGray,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.subtleGray,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.lightGray);
  }

  Widget _buildError(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Error loading budget',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final BudgetHealth health;

  const _AnimatedProgressBar({
    required this.progress,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getProgressColors(health);

    return Stack(
      children: [
        // Background
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.subtleGray,
            borderRadius: BorderRadius.circular(AppRadius.round),
          ),
        ),
        // Progress
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return FractionallySizedBox(
              widthFactor: value.clamp(0.02, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Color> _getProgressColors(BudgetHealth health) {
    switch (health) {
      case BudgetHealth.excellent:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case BudgetHealth.good:
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
      case BudgetHealth.warning:
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      case BudgetHealth.danger:
        return [const Color(0xFFEF4444), const Color(0xFFF87171)];
      case BudgetHealth.unknown:
        return [AppColors.mediumGray, AppColors.mediumGray.withOpacity(0.7)];
    }
  }
}

