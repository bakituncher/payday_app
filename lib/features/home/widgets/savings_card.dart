/// Savings Card for Home Screen - Quick overview of savings goals
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/savings/providers/savings_providers.dart';
import 'package:payday/features/savings/screens/savings_screen.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/core/services/currency_service.dart';

class SavingsCard extends ConsumerWidget {
  const SavingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsGoalsAsync = ref.watch(savingsGoalsProvider);
    final totalSavings = ref.watch(totalSavingsProvider);
    final totalTarget = ref.watch(totalTargetProvider);
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);

    final currency = userSettingsAsync.when(
      data: (settings) => settings?.currency ?? 'USD',
      loading: () => 'USD',
      error: (_, __) => 'USD',
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SavingsScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.successGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Daha minimal dekorasyon (daha az görsel kalabalık)
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header - daha kompakt
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Savings',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                savingsGoalsAsync.when(
                                  data: (goals) => '${goals.length} ${goals.length == 1 ? 'goal' : 'goals'}',
                                  loading: () => 'Loading…',
                                  error: (_, __) => '0 goals',
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Content - daha kısa
                    savingsGoalsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      error: (error, _) => Text(
                        'Failed to load',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      data: (goals) {
                        if (goals.isEmpty) {
                          return Text(
                            'Add a goal to start saving',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }

                        final progressPercentage = totalTarget > 0
                            ? ((totalSavings / totalTarget) * 100).clamp(0.0, 100.0)
                            : 0.0;

                        final amountText = _formatCurrency(totalSavings, currency);
                        final targetText = _formatCurrency(totalTarget, currency);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Büyük rakam ama taşmasın
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                amountText,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Target $targetText',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Progress bar - tek satır/kompakt
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              child: LinearProgressIndicator(
                                value: progressPercentage / 100,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${progressPercentage.toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '${_formatCurrency((totalTarget - totalSavings).clamp(0, double.infinity), currency)} left',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.78),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount, String currency) {
    final currencyService = CurrencyUtilityService();
    return currencyService.formatAmountWithSeparators(amount, currency, decimals: 0);
  }
}