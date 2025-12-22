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
    final isDark = theme.brightness == Brightness.dark;

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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: subscription.isDueSoon(3)
              ? Border.all(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.4 : 0.5),
                  width: 1.5,
                )
              : (isDark
                  ? Border.all(
                      color: AppColors.darkBorder.withValues(alpha: 0.5),
                      width: 1,
                    )
                  : null),
        ),
        child: Row(
          children: [
            // Subscription Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(subscription.category).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(subscription.category).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  subscription.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Subscription Info - Flexible to prevent overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name and Badge Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subscription.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(context),
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subscription.status != SubscriptionStatus.active || !subscription.autoRenew) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(subscription).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getBadgeColor(subscription).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getBadgeLabel(subscription),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _getBadgeColor(subscription),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Frequency
                  Text(
                    subscription.frequencyText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Due Date
                  Text(
                    _getDueDateText(daysUntil),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: daysUntil <= 3
                          ? AppColors.warning
                          : AppColors.getTextSecondary(context),
                      fontWeight: daysUntil <= 3 ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount and Arrow Column
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(subscription.amount, currencyCode),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(context),
                        fontSize: 15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subscription.frequency != RecurrenceFrequency.monthly) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.format(subscription.monthlyCost, currencyCode)}/mo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
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
