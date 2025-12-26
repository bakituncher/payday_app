/// Theme Selection Card Widget
/// Allows users to select light, dark, or system theme
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/theme_providers.dart';

class ThemeCard extends ConsumerWidget {
  const ThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose theme',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  title: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.light);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ThemeOption(
                  title: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.dark);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ThemeOption(
                  title: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.system);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.pinkGradient : null,
          color: isSelected ? null : AppColors.getSubtle(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

