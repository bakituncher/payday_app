/// Financial Insights Service
/// Generates smart insights and recommendations based on user data
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/summary_period.dart';

class FinancialInsightsService {
  /// Generate summary from transactions based on period
  static MonthlySummary generateSummary({
    required String userId,
    required SummaryPeriod period,
    required double totalIncome,
    required List<Transaction> transactions,
    required List<Subscription> subscriptions,
    double? previousPeriodExpenses,
    DateTime? referenceDate,
  }) {
    // Determine date range for the current period
    final now = referenceDate ?? DateTime.now();
    final DateTime startDate;
    final DateTime endDate;
    final double adjustedIncome;

    switch (period) {
      case SummaryPeriod.weekly:
        // Start of current week (Monday) at 00:00:00
        final start = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(start.year, start.month, start.day);
        // End is the reference date (e.g. today or end of historical week)
        endDate = now;
        adjustedIncome = totalIncome / 4; // Approx weekly income
        break;
      case SummaryPeriod.biWeekly:
        // Last 14 days at 00:00:00
        final start = now.subtract(const Duration(days: 13));
        startDate = DateTime(start.year, start.month, start.day);
        endDate = now;
        adjustedIncome = totalIncome / 2; // Approx bi-weekly income
        break;
      case SummaryPeriod.monthly:
        // Start of month at 00:00:00
        startDate = DateTime(now.year, now.month, 1);
        // End of month (for historical) or now (for current)
        // For monthly, we generally want the whole month range if it's historical
        // But for "current status" we might want "up to now"
        // Let's assume standard month boundaries:
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        endDate = nextMonth.subtract(const Duration(seconds: 1));
        adjustedIncome = totalIncome;
        break;
    }

    // Filter transactions
    final periodTransactions = transactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calculate total expenses
    final totalExpenses = periodTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate subscription costs (pro-rated if needed)
    // For simplicity, we include active subscriptions in monthly,
    // and pro-rate for others
    double totalSubscriptions = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold<double>(0, (sum, s) => sum + s.monthlyCost);

    if (period == SummaryPeriod.weekly) {
      totalSubscriptions /= 4;
    } else if (period == SummaryPeriod.biWeekly) {
      totalSubscriptions /= 2;
    }

    // Calculate leftover
    final leftoverAmount = adjustedIncome - totalExpenses - totalSubscriptions;

    // Determine financial health
    final spendingRatio = (totalExpenses + totalSubscriptions) / adjustedIncome;
    final healthStatus = _determineHealthStatus(spendingRatio);

    // Determine spending trend
    final trend = _determineSpendingTrend(
      currentExpenses: totalExpenses,
      previousExpenses: previousPeriodExpenses,
    );

    // Group expenses by category
    final expensesByCategory = <String, double>{};
    for (final transaction in periodTransactions.where((t) => t.isExpense)) {
      expensesByCategory[transaction.categoryName] =
          (expensesByCategory[transaction.categoryName] ?? 0) + transaction.amount;
    }

    // Add subscriptions to expenses
    expensesByCategory['Subscriptions'] = totalSubscriptions;

    // Generate insights
    final insights = _generateInsights(
      totalIncome: adjustedIncome,
      totalExpenses: totalExpenses,
      totalSubscriptions: totalSubscriptions,
      leftoverAmount: leftoverAmount,
      expensesByCategory: expensesByCategory,
      trend: trend,
      healthStatus: healthStatus,
    );

    // Generate leftover suggestions
    final leftoverSuggestions = _generateLeftoverSuggestions(
      leftoverAmount: leftoverAmount,
      healthStatus: healthStatus,
    );

    return MonthlySummary(
      id: '${userId}_${period.name}_${now.millisecondsSinceEpoch}',
      userId: userId,
      year: now.year,
      month: now.month,
      totalIncome: adjustedIncome,
      totalExpenses: totalExpenses + totalSubscriptions,
      totalSubscriptions: totalSubscriptions,
      leftoverAmount: leftoverAmount,
      healthStatus: healthStatus,
      trend: trend,
      expensesByCategory: expensesByCategory,
      insights: insights,
      leftoverSuggestions: leftoverSuggestions,
      createdAt: now,
    );
  }

  /// Generate monthly summary from transactions (Legacy support wrapper)
  static MonthlySummary generateMonthlySummary({
    required String userId,
    required int year,
    required int month,
    required double totalIncome,
    required List<Transaction> transactions,
    required List<Subscription> subscriptions,
    double? previousMonthExpenses,
  }) {
    // Construct a reference date for the requested month
    // We use the end of that month so the logic captures the whole month
    // Or at least a date within that month so 'startDate' calculation works
    final referenceDate = DateTime(year, month, 15);

    return generateSummary(
      userId: userId,
      period: SummaryPeriod.monthly,
      totalIncome: totalIncome,
      transactions: transactions,
      subscriptions: subscriptions,
      previousPeriodExpenses: previousMonthExpenses,
      referenceDate: referenceDate,
    );
  }

  static FinancialHealth _determineHealthStatus(double spendingRatio) {
    if (spendingRatio < 0.5) return FinancialHealth.excellent;
    if (spendingRatio < 0.7) return FinancialHealth.good;
    if (spendingRatio < 0.9) return FinancialHealth.fair;
    if (spendingRatio <= 1.0) return FinancialHealth.poor;
    return FinancialHealth.critical;
  }

  static SpendingTrend _determineSpendingTrend({
    required double currentExpenses,
    double? previousExpenses,
  }) {
    if (previousExpenses == null || previousExpenses == 0) return SpendingTrend.stable;

    final difference = currentExpenses - previousExpenses;
    final percentageChange = (difference / previousExpenses) * 100;

    if (percentageChange > 10) return SpendingTrend.increasing;
    if (percentageChange < -10) return SpendingTrend.decreasing;
    return SpendingTrend.stable;
  }

  static List<SpendingInsight> _generateInsights({
    required double totalIncome,
    required double totalExpenses,
    required double totalSubscriptions,
    required double leftoverAmount,
    required Map<String, double> expensesByCategory,
    required SpendingTrend trend,
    required FinancialHealth healthStatus,
  }) {
    final insights = <SpendingInsight>[];
    var insightId = 0;

    // Savings rate insight
    final savingsRate = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome * 100) : 0;
    if (savingsRate >= 20) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Great Savings Rate!',
        description: 'You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income. Keep it up!',
        emoji: '🎉',
        type: InsightType.achievement,
        amount: savingsRate,
      ));
    } else if (savingsRate < 10 && savingsRate > 0) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Low Savings Alert',
        description: 'Consider saving at least 10-20% of your income for financial security.',
        emoji: '💡',
        type: InsightType.tip,
        amount: savingsRate,
        actionText: 'Set Savings Goal',
      ));
    }

    // Subscription spending insight
    final subscriptionRatio = totalIncome > 0 ? (totalSubscriptions / totalIncome * 100) : 0;
    if (subscriptionRatio > 15) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'High Subscription Costs',
        description: 'Subscriptions take ${subscriptionRatio.toStringAsFixed(0)}% of your income. Review for potential savings.',
        emoji: '📱',
        type: InsightType.warning,
        amount: totalSubscriptions,
        category: 'Subscriptions',
        actionText: 'Review Subscriptions',
      ));
    }

    // Biggest expense category
    if (expensesByCategory.isNotEmpty) {
      final sortedCategories = expensesByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topCategory = sortedCategories.first;
      final topCategoryRatio = totalExpenses > 0 ? (topCategory.value / totalExpenses * 100) : 0;

      if (topCategoryRatio > 40) {
        insights.add(SpendingInsight(
          id: 'insight_${insightId++}',
          title: 'Top Spending Category',
          description: '${topCategory.key} accounts for ${topCategoryRatio.toStringAsFixed(0)}% of your spending.',
          emoji: '📊',
          type: InsightType.tip,
          amount: topCategory.value,
          category: topCategory.key,
        ));
      }
    }

    // Spending trend insight
    if (trend == SpendingTrend.increasing) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Spending Increased',
        description: 'Your spending has increased compared to previous period. Keep an eye on your budget.',
        emoji: '📈',
        type: InsightType.warning,
      ));
    } else if (trend == SpendingTrend.decreasing) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Spending Decreased',
        description: 'Great job! You spent less than the previous period.',
        emoji: '📉',
        type: InsightType.positive,
      ));
    }

    // Leftover money insight
    if (leftoverAmount > 0) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Money Left Over',
        description: 'You have \$${leftoverAmount.toStringAsFixed(2)} remaining. Decide what to do with it!',
        emoji: '💰',
        type: InsightType.positive,
        amount: leftoverAmount,
        actionText: 'Allocate Funds',
      ));
    } else if (leftoverAmount < 0) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Over Budget',
        description: 'You\'ve overspent by \$${(-leftoverAmount).toStringAsFixed(2)}. Review your expenses.',
        emoji: '🚨',
        type: InsightType.warning,
        amount: leftoverAmount,
        actionText: 'Review Expenses',
      ));
    }

    return insights;
  }

  static List<LeftoverSuggestion> _generateLeftoverSuggestions({
    required double leftoverAmount,
    required FinancialHealth healthStatus,
  }) {
    if (leftoverAmount <= 0) return [];

    final suggestions = <LeftoverSuggestion>[];

    // Emergency fund (highest priority for poor financial health)
    if (healthStatus == FinancialHealth.poor || healthStatus == FinancialHealth.fair) {
      suggestions.add(LeftoverSuggestion(
        id: 'suggestion_emergency',
        action: LeftoverAction.emergency,
        title: 'Build Emergency Fund',
        description: 'Aim for 3-6 months of expenses saved. Start with this amount.',
        suggestedAmount: leftoverAmount * 0.5,
        priority: 1,
        emoji: '🛡️',
      ));
    }

    // Savings (always a good option)
    suggestions.add(LeftoverSuggestion(
      id: 'suggestion_save',
      action: LeftoverAction.save,
      title: 'Add to Savings',
      description: 'Grow your savings for future goals.',
      suggestedAmount: leftoverAmount * 0.4,
      priority: 2,
      emoji: '🏦',
    ));

    // Debt payoff (if applicable - we suggest it as general advice)
    suggestions.add(LeftoverSuggestion(
      id: 'suggestion_debt',
      action: LeftoverAction.debt,
      title: 'Pay Down Debt',
      description: 'Extra payments reduce interest and speed up payoff.',
      suggestedAmount: leftoverAmount * 0.3,
      priority: 3,
      emoji: '💳',
    ));

    // Investment (for good financial health)
    if (healthStatus == FinancialHealth.excellent || healthStatus == FinancialHealth.good) {
      suggestions.add(LeftoverSuggestion(
        id: 'suggestion_invest',
        action: LeftoverAction.invest,
        title: 'Start Investing',
        description: 'Make your money work for you with long-term investments.',
        suggestedAmount: leftoverAmount * 0.3,
        priority: 4,
        emoji: '📈',
      ));
    }

    // Roll over to next month
    suggestions.add(LeftoverSuggestion(
      id: 'suggestion_rollover',
      action: LeftoverAction.rollover,
      title: 'Roll Over to Next Month',
      description: 'Increase next month\'s budget flexibility.',
      suggestedAmount: leftoverAmount,
      priority: 5,
      emoji: '🔄',
    ));

    // Small treat (for excellent financial health)
    if (healthStatus == FinancialHealth.excellent && leftoverAmount > 100) {
      suggestions.add(LeftoverSuggestion(
        id: 'suggestion_treat',
        action: LeftoverAction.treat,
        title: 'Treat Yourself',
        description: 'You\'ve been responsible. A small reward is okay!',
        suggestedAmount: leftoverAmount * 0.1,
        priority: 6,
        emoji: '🎁',
      ));
    }

    // Sort by priority
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));

    return suggestions;
  }

  /// Get smart tip based on current financial situation
  static String getSmartTip({
    required double daysUntilPayday,
    required double dailyAllowance,
    required double spentToday,
    required FinancialHealth healthStatus,
  }) {
    if (spentToday > dailyAllowance * 1.5) {
      return '💡 You\'ve spent more than your daily allowance. Consider skipping non-essential purchases tomorrow.';
    }

    if (daysUntilPayday <= 3 && healthStatus != FinancialHealth.excellent) {
      return '💡 Payday is coming soon! Try to minimize spending these last few days.';
    }

    if (healthStatus == FinancialHealth.excellent) {
      return '💡 Great financial habits! Consider increasing your savings or investment contributions.';
    }

    if (spentToday == 0) {
      return '💡 No spending today! Your daily allowance rolls over for flexibility.';
    }

    return '💡 Track every expense to stay on budget. Small purchases add up!';
  }
}
