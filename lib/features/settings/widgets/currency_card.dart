/// Currency Selection Card Widget
/// Displays and allows selection of currency
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/utils/currency_formatter.dart';

class CurrencyCard extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;

  const CurrencyCard({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = CurrencyService().getAll();
    final currencyPickerCurrency = currencies.firstWhere(
      (c) => c.code == selectedCurrency,
      orElse: () => currencies.first,
    );
    final currencySymbol = CurrencyFormatter.getSymbol(selectedCurrency);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCurrencyPicker(context);
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
                color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                currencySymbol,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyPickerCurrency.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currencyPickerCurrency.code} • ${currencyPickerCurrency.symbol}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
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

  void _showCurrencyPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCurrencyPicker(
      context: context,
      theme: CurrencyPickerThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
          fontSize: 14,
        ),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search currency...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryPink,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.getBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkBackground : AppColors.lightGray,
        ),
        currencySignTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
          fontSize: 16,
        ),
      ),
      favorite: AppConstants.popularCurrencies,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        HapticFeedback.mediumImpact();
        onCurrencyChanged(currency.code);
      },
    );
  }
}

