/// Pay Period Summary Screen
/// Shows spending overview for current pay cycle
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final transactionsAsync = ref.watch(currentCycleTransactionsProvider);
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pay Period Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          ),
          error: (error, _) => _buildErrorState(context, error),
          data: (settings) {
            if (settings == null) {
              return _buildNoDataState(context);
            }

            return transactionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              ),
              error: (error, _) => _buildErrorState(context, error),
              data: (transactions) {
                return subscriptionsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryPink),
                  ),
                  error: (error, _) => _buildErrorState(context, error),
                  data: (subscriptions) {
                    return _buildContent(context, settings.payCycle, settings.currency, transactions, subscriptions);
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
    final currencyFormat = NumberFormat.currency(symbol: CurrencyFormatter.getSymbol(currency));

    // Filter only expenses
    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);

    // Group expenses by date for chart
    final expensesByDate = <DateTime, double>{};
    for (var expense in expenses) {
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      expensesByDate[dateKey] = (expensesByDate[dateKey] ?? 0) + expense.amount;
    }

    // Calculate subscription costs in this period
    final subscriptionTotal = subscriptions.fold<double>(
      0,
      (sum, sub) => sum + _getSubscriptionCostInPeriod(sub, payCycle),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pay Cycle Info Card
                _buildPayCycleCard(context, payCycle),

                const SizedBox(height: AppSpacing.xl),

                // Spending Chart
                Text(
                  'Daily Spending',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSpendingChart(context, expensesByDate, payCycle, currency),

                const SizedBox(height: AppSpacing.xl),

                // Expense Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expenses Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currencyFormat.format(totalExpenses),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (expenses.isEmpty)
                  _buildEmptyState(context, 'No expenses yet', Icons.shopping_bag_outlined)
                else
                  _buildExpensesList(context, expenses, currency),

                const SizedBox(height: AppSpacing.xl),

                // Subscriptions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscriptions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        currencyFormat.format(subscriptionTotal),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.secondaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (subscriptions.isEmpty)
                  _buildEmptyState(context, 'No active subscriptions', Icons.subscriptions_outlined)
                else
                  _buildSubscriptionsList(context, subscriptions, payCycle, currency),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayCycleCard(BuildContext context, String payCycle) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay Cycle',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                payCycle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart(
    BuildContext context,
    Map<DateTime, double> expensesByDate,
    String payCycle,
    String currency,
  ) {
    if (expensesByDate.isEmpty) {
      return _buildEmptyState(context, 'No spending data yet', Icons.insert_chart_outlined);
    }

    // Prepare chart data - sorted by date (most recent first)
    final sortedDates = expensesByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    final currencyFormat = NumberFormat.currency(symbol: CurrencyFormatter.getSymbol(currency));
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: sortedDates.take(10).map((date) {
          final amount = expensesByDate[date]!;
          final isToday = DateTime.now().difference(date).inDays == 0;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.getBorder(context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : AppColors.getSubtle(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isToday ? AppColors.primaryPink : AppColors.getTextPrimary(context),
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Today' : DateFormat('EEEE').format(date),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPink,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, List<Transaction> expenses, String currency) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: CurrencyFormatter.getSymbol(currency));

    // Group by category
    final byCategory = <String, List<Transaction>>{};
    for (var expense in expenses) {
      byCategory.putIfAbsent(expense.categoryName, () => []).add(expense);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: byCategory.entries.map((entry) {
          final categoryName = entry.key;
          final categoryExpenses = entry.value;
          final categoryTotal = categoryExpenses.fold<double>(0, (sum, t) => sum + t.amount);
          final emoji = categoryExpenses.first.categoryEmoji;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              categoryName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${categoryExpenses.length} transaction${categoryExpenses.length > 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
            trailing: Text(
              currencyFormat.format(categoryTotal),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPink,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionsList(
    BuildContext context,
    List<Subscription> subscriptions,
    String payCycle,
    String currency,
  ) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: CurrencyFormatter.getSymbol(currency));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: subscriptions.map((sub) {
          final costInPeriod = _getSubscriptionCostInPeriod(sub, payCycle);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(sub.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              sub.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _getFrequencyText(sub.frequency),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(costInPeriod),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                if (costInPeriod != sub.amount)
                  Text(
                    'Est. for period',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
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

  String _getFrequencyText(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.biweekly:
        return 'Every 2 weeks';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.quarterly:
        return 'Quarterly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }


  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error loading summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.pinkGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.summarize_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Summary Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start tracking your expenses to see your monthly summary.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

