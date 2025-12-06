/// Active Subscriptions Preview Card for Home Screen
/// Shows a summary of subscriptions and upcoming bills
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday_flutter/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:intl/intl.dart';

class ActiveSubscriptionsCard extends ConsumerWidget {
  const ActiveSubscriptionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final totalMonthlyCostAsync = ref.watch(totalMonthlyCostProvider);
    final subscriptionsDueAsync = ref.watch(subscriptionsDueSoonProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
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
                        Icons.subscriptions_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Subscriptions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
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

            // Stats Row
            Row(
              children: [
                // Monthly Total
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        totalMonthlyCostAsync.when(
                          loading: () => Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          error: (_, __) => Text(
                            '\$0.00',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          data: (cost) => Text(
                            currencyFormat.format(cost),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Active Count
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        subscriptionsAsync.when(
                          loading: () => Container(
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          error: (_, __) => Text(
                            '0',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          data: (subs) => Text(
                            '${subs.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Due Soon
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Soon',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        subscriptionsDueAsync.when(
                          loading: () => Container(
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          error: (_, __) => Text(
                            '0',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                          data: (subs) => Text(
                            '${subs.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Upcoming Bills Preview
            subscriptionsDueAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (dueSoon) {
                if (dueSoon.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Coming up',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...dueSoon.take(2).map((sub) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Row(
                        children: [
                          Text(sub.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sub.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${sub.daysUntilBilling}d',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: sub.daysUntilBilling <= 2
                                  ? AppColors.warning
                                  : AppColors.mediumGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currencyFormat.format(sub.amount),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

