/// Compact Spending Insights Card for Home Screen
/// Attractive and space-efficient card that invites users to explore spending data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/features/insights/screens/spending_insights_screen.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final transactionsAsync = ref.watch(currentCycleTransactionsProvider);
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SpendingInsightsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: settingsAsync.when(
          loading: () => _buildLoadingState(context),
          error: (_, __) => _buildErrorState(context),
          data: (settings) {
            if (settings == null) {
              return _buildEmptyState(context);
            }

            return transactionsAsync.when(
              loading: () => _buildLoadingState(context),
              error: (_, __) => _buildErrorState(context),
              data: (transactions) {
                return subscriptionsAsync.when(
                  loading: () => _buildLoadingState(context),
                  error: (_, __) => _buildErrorState(context),
                  data: (subscriptions) {
                    return _buildContent(
                      context,
                      settings.payCycle,
                      settings.currency,
                      transactions,
                      subscriptions,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String payCycle,
    String currency,
    List<Transaction> transactions,
    List<Subscription> subscriptions,
  ) {
    final theme = Theme.of(context);

    // Calculate expenses
    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate subscription costs
    final subscriptionTotal = subscriptions.fold<double>(
      0,
      (sum, sub) => sum + _getSubscriptionCostInPeriod(sub, payCycle),
    );

    final totalSpending = totalExpenses + subscriptionTotal;

    // Get trend data
    final trendData = _getTrendData(expenses);
    final trendDirection = _calculateTrendDirection(trendData);

    return Row(
      children: [
        // Left side - Main info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row
              Row(
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Spending Insights',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Amount
              Text(
                CurrencyFormatter.format(totalSpending, currency),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              // Trend + Stats
              Row(
                children: [
                  _buildTrendBadge(context, trendDirection),
                  const SizedBox(width: 8),
                  Text(
                    '${expenses.length} expenses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Right side - Mini chart + CTA
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini spark chart
            _buildSparkChart(context, trendData),
            const SizedBox(height: 8),
            // CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 1500.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendBadge(BuildContext context, TrendDirection trend) {
    final isUp = trend == TrendDirection.up;
    final isFlat = trend == TrendDirection.flat;

    final icon = isFlat
        ? Icons.trending_flat_rounded
        : isUp
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded;

    final text = isFlat ? 'Stable' : (isUp ? 'Up' : 'Down');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkChart(BuildContext context, List<DayData> data) {
    if (data.isEmpty) {
      return const SizedBox(width: 60, height: 30);
    }

    final maxAmount = data.map((d) => d.amount).fold(0.0, math.max);

    return SizedBox(
      width: 70,
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((dayData) {
          final heightFactor = maxAmount > 0 ? (dayData.amount / maxAmount) : 0.0;

          return Container(
            width: 6,
            height: (heightFactor * 25).clamp(3, 25),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7 + (heightFactor * 0.3)),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildErrorState(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          'Could not load insights',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Spending Insights',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Set up profile to start',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white, size: 20),
      ],
    );
  }

  // Helper methods
  List<DayData> _getTrendData(List<Transaction> expenses) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return last7Days.map((date) {
      final dayExpenses = expenses.where((t) =>
          t.isExpense &&
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day);
      final total = dayExpenses.fold<double>(0, (sum, t) => sum + t.amount);
      return DayData(date: date, amount: total);
    }).toList();
  }

  TrendDirection _calculateTrendDirection(List<DayData> data) {
    if (data.length < 4) return TrendDirection.flat;

    final firstHalf = data.take(3).fold<double>(0, (sum, d) => sum + d.amount);
    final secondHalf = data.skip(4).fold<double>(0, (sum, d) => sum + d.amount);

    if ((secondHalf - firstHalf).abs() < firstHalf * 0.1) {
      return TrendDirection.flat;
    }
    return secondHalf > firstHalf ? TrendDirection.up : TrendDirection.down;
  }

  double _getSubscriptionCostInPeriod(Subscription sub, String payCycle) {
    switch (payCycle.toLowerCase()) {
      case 'weekly':
        return _convertToWeeklyCost(sub);
      case 'bi-weekly':
      case 'biweekly':
      case 'fortnightly':
        return _convertToBiWeeklyCost(sub);
      case 'monthly':
        return sub.monthlyCost;
      default:
        return sub.monthlyCost;
    }
  }

  double _convertToWeeklyCost(Subscription sub) {
    switch (sub.frequency) {
      case RecurrenceFrequency.daily:
        return sub.amount * 7;
      case RecurrenceFrequency.weekly:
        return sub.amount;
      case RecurrenceFrequency.biweekly:
        return sub.amount / 2;
      case RecurrenceFrequency.monthly:
        return sub.amount / 4.33;
      case RecurrenceFrequency.quarterly:
        return sub.amount / 13;
      case RecurrenceFrequency.yearly:
        return sub.amount / 52;
    }
  }

  double _convertToBiWeeklyCost(Subscription sub) {
    switch (sub.frequency) {
      case RecurrenceFrequency.daily:
        return sub.amount * 14;
      case RecurrenceFrequency.weekly:
        return sub.amount * 2;
      case RecurrenceFrequency.biweekly:
        return sub.amount;
      case RecurrenceFrequency.monthly:
        return sub.amount / 2.17;
      case RecurrenceFrequency.quarterly:
        return sub.amount / 6.5;
      case RecurrenceFrequency.yearly:
        return sub.amount / 26;
    }
  }
}

// Helper classes
class DayData {
  final DateTime date;
  final double amount;

  DayData({required this.date, required this.amount});
}

enum TrendDirection { up, down, flat }

