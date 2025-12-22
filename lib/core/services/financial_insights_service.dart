/// Financial Insights Service
/// Generates smart insights and recommendations based on user data
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';

class FinancialInsightsService {
  /// Generate monthly summary from transactions
  static MonthlySummary generateMonthlySummary({
    required String userId,
    required int year,
    required int month,
    required double totalIncome,
    required List<Transaction> transactions,
    required List<Subscription> subscriptions,
    double? previousMonthExpenses,
  }) {
    // Calculate total expenses
    final totalExpenses = transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate subscription costs
    final totalSubscriptions = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold<double>(0, (sum, s) => sum + s.monthlyCost);

    // Calculate leftover
    final leftoverAmount = totalIncome - totalExpenses - totalSubscriptions;

    // Determine financial health
    final spendingRatio = (totalExpenses + totalSubscriptions) / totalIncome;
    final healthStatus = _determineHealthStatus(spendingRatio);

    // Determine spending trend
    final trend = _determineSpendingTrend(
      currentExpenses: totalExpenses,
      previousExpenses: previousMonthExpenses,
    );

    // Group expenses by category
    final expensesByCategory = <String, double>{};
    for (final transaction in transactions.where((t) => t.isExpense)) {
      expensesByCategory[transaction.categoryName] =
          (expensesByCategory[transaction.categoryName] ?? 0) + transaction.amount;
    }

    // Add subscriptions to expenses
// Add subscriptions to expenses (Sadece tutar 0'dan büyükse ekle)
    if (totalSubscriptions > 0) {
      expensesByCategory['Subscriptions'] = totalSubscriptions;
    }
    // Generate insights
    final insights = _generateInsights(
      totalIncome: totalIncome,
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
      id: '${userId}_${year}_$month',
      userId: userId,
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses + totalSubscriptions,
      totalSubscriptions: totalSubscriptions,
      leftoverAmount: leftoverAmount,
      healthStatus: healthStatus,
      trend: trend,
      expensesByCategory: expensesByCategory,
      insights: insights,
      leftoverSuggestions: leftoverSuggestions,
      createdAt: DateTime.now(),
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
    if (previousExpenses == null) return SpendingTrend.stable;

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
    final savingsRate = ((totalIncome - totalExpenses) / totalIncome * 100);
    if (savingsRate >= 20) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Great Savings Rate!',
        description: 'You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income. Keep it up!',
        emoji: '🎉',
        type: InsightType.achievement,
        amount: savingsRate,
      ));
    } else if (savingsRate < 10) {
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
    final subscriptionRatio = totalSubscriptions / totalIncome * 100;
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
      final topCategoryRatio = topCategory.value / totalExpenses * 100;

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
        description: 'Your spending has increased compared to last month. Keep an eye on your budget.',
        emoji: '📈',
        type: InsightType.warning,
      ));
    } else if (trend == SpendingTrend.decreasing) {
      insights.add(SpendingInsight(
        id: 'insight_${insightId++}',
        title: 'Spending Decreased',
        description: 'Great job! You spent less than last month.',
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

