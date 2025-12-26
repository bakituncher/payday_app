/// Pay Cycle Card Widget
/// Displays and selects pay cycle options in a 2x2 grid layout
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/services/date_cycle_service.dart';

class PayCycleCard extends StatelessWidget {
  final String selectedPayCycle;
  final DateTime currentNextPayday;
  final Function(String cycle, DateTime adjustedDate) onPayCycleChanged;

  const PayCycleCard({
    super.key,
    required this.selectedPayCycle,
    required this.currentNextPayday,
    required this.onPayCycleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listeyi güvenli bir şekilde alıyoruz
    final options = AppConstants.payCycleOptions;

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
            'How often do you get paid?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ÜST SATIR: Weekly ve Bi-weekly
          Row(
            children: [
              if (options.isNotEmpty)
                _buildCycleOption(context, options[0]), // Weekly
              const SizedBox(width: AppSpacing.sm),
              if (options.length > 1)
                _buildCycleOption(context, options[1]), // Bi-weekly
            ],
          ),

          const SizedBox(height: AppSpacing.sm), // Satırlar arası boşluk

          // ALT SATIR: Semi-monthly ve Monthly
          Row(
            children: [
              if (options.length > 2)
                _buildCycleOption(context, options[2]), // Semi-monthly
              const SizedBox(width: AppSpacing.sm),
              if (options.length > 3)
                _buildCycleOption(context, options[3]), // Monthly
            ],
          ),
        ],
      ),
    );
  }

  // Kod tekrarını önlemek için buton tasarımını buraya aldım
  Widget _buildCycleOption(BuildContext context, String cycle) {
    final theme = Theme.of(context);
    final isSelected = selectedPayCycle == cycle;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (selectedPayCycle != cycle) {
            final adjustedDate = DateCycleService.calculateNextPayday(
              currentNextPayday,
              cycle,
            );
            onPayCycleChanged(cycle, adjustedDate);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.pinkGradient : null,
            color: isSelected ? null : AppColors.getSubtle(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            cycle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}