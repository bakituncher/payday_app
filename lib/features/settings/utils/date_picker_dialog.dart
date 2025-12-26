/// Date Picker Dialog Utility
/// Shows date picker with themed styling
import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';

class DatePickerDialog {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primaryPink,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryPink,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.darkCharcoal,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              ),
              bodyLarge: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              ),
              bodyMedium: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

