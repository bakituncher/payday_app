/// Sector Style Summary Card
/// A high-quality, industry-standard summary card with Weekly, Bi-Weekly, and Monthly views.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/summary_period.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/insights/screens/monthly_summary_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SectorStyleSummaryCard extends ConsumerWidget {
  const SectorStyleSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(currentSummaryProvider);
    final selectedPeriod = ref.watch(summaryPeriodProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0), // Parent padding handles it usually, but ensures fit
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Period Selector (Tabs)
          _buildPeriodSelector(context, ref, selectedPeriod),

          // 2. Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: summaryAsync.when(
              loading: () => _buildLoadingState(context),
              error: (err, _) => _buildErrorState(context, err.toString()),
              data: (summary) {
                if (summary == null) return _buildEmptyState(context);
                return _buildSummaryContent(context, summary);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref, SummaryPeriod current) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getSubtle(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: SummaryPeriod.values.map((period) {
          final isSelected = period == current;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(summaryPeriodProvider.notifier).state = period;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.getCardBackground(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.getTextPrimary(context)
                            : AppColors.getTextSecondary(context),
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context, MonthlySummary summary) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Balance Section
          Text(
            'Remaining Balance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(summary.leftoverAmount),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -1,
            ),
          ).animate(key: ValueKey(summary.leftoverAmount)).scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
              ),

          const SizedBox(height: AppSpacing.lg),

          // Visual Bar (Income vs Expense)
          _buildProgressBar(context, summary),

          const SizedBox(height: AppSpacing.lg),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Income',
                  amount: summary.totalIncome,
                  color: AppColors.success,
                  icon: Icons.arrow_downward_rounded, // In
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.getBorder(context).withOpacity(0.5),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Expense',
                  amount: summary.totalExpenses, // Includes subscriptions
                  color: AppColors.error,
                  icon: Icons.arrow_upward_rounded, // Out
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // "View Details" button
          InkWell(
            onTap: () {
               HapticFeedback.lightImpact();
               Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
               );
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                      'View Analysis',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                   ),
                   const SizedBox(width: 4),
                   const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryPink),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, MonthlySummary summary) {
    // Calculate percentage, clamped between 0 and 1
    final progress = summary.totalIncome > 0
        ? (summary.totalExpenses / summary.totalIncome).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Stack(
          children: [
            // Background
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getSubtle(context),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient, // Use the pink gradient
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(duration: 800.ms, curve: Curves.easeOutQuart, begin: -1, end: 0),
          ],
        ),
        const SizedBox(height: 8),
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Used',
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextSecondary(context),
                 ),
              ),
              Text(
                '${((1 - progress) * 100).toStringAsFixed(0)}% Left',
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.getTextSecondary(context),
                 ),
              ),
           ],
        )
      ],
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required String label, required double amount, required Color color, required IconData icon}) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.compactSimpleCurrency(); // e.g. $1.2K

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            height: 40,
            width: 150,
            decoration: BoxDecoration(
               color: AppColors.getSubtle(context),
               borderRadius: BorderRadius.circular(8),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white54),
          const SizedBox(height: 20),
          Container(
            height: 12,
            width: double.infinity,
             decoration: BoxDecoration(
               color: AppColors.getSubtle(context),
               borderRadius: BorderRadius.circular(6),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, delay: 200.ms, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'Unable to load data',
        style: TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Text('No data available for this period'),
      ),
    );
  }
}
