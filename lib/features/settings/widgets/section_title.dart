/// Section Title Widget
/// Displays a consistent section title with icon
import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPink),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(context),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

