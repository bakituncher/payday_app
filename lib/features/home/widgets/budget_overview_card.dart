import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/features/home/providers/home_providers.dart';

/// Daily budget + overall budget'ı tek, kompakt bir kartta gösterir.
///
/// Hedef: ana ekranda dikey alanı koruyup (yer tasarrufu) yine de kritik metrikleri kaybetmemek.
class BudgetOverviewCard extends ConsumerWidget {
  final String currency;
  final double currentBalance;

  const BudgetOverviewCard({
    super.key,
    required this.currency,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final dailySpendAsync = ref.watch(dailyAllowableSpendProvider);
    final totalExpensesAsync = ref.watch(totalExpensesProvider);
    final health = ref.watch(budgetHealthProvider).value ?? BudgetHealth.unknown;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
        border: Border.all(
          color: AppColors.getBorder(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: totalExpensesAsync.when(
        loading: () => _buildSkeleton(context),
        error: (_, __) => _buildSkeleton(context),
        data: (totalExpenses) {
          final totalBudget = currentBalance + totalExpenses;
          final progress = totalBudget > 0 ? (totalExpenses / totalBudget).clamp(0.0, 1.0) : 0.0;
          final progressColor = _getProgressColor(health);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Sol: icon + "Budget"
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryPink.withValues(alpha: 0.14),
                                AppColors.secondaryPurple.withValues(alpha: 0.10),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 16,
                            color: AppColors.primaryPink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Budget',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sağ: Daily chip + health badge (aynı hizada)
                  _DailyChip(
                    currency: currency,
                    dailySpendAsync: dailySpendAsync,
                    compact: true,
                  ),
                  const SizedBox(width: 8),
                  _HealthBadge(health: health),
                ],
              ),

              const SizedBox(height: 10),

              // Ana satır: sadece Spent / Left (daha geniş)
              Row(
                children: [
                  Expanded(
                    child: _MetricPill(
                      label: 'Spent',
                      value: CurrencyFormatter.format(totalExpenses, currency),
                      tint: AppColors.primaryPink,
                      emphasize: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricPill(
                      label: 'Left',
                      value: CurrencyFormatter.format(currentBalance, currency),
                      tint: currentBalance >= 0 ? AppColors.success : AppColors.error,
                      emphasize: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.round),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: progress,
                  backgroundColor: AppColors.getSurfaceVariant(context),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% used',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${(100 - progress * 100).toInt()}% left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 90,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.getSubtle(context),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 90,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.getSubtle(context),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 56,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.getSubtle(context),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _MetricPill(label: 'Spent', value: '—', tint: AppColors.primaryPink, isSkeleton: true, emphasize: true)),
            const SizedBox(width: 10),
            Expanded(child: _MetricPill(label: 'Left', value: '—', tint: AppColors.success, isSkeleton: true, emphasize: true)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.round),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: null,
            backgroundColor: AppColors.getSurfaceVariant(context),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.getBorder(context).withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }
}

class _DailyChip extends StatelessWidget {
  final String currency;
  final AsyncValue<double> dailySpendAsync;
  final bool compact;

  const _DailyChip({
    required this.currency,
    required this.dailySpendAsync,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final value = dailySpendAsync.when(
      loading: () => '—',
      error: (_, __) => '—',
      data: (v) => CurrencyFormatter.format(v.abs(), currency),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        // ✅ biraz büyüttük: badge ile aynı boya yaklaşsın
        horizontal: compact ? 9 : 10,
        vertical: compact ? 7 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(
          color: AppColors.secondaryPurple.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: compact ? 13 : 14,
            color: AppColors.secondaryPurple,
          ),
          const SizedBox(width: 6),
          Text(
            'Daily',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: (compact ? theme.textTheme.labelMedium : theme.textTheme.labelLarge)?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.secondaryPurple,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;
  final bool isSkeleton;
  final bool emphasize;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.tint,
    this.isSkeleton = false,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = AppColors.getSurfaceVariant(context);
    final border = tint.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (emphasize ? theme.textTheme.titleSmall : theme.textTheme.labelLarge)?.copyWith(
                fontWeight: FontWeight.w900,
                color: isSkeleton ? AppColors.getTextSecondary(context).withValues(alpha: 0.6) : tint,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final BudgetHealth health;

  const _HealthBadge({required this.health});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      // ✅ Great/Badge'i bir tık büyüttük
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
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
