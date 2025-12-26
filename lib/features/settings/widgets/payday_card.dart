/// Payday Selection Card Widget
/// Displays and allows selection of next payday date
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/theme/app_theme.dart';

class PaydayCard extends StatelessWidget {
  final DateTime nextPayday;
  final VoidCallback onTap;

  const PaydayCard({
    super.key,
    required this.nextPayday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final daysUntil = nextPayday.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.getBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primaryPink,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(nextPayday),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDaysUntilText(daysUntil),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: daysUntil < 0
                          ? AppColors.error
                          : AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysUntilText(int daysUntil) {
    if (daysUntil > 0) {
      return '$daysUntil days away';
    } else if (daysUntil == 0) {
      return 'Today! 🎉';
    } else {
      return 'Tap to update';
    }
  }
}

