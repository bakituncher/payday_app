/// Pay Period Summary Card for Home Screen
/// Shows a quick snapshot of current pay period's spending
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/features/insights/screens/monthly_summary_screen.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

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
          MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.getCardShadow(context),
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

    // Calculate subscription costs in this period
    final subscriptionTotal = subscriptions.fold<double>(
      0,
          (sum, sub) => sum + _getSubscriptionCostInPeriod(sub, payCycle),
    );

    final totalSpending = totalExpenses + subscriptionTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay Period',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      payCycle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextSecondary(context),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Total Spending
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spending',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              // GÜNCELLEME: Merkezi CurrencyFormatter kullanılıyor
              Text(
                CurrencyFormatter.format(totalSpending, currency),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Spending Chart
        _buildMiniChart(context, transactions, currency),
      ],
    );
  }

  Widget _buildMiniChart(BuildContext context, List<Transaction> transactions, String currency) {
    final theme = Theme.of(context);

    // Group expenses by date (last 7 days)
    final expenses = transactions.where((t) => t.isExpense).toList();
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final expensesByDate = <DateTime, double>{};
    for (var expense in expenses) {
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (last7Days.any((d) =>
      d.year == dateKey.year && d.month == dateKey.month && d.day == dateKey.day)) {
        expensesByDate[dateKey] = (expensesByDate[dateKey] ?? 0) + expense.amount;
      }
    }

    final maxAmount = expensesByDate.values.isEmpty ? 100.0 : expensesByDate.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: last7Days.map((date) {
              final dateKey = DateTime(date.year, date.month, date.day);
              final amount = expensesByDate[dateKey] ?? 0;
              final heightFactor = maxAmount > 0 ? (amount / maxAmount) : 0.0;
              final isToday = DateTime.now().difference(date).inDays == 0;

              // GÜNCELLEME: Grafik için temizlenmiş (decimalsız) metin
              String labelText = '';
              if (amount > 0) {
                final formatted = CurrencyFormatter.format(amount, currency, showSymbol: false);
                // Ondalık kısmı (.00 veya ,00) regex ile güvenli bir şekilde kaldırıyoruz
                // Böylece '1,200.00' -> '1,200' olur. '1.200,00' -> '1.200' olur.
                labelText = formatted.replaceAll(RegExp(r'[.,]\d+$'), '');
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount (if not zero)
                      SizedBox(
                        height: 16,
                        child: amount > 0 ? Text(
                          labelText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ) : null,
                      ),
                      const SizedBox(height: 2),
                      // Bar
                      Container(
                        width: double.infinity,
                        height: (heightFactor * 40).clamp(2, 40),
                        decoration: BoxDecoration(
                          gradient: amount > 0 ? AppColors.pinkGradient : null,
                          color: amount == 0 ? AppColors.getSubtle(context) : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Day label
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: isToday ? AppColors.primaryPink : AppColors.getTextSecondary(context),
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.getSubtle(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.getSubtle(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.getSubtle(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.getSubtle(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.getSubtle(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.getSubtle(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Could not load pay period data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay Period Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              Text(
                'Set up your profile to get started',
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
    );
  }

  double _getSubscriptionCostInPeriod(Subscription sub, String payCycle) {
    // Calculate how much this subscription costs in the given pay period
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