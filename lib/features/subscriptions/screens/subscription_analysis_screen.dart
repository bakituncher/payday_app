/// Subscription Analysis Screen - Industry-grade compact UI/UX
/// Advanced analytics with modern, minimal design
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription_analysis.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';

class SubscriptionAnalysisScreen extends ConsumerWidget {
  const SubscriptionAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(subscriptionAnalysisProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      extendBody: true,
      body: Stack(
        children: [
          // Subtle background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.success.withValues(alpha: 0.02),
                    AppColors.primaryPink.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: analysisAsync.when(
              loading: () => _buildLoadingState(),
              error: (error, _) => _buildErrorState(context, error),
              data: (summary) => _buildAnalysisContent(context, ref, summary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context,
    WidgetRef ref,
    SubscriptionSummary summary,
  ) {
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Check if there are no subscriptions
    if (summary.totalSubscriptions == 0) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, theme),
          // Empty State
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 64,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Data Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.getTextPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add subscriptions to see\ndetailed analytics and insights',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add Subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, theme),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Monthly Spend Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Monthly Spending',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              CurrencyFormatter.format(summary.totalMonthlySpend, currencyCode),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                fontSize: 32,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '/month',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Yearly total:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(summary.totalYearlySpend, currencyCode),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Quick Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isDark ? Border.all(
                      color: AppColors.darkBorder.withValues(alpha: 0.5),
                      width: 1,
                    ) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        context,
                        icon: Icons.subscriptions_rounded,
                        label: 'Active',
                        value: '${summary.totalSubscriptions}',
                        color: AppColors.info,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.3)
                            : AppColors.subtleGray.withValues(alpha: 0.5),
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.category_rounded,
                        label: 'Categories',
                        value: '${summary.spendByCategory.length}',
                        color: AppColors.secondaryPurple,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.3)
                            : AppColors.subtleGray.withValues(alpha: 0.5),
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.show_chart_rounded,
                        label: 'Avg/Sub',
                        value: CurrencyFormatter.format(
                          summary.totalMonthlySpend / summary.totalSubscriptions,
                          currencyCode,
                        ),
                        color: AppColors.primaryPink,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

                const SizedBox(height: 20),

                // Category Distribution Chart
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                if (summary.spendByCategory.isNotEmpty)
                  _buildCategoryChart(context, summary, currencyCode, isDark)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms),

                const SizedBox(height: 20),

                // Category Breakdown List
                Text(
                  'Category Breakdown',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Category List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = summary.spendByCategory.entries.toList()[index];
                return _buildCategoryCard(
                  context,
                  entry.key,
                  entry.value,
                  summary.totalMonthlySpend,
                  currencyCode,
                  index,
                  isDark,
                ).animate().fadeIn(duration: 250.ms, delay: (150 + index * 30).ms)
                  .slideX(begin: 0.05, end: 0);
              },
              childCount: summary.spendByCategory.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.getBackground(context).withValues(alpha: 0.8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leadingWidth: 48,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.getTextPrimary(context),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      titleSpacing: 8,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.getTextPrimary(context),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.getTextSecondary(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    SubscriptionSummary summary,
    String currencyCode,
    bool isDark,
  ) {
    final sortedCategories = summary.spendByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(
          color: AppColors.darkBorder.withValues(alpha: 0.5),
          width: 1,
        ) : null,
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sortedCategories.map((entry) {
                  final percentage = (entry.value / summary.totalMonthlySpend * 100);
                  return PieChartSectionData(
                    color: _getCategoryColor(entry.key),
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedCategories.take(5).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatCategoryName(entry.key),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    double amount,
    double totalSpend,
    String currencyCode,
    int index,
    bool isDark,
  ) {
    final percentage = (amount / totalSpend * 100);
    final color = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(
          color: AppColors.darkBorder.withValues(alpha: 0.5),
          width: 1,
        ) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCategoryName(category),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(amount, currencyCode),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.subtleGray.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryPink,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing subscriptions...',
            style: TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Could not load analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.getTextPrimary(context),
                fontWeight: FontWeight.w700,
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
      ),
    );
  }

  String _formatCategoryName(String key) {
    return key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim().replaceFirst(key[0], key[0].toUpperCase());
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'streaming':
        return Icons.play_circle_outline_rounded;
      case 'productivity':
        return Icons.work_outline_rounded;
      case 'cloudstorage':
        return Icons.cloud_outlined;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'music':
        return Icons.music_note_rounded;
      case 'education':
        return Icons.school_outlined;
      case 'news':
        return Icons.newspaper_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'streaming':
        return AppColors.primaryPink;
      case 'productivity':
        return AppColors.secondaryBlue;
      case 'cloudstorage':
        return AppColors.secondaryTeal;
      case 'fitness':
        return AppColors.success;
      case 'gaming':
        return AppColors.secondaryPurple;
      case 'shopping':
        return AppColors.accentPink;
      default:
        return AppColors.mediumGray;
    }
  }
}

