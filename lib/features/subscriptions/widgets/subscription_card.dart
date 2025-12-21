/// Subscription Card Widget
/// Premium subscription item display
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/screens/subscription_detail_screen.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class SubscriptionCard extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionCard({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final daysUntil = subscription.daysUntilBilling;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubscriptionDetailScreen(subscription: subscription),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.getCardShadow(context),
          border: subscription.isDueSoon(3)
              ? Border.all(color: AppColors.warning.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Subscription Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _getCategoryColor(subscription.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  subscription.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Subscription Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subscription.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subscription.status != SubscriptionStatus.active || !subscription.autoRenew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(subscription).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            _getBadgeLabel(subscription),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getBadgeColor(subscription),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subscription.frequencyText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.getBorder(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getDueDateText(daysUntil),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: daysUntil <= 3 ? AppColors.warning : AppColors.getTextSecondary(context),
                          fontWeight: daysUntil <= 3 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(subscription.amount, currencyCode),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                if (subscription.frequency != RecurrenceFrequency.monthly)
                  Text(
                    '${CurrencyFormatter.format(subscription.monthlyCost, currencyCode)}/mo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.xs),

            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightGray,
            ),
          ],
        ),
      ),
    );
  }

  String _getDueDateText(int daysUntil) {
    if (daysUntil < 0) return 'Overdue';
    if (daysUntil == 0) return 'Due today';
    if (daysUntil == 1) return 'Due tomorrow';
    if (daysUntil <= 7) return 'Due in $daysUntil days';
    return 'Due ${DateFormat('MMM d').format(subscription.nextBillingDate)}';
  }

  Color _getCategoryColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return AppColors.primaryPink;
      case SubscriptionCategory.productivity:
        return AppColors.secondaryBlue;
      case SubscriptionCategory.cloudStorage:
        return AppColors.secondaryTeal;
      case SubscriptionCategory.fitness:
        return AppColors.success;
      case SubscriptionCategory.gaming:
        return AppColors.secondaryPurple;
      case SubscriptionCategory.newsMedia:
        return AppColors.warning;
      case SubscriptionCategory.foodDelivery:
        return Colors.orange;
      case SubscriptionCategory.shopping:
        return AppColors.accentPink;
      case SubscriptionCategory.finance:
        return AppColors.success;
      case SubscriptionCategory.education:
        return AppColors.info;
      case SubscriptionCategory.utilities:
        return AppColors.mediumGray;
      case SubscriptionCategory.other:
        return AppColors.mediumGray;
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.trial:
        return AppColors.info;
    }
  }

  String _getBadgeLabel(Subscription sub) {
    if (sub.status == SubscriptionStatus.cancelled) {
      return 'CANCELLED';
    }
    if (!sub.autoRenew && sub.status == SubscriptionStatus.active) {
      return 'ENDS SOON';
    }
    if (sub.status == SubscriptionStatus.paused) {
      return 'PAUSED';
    }
    if (sub.status == SubscriptionStatus.trial) {
      return 'TRIAL';
    }
    return sub.status.name.toUpperCase();
  }

  Color _getBadgeColor(Subscription sub) {
    if (sub.status == SubscriptionStatus.cancelled) {
      return AppColors.error;
    }
    if (!sub.autoRenew && sub.status == SubscriptionStatus.active) {
      return AppColors.error;
    }
    return _getStatusColor(sub.status);
  }
}
