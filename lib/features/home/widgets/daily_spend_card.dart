/// Daily Allowable Spend Card - Premium Compact Design
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/utils/currency_formatter.dart';
import 'package:payday_flutter/features/home/providers/home_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailySpendCard extends ConsumerWidget {
  const DailySpendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailySpendAsync = ref.watch(dailyAllowableSpendProvider);
    final userSettings = ref.watch(userSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: dailySpendAsync.when(
          loading: () => _buildShimmer(),
          error: (error, stack) => _buildError(theme),
          data: (dailySpend) {
            final currency = userSettings.value?.currency ?? 'USD';
            final isPositive = dailySpend > 0;
            final statusColor = isPositive ? AppColors.success : AppColors.error;
            final statusBgColor = isPositive ? AppColors.successLight : AppColors.errorLight;

            return Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPositive
                          ? [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.05)]
                          : [AppColors.error.withOpacity(0.2), AppColors.error.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    isPositive ? Icons.account_balance_wallet_rounded : Icons.warning_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daily Budget',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.format(dailySpend.abs(), currency),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPositive ? 'available' : 'over',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isPositive ? 'On Track' : 'Over',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.subtleGray,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 12,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 20,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.lightGray);
  }

  Widget _buildError(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Unable to load',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

