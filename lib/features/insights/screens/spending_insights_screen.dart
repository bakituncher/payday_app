/// Spending Insights Screen - Premium Industry-Grade Analytics
/// Beautiful charts, period selection, and deep spending analysis
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/shared/widgets/payday_banner_ad.dart';

// Period enum for selection
enum InsightPeriod {
  week('7D', 7, 'Last 7 Days'),
  month('1M', 30, 'Last 30 Days'),
  threeMonths('3M', 90, 'Last 3 Months'),
  sixMonths('6M', 180, 'Last 6 Months');

  final String label;
  final int days;
  final String fullLabel;

  const InsightPeriod(this.label, this.days, this.fullLabel);
}

// Provider for selected period
final selectedPeriodProvider = StateProvider<InsightPeriod>((ref) => InsightPeriod.month);

// Provider for transactions in selected period
final periodTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(transactionRepositoryProvider);

  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: period.days));

  return repository.getTransactionsByDateRange(userId, startDate, now);
});

class SpendingInsightsScreen extends ConsumerStatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  ConsumerState<SpendingInsightsScreen> createState() => _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends ConsumerState<SpendingInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedPieIndex = -1;
  bool _didShowInterstitial = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didShowInterstitial) return;
      _didShowInterstitial = true;
      AdService().showInterstitial(2);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final transactionsAsync = ref.watch(periodTransactionsProvider);
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.getCardShadow(context),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Spending Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.getTextPrimary(context),
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: settingsAsync.when(
                loading: () => _buildLoadingState(context),
                error: (error, _) => _buildErrorState(context, error),
                data: (settings) {
                  if (settings == null) {
                    return _buildNoDataState(context);
                  }

                  return transactionsAsync.when(
                    loading: () => _buildLoadingState(context),
                    error: (error, _) => _buildErrorState(context, error),
                    data: (transactions) {
                      return subscriptionsAsync.when(
                        loading: () => _buildLoadingState(context),
                        error: (error, _) => _buildErrorState(context, error),
                        data: (subscriptions) {
                          return _buildContent(
                            context,
                            settings.currency,
                            settings.payCycle,
                            transactions,
                            subscriptions,
                            selectedPeriod,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: PaydayBannerAd(adUnitId: AdService().insightsBannerId),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String currency,
    String payCycle,
    List<Transaction> transactions,
    List<Subscription> subscriptions,
    InsightPeriod selectedPeriod,
  ) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final categoryData = _getCategoryData(expenses);

    return Column(
      children: [
        // Fixed header section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Period Selector
              _buildPeriodSelector(context, selectedPeriod),

              const SizedBox(height: 16),

              // Total Spending Card - Hero
              _buildTotalSpendingCard(context, totalExpenses, currency, expenses)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Tab Bar for different views
              _buildTabBar(context),

              const SizedBox(height: 8),
            ],
          ),
        ),

        // Tab Content - Scrollable
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              _buildOverviewTab(context, expenses, categoryData, currency, selectedPeriod),
              // Categories Tab
              _buildCategoriesTab(context, categoryData, totalExpenses, currency),
              // Trends Tab
              _buildTrendsTab(context, expenses, currency, selectedPeriod),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context, InsightPeriod selectedPeriod) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Row(
        children: InsightPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedPeriodProvider.notifier).state = period;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.premiumGradient : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSpendingCard(
    BuildContext context,
    double totalExpenses,
    String currency,
    List<Transaction> expenses,
  ) {
    final theme = Theme.of(context);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    // Calculate daily average
    final dailyAverage = expenses.isNotEmpty ? totalExpenses / selectedPeriod.days : 0.0;

    // Calculate previous period for comparison
    final previousPeriodTotal = _calculatePreviousPeriodTotal(expenses, selectedPeriod);
    final changePercent = previousPeriodTotal > 0
        ? ((totalExpenses - previousPeriodTotal) / previousPeriodTotal * 100)
        : 0.0;
    final isIncrease = changePercent > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPeriod.fullLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalExpenses, currency),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              // Change indicator
              if (previousPeriodTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isIncrease
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${changePercent.abs().toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildHeroStat(
                context,
                icon: Icons.calendar_today_rounded,
                value: CurrencyFormatter.format(dailyAverage, currency),
                label: 'Daily Avg',
              ),
              _buildHeroDivider(),
              _buildHeroStat(
                context,
                icon: Icons.receipt_long_rounded,
                value: '${expenses.length}',
                label: 'Transactions',
              ),
              _buildHeroDivider(),
              _buildHeroStat(
                context,
                icon: Icons.category_rounded,
                value: '${_getCategoryData(expenses).length}',
                label: 'Categories',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(BuildContext context,
      {required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDivider() {
    return Container(
      width: 1,
      height: 35,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.pinkGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.getTextSecondary(context),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Categories'),
          Tab(text: 'Trends'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    List<Transaction> expenses,
    List<CategoryData> categoryData,
    String currency,
    InsightPeriod period,
  ) {
    if (expenses.isEmpty) {
      return _buildEmptyTabState(context, 'No expenses in this period');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spending Breakdown Pie Chart
          _buildSectionTitle(context, 'Spending Breakdown', Icons.pie_chart_rounded),
          const SizedBox(height: 12),
          _buildPieChartCard(context, categoryData, currency)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 24),

          // Daily Spending Line Chart
          _buildSectionTitle(context, 'Daily Spending Pattern', Icons.show_chart_rounded),
          const SizedBox(height: 12),
          _buildLineChartCard(context, expenses, currency, period)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 24),

          // Top Spending Days
          _buildSectionTitle(context, 'Top Spending Days', Icons.calendar_month_rounded),
          const SizedBox(height: 12),
          _buildTopSpendingDays(context, expenses, currency)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(
    BuildContext context,
    List<CategoryData> categoryData,
    double totalExpenses,
    String currency,
  ) {
    if (categoryData.isEmpty) {
      return _buildEmptyTabState(context, 'No category data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breakdown with progress bars
          ...categoryData.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = totalExpenses > 0 ? (category.amount / totalExpenses * 100) : 0.0;

            return _buildCategoryItem(context, category, percentage, currency, index)
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                .slideX(begin: 0.1, end: 0);
          }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(
    BuildContext context,
    List<Transaction> expenses,
    String currency,
    InsightPeriod period,
  ) {
    if (expenses.isEmpty) {
      return _buildEmptyTabState(context, 'No trend data available');
    }

    // Group by week or month depending on period
    final groupedData = _getGroupedTrendData(expenses, period);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar chart for grouped data
          _buildSectionTitle(
            context,
            period.days <= 30 ? 'Weekly Breakdown' : 'Monthly Breakdown',
            Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 12),
          _buildBarChartCard(context, groupedData, currency)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),

          const SizedBox(height: 24),

          // Spending heatmap / Day of week analysis
          _buildSectionTitle(context, 'Spending by Day of Week', Icons.view_week_rounded),
          const SizedBox(height: 12),
          _buildDayOfWeekAnalysis(context, expenses, currency)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 24),

          // Insights cards
          _buildSectionTitle(context, 'Quick Insights', Icons.lightbulb_rounded),
          const SizedBox(height: 12),
          _buildInsightsCards(context, expenses, currency)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
        ),
      ],
    );
  }

  Widget _buildPieChartCard(
    BuildContext context,
    List<CategoryData> categoryData,
    String currency,
  ) {
    final theme = Theme.of(context);
    final topCategories = categoryData.take(5).toList();
    final totalAmount = topCategories.fold<double>(0, (sum, c) => sum + c.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isTouched = index == _touchedPieIndex;
                  final radius = isTouched ? 50.0 : 40.0;

                  return PieChartSectionData(
                    color: _getCategoryColor(index),
                    value: category.amount,
                    title: isTouched
                        ? '${(category.amount / totalAmount * 100).toStringAsFixed(0)}%'
                        : '',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    titlePositionPercentageOffset: 0.55,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend - Horizontal wrap
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = totalAmount > 0
                  ? (category.amount / totalAmount * 100)
                  : 0.0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${category.name} ${percentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextPrimary(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(
    BuildContext context,
    List<Transaction> expenses,
    String currency,
    InsightPeriod period,
  ) {
    final dailyData = _getDailySpendingData(expenses, period);
    if (dailyData.isEmpty) return const SizedBox.shrink();

    final maxY = dailyData.map((d) => d.amount).fold(0.0, math.max);
    final safeMaxY = maxY > 0 ? maxY * 1.2 : 100.0;
    final interval = safeMaxY / 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval > 0 ? interval : 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.getBorder(context).withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: period.days <= 7 ? 1 : (dailyData.length / 5).ceilToDouble(),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= dailyData.length) return const SizedBox.shrink();
                    final date = dailyData[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('d/M').format(date),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: interval > 0 ? interval : 25,
                  getTitlesWidget: (value, meta) {
                    if (value < 0) return const SizedBox.shrink();
                    return Text(
                      CurrencyFormatter.formatCompact(value, currency),
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (dailyData.length - 1).toDouble().clamp(0, double.infinity),
            minY: 0,
            maxY: safeMaxY,
            clipData: const FlClipData.all(),
            lineBarsData: [
              LineChartBarData(
                spots: dailyData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.amount.clamp(0, double.infinity));
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.25,
                preventCurveOverShooting: true,
                gradient: AppColors.pinkGradient,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: period.days <= 14,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: AppColors.primaryPink,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryPink.withValues(alpha: 0.3),
                      AppColors.primaryPink.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartCard(
    BuildContext context,
    List<GroupedData> groupedData,
    String currency,
  ) {
    if (groupedData.isEmpty) return const SizedBox.shrink();

    final maxY = groupedData.map((d) => d.amount).fold(0.0, math.max);
    final safeMaxY = maxY > 0 ? maxY * 1.2 : 100.0;
    final interval = safeMaxY / 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: safeMaxY,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => AppColors.darkSurface,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    CurrencyFormatter.format(rod.toY, currency),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= groupedData.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        groupedData[index].label,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: interval > 0 ? interval : 25,
                  getTitlesWidget: (value, meta) {
                    if (value < 0) return const SizedBox.shrink();
                    return Text(
                      CurrencyFormatter.formatCompact(value, currency),
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval > 0 ? interval : 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.getBorder(context).withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            barGroups: groupedData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.amount.clamp(0, double.infinity),
                    gradient: AppColors.pinkGradient,
                    width: groupedData.length > 6 ? 16 : 24,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryData category,
    double percentage,
    String currency,
    int index,
  ) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      '${category.transactionCount} transactions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(category.amount, currency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.getSubtle(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpendingDays(
    BuildContext context,
    List<Transaction> expenses,
    String currency,
  ) {
    final dailyTotals = <DateTime, double>{};
    for (var expense in expenses) {
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.amount;
    }

    final sortedDays = dailyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topDays = sortedDays.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: topDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isFirst = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: index < topDays.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: AppColors.getBorder(context).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isFirst ? AppColors.premiumGradient : null,
                    color: isFirst ? null : AppColors.getSubtle(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isFirst ? Colors.white : AppColors.getTextSecondary(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(day.key),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(day.key),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(day.value, currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFirst ? AppColors.primaryPink : AppColors.getTextPrimary(context),
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayOfWeekAnalysis(
    BuildContext context,
    List<Transaction> expenses,
    String currency,
  ) {
    final dayTotals = List.generate(7, (i) => 0.0);
    final dayCounts = List.generate(7, (i) => 0);

    for (var expense in expenses) {
      final dayIndex = expense.date.weekday - 1; // 0-6 for Mon-Sun
      dayTotals[dayIndex] += expense.amount;
      dayCounts[dayIndex]++;
    }

    final maxTotal = dayTotals.reduce(math.max);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final heightFactor = maxTotal > 0 ? dayTotals[index] / maxTotal : 0.0;
          final isHighest = dayTotals[index] == maxTotal && maxTotal > 0;

          return Column(
            children: [
              SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 30,
                      height: (heightFactor * 60).clamp(4, 60),
                      decoration: BoxDecoration(
                        gradient: isHighest
                            ? AppColors.premiumGradient
                            : AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isHighest
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayNames[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isHighest ? FontWeight.w700 : FontWeight.w500,
                  color: isHighest
                      ? AppColors.primaryPink
                      : AppColors.getTextSecondary(context),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInsightsCards(
    BuildContext context,
    List<Transaction> expenses,
    String currency,
  ) {
    final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final avgTransaction = expenses.isNotEmpty ? totalExpenses / expenses.length : 0.0;
    final maxTransaction = expenses.isNotEmpty
        ? expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount
        : 0.0;

    // Find most active day
    final dayCounts = <int, int>{};
    for (var expense in expenses) {
      final day = expense.date.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    final mostActiveDay = dayCounts.isNotEmpty
        ? dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 1;
    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                context,
                icon: Icons.analytics_rounded,
                title: 'Avg Transaction',
                value: CurrencyFormatter.format(avgTransaction, currency),
                color: AppColors.secondaryPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                context,
                icon: Icons.arrow_upward_rounded,
                title: 'Highest Spend',
                value: CurrencyFormatter.format(maxTransaction, currency),
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          context,
          icon: Icons.event_rounded,
          title: 'Most Active Day',
          value: dayNames[mostActiveDay],
          subtitle: '${dayCounts[mostActiveDay] ?? 0} transactions',
          color: AppColors.secondaryTeal,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getSubtle(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insights_outlined,
              size: 48,
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see insights',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your spending...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Could not load insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Set Up Your Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile to start tracking spending insights',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<CategoryData> _getCategoryData(List<Transaction> expenses) {
    final byCategory = <String, CategoryData>{};
    for (var expense in expenses) {
      if (byCategory.containsKey(expense.categoryName)) {
        final existing = byCategory[expense.categoryName]!;
        byCategory[expense.categoryName] = CategoryData(
          name: expense.categoryName,
          emoji: expense.categoryEmoji,
          amount: existing.amount + expense.amount,
          transactionCount: existing.transactionCount + 1,
        );
      } else {
        byCategory[expense.categoryName] = CategoryData(
          name: expense.categoryName,
          emoji: expense.categoryEmoji,
          amount: expense.amount,
          transactionCount: 1,
        );
      }
    }

    final sorted = byCategory.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }

  List<DayData> _getDailySpendingData(List<Transaction> expenses, InsightPeriod period) {
    final now = DateTime.now();
    final days = List.generate(
      period.days,
      (i) => now.subtract(Duration(days: period.days - 1 - i)),
    );

    return days.map((date) {
      final dayExpenses = expenses.where((t) =>
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day);
      final total = dayExpenses.fold<double>(0, (sum, t) => sum + t.amount);
      return DayData(date: date, amount: total);
    }).toList();
  }

  List<GroupedData> _getGroupedTrendData(List<Transaction> expenses, InsightPeriod period) {
    if (period.days <= 30) {
      // Group by week
      final weeklyData = <int, double>{};
      for (var expense in expenses) {
        final weekOfYear = _getWeekOfYear(expense.date);
        weeklyData[weekOfYear] = (weeklyData[weekOfYear] ?? 0) + expense.amount;
      }

      final sortedWeeks = weeklyData.keys.toList()..sort();
      return sortedWeeks.map((week) {
        return GroupedData(
          label: 'W$week',
          amount: weeklyData[week]!,
        );
      }).toList();
    } else {
      // Group by month
      final monthlyData = <String, double>{};
      for (var expense in expenses) {
        final monthKey = '${expense.date.year}-${expense.date.month}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + expense.amount;
      }

      final sortedMonths = monthlyData.keys.toList()..sort();
      return sortedMonths.map((month) {
        final parts = month.split('-');
        final monthNum = int.parse(parts[1]);
        final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return GroupedData(
          label: monthNames[monthNum],
          amount: monthlyData[month]!,
        );
      }).toList();
    }
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  double _calculatePreviousPeriodTotal(List<Transaction> expenses, InsightPeriod period) {
    // This is a simplified calculation - actual implementation might need more data
    // For now, return 0 if we don't have enough data
    return 0;
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primaryPink,
      AppColors.secondaryPurple,
      AppColors.secondaryTeal,
      AppColors.warning,
      AppColors.secondaryBlue,
      AppColors.success,
      AppColors.accentPink,
      AppColors.deepPink,
    ];
    return colors[index % colors.length];
  }
}

// Helper classes
class CategoryData {
  final String name;
  final String emoji;
  final double amount;
  final int transactionCount;

  CategoryData({
    required this.name,
    this.emoji = '📦',
    required this.amount,
    this.transactionCount = 0,
  });
}

class DayData {
  final DateTime date;
  final double amount;

  DayData({required this.date, required this.amount});
}

class GroupedData {
  final String label;
  final double amount;

  GroupedData({required this.label, required this.amount});
}

