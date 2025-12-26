import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';

enum DataConflictChoice {
  keepLocal,
  keepRemote,
  cancel,
}

class DataConflictDialog extends StatelessWidget {
  final bool hasLocalData;
  final bool hasRemoteData;
  final VoidCallback onCancel;
  final Function(DataConflictChoice) onChoiceMade;

  const DataConflictDialog({
    super.key,
    required this.hasLocalData,
    required this.hasRemoteData,
    required this.onCancel,
    required this.onChoiceMade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal;
    final subtleColor = isDark ? AppColors.darkTextSecondary : AppColors.mediumGray;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sync_problem_rounded,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Data Conflict',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              'You have data on this device and in your account. Which would you like to keep?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: subtleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Keep Local Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onChoiceMade(DataConflictChoice.keepLocal);
                },
                icon: const Icon(Icons.phone_android, size: 20),
                label: const Text('Keep Device Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Keep Remote Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onChoiceMade(DataConflictChoice.keepRemote);
                },
                icon: const Icon(Icons.cloud_outlined, size: 20),
                label: const Text('Keep Cloud Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightGray,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cancel
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: subtleColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

