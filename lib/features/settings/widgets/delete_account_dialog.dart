/// Delete Account Dialog Widget
/// Displays warning dialog before account deletion
import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Delete Account',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to delete your account. This action cannot be undone!',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'The following data will be permanently deleted:',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DeleteWarningItem(
            text: 'All transactions and expenses',
            isDark: isDark,
          ),
          _DeleteWarningItem(
            text: 'Financial settings and preferences',
            isDark: isDark,
          ),
          _DeleteWarningItem(
            text: 'Account information',
            isDark: isDark,
          ),
          _DeleteWarningItem(
            text: 'Premium subscription status',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This action cannot be undone!',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ),
          child: const Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteWarningItem extends StatelessWidget {
  final String text;
  final bool isDark;

  const _DeleteWarningItem({
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

