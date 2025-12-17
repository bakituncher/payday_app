/// Upcoming Bills Card Widget
/// Displays bills due within the next 7 days
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';

class UpcomingBillsCard extends ConsumerWidget {
  const UpcomingBillsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsDueAsync = ref.watch(subscriptionsDueSoonProvider);
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Upcoming Bills',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
              Text(
                'Next 7 days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Bills List
          subscriptionsDueAsync.when(
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(context, error),
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: [
                  ...subscriptions.take(3).map((subscription) {
                    final daysUntil = subscription.daysUntilBilling;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Center(
                              child: Text(
                                subscription.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subscription.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(context),
                                  ),
                                ),
                                Text(
                                  _getDueDateText(daysUntil),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: daysUntil <= 2
                                        ? AppColors.warning
                                        : AppColors.getTextSecondary(context),
                                    fontWeight: daysUntil <= 2
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount
                          Text(
                            CurrencyFormatter.format(subscription.amount, currencyCode),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (subscriptions.length > 3)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Navigate to all upcoming bills
                      },
                      child: Text(
                        '+${subscriptions.length - 3} more bills',
                        style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDueDateText(int daysUntil) {
    if (daysUntil < 0) return 'Overdue!';
    if (daysUntil == 0) return 'Due today';
    if (daysUntil == 1) return 'Due tomorrow';
    return 'Due in $daysUntil days';
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Text(
        'Could not load upcoming bills',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.getTextSecondary(context),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'No bills due in the next 7 days',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

