/// Income and Balance Card Widget
/// Displays and edits income and current balance
import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/utils/currency_formatter.dart';

class IncomeCard extends StatelessWidget {
  final TextEditingController incomeController;
  final TextEditingController currentBalanceController;
  final String selectedCurrency;

  const IncomeCard({
    super.key,
    required this.incomeController,
    required this.currentBalanceController,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = CurrencyFormatter.getSymbol(selectedCurrency);
    final isSymbolOnRight = CurrencyFormatter.isSymbolOnRight(selectedCurrency);

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
          _buildIncomeField(theme, context, currencySymbol, isSymbolOnRight),
          const SizedBox(height: AppSpacing.lg),
          _buildBalanceField(theme, context, currencySymbol, isSymbolOnRight),
        ],
      ),
    );
  }

  Widget _buildIncomeField(
    ThemeData theme,
    BuildContext context,
    String currencySymbol,
    bool isSymbolOnRight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Income',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.getTextSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: incomeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: isSymbolOnRight ? null : currencySymbol,
            suffixText: isSymbolOnRight ? currencySymbol : null,
            prefixStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPink,
            ),
            suffixStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPink,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceField(
    ThemeData theme,
    BuildContext context,
    String currencySymbol,
    bool isSymbolOnRight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Balance',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.getTextSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: currentBalanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: isSymbolOnRight ? null : currencySymbol,
            suffixText: isSymbolOnRight ? currencySymbol : null,
            prefixStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
            suffixStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.secondaryPurple, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}

