/// Savings Card for Home Screen - Quick overview of savings goals
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
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content - Kompakt
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Kompakt
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Savings',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              savingsGoalsAsync.when(
                                data: (goals) => '${goals.length} ${goals.length == 1 ? 'goal' : 'goals'}',
                                loading: () => 'Loading...',
                                error: (_, __) => '0 goals',
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Amount
                  savingsGoalsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (error, _) => Text(
                      'Failed to load data',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    data: (goals) {
                      if (goals.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No goals yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Add goals like home, car, or vacation\nand start saving automatically',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      }

                      final progressPercentage = totalTarget > 0
                          ? ((totalSavings / totalTarget) * 100).clamp(0.0, 100.0)
                          : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatCurrency(totalSavings, currency),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${_formatCurrency(totalTarget, currency)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Progress bar
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${progressPercentage.toStringAsFixed(0)}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(totalTarget - totalSavings, currency)} left',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                child: LinearProgressIndicator(
                                  value: progressPercentage / 100,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 6,
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
    );
  }

  String _formatCurrency(double amount, String currency) {
    final currencyService = CurrencyUtilityService();
    return currencyService.formatAmountWithSeparators(amount, currency, decimals: 0);
  }
}