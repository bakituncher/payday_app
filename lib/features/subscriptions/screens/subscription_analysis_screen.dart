/// Subscription Analysis Screen - Industry-grade compact UI/UX
/// Advanced analytics with modern, minimal design
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          // App Bar
          SliverAppBar(
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Savings Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
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
                        Icons.subscriptions_outlined,
                        size: 64,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Subscriptions Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.getTextPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add your first subscription to see\npersonalized savings recommendations',
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
        // Compact Modern App Bar
        SliverAppBar(
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.success,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Savings Analysis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(context),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Savings Potential Card - More compact
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
                            Icons.savings_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Potential Savings',
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
                              CurrencyFormatter.format(summary.potentialMonthlySavings, currencyCode),
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
                                  'Yearly potential:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(summary.potentialYearlySavings, currencyCode),
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

                // Quick Stats - More compact
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.receipt_long_rounded,
                        label: 'Active',
                        value: '${summary.totalSubscriptions}',
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.search_rounded,
                        label: 'Review',
                        value: '${summary.subscriptionsToReview}',
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.cancel_outlined,
                        label: 'Cancel',
                        value: '${summary.subscriptionsToCancel}',
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

                const SizedBox(height: 20),

                // Spending by Category
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

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
                  child: Column(
                    children: summary.spendByCategory.entries.map((entry) {
                      final percentage = summary.totalMonthlySpend > 0
                          ? (entry.value / summary.totalMonthlySpend * 100)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatCategoryName(entry.key),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextPrimary(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  CurrencyFormatter.format(entry.value, currencyCode),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.getTextPrimary(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                                    : AppColors.subtleGray.withValues(alpha: 0.5),
                                valueColor: AlwaysStoppedAnimation(
                                  _getCategoryColor(entry.key),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                const SizedBox(height: 20),

                // Recommendations
                Text(
                  'Recommendations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(context),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on typical usage patterns',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Analysis List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final analysis = summary.analyses[index];
                return _buildAnalysisCard(context, ref, analysis, index)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: (150 + index * 30).ms)
                    .slideX(begin: 0.05, end: 0);
              },
              childCount: summary.analyses.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(context),
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionAnalysis analysis,
    int index,
  ) {
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final isDark = theme.brightness == Brightness.dark;

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
        border: analysis.recommendation == RecommendationType.cancel
            ? Border.all(
                color: AppColors.error.withValues(alpha: isDark ? 0.4 : 0.3),
                width: 1.5,
              )
            : analysis.recommendation == RecommendationType.review
                ? Border.all(
                    color: AppColors.warning.withValues(alpha: isDark ? 0.4 : 0.3),
                    width: 1.5,
                  )
                : (isDark
                    ? Border.all(
                        color: AppColors.darkBorder.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      analysis.recommendationEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.subscriptionName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(context),
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CurrencyFormatter.format(analysis.monthlyAmount, currencyCode)}/month',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRecommendationColor(analysis.recommendation).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRecommendationColor(analysis.recommendation).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getRecommendationLabel(analysis.recommendation),
                  style: TextStyle(
                    color: _getRecommendationColor(analysis.recommendation),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          // Usage Score
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Usage Score:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: analysis.usageScore / 100,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                        : AppColors.subtleGray.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation(
                      _getUsageColor(analysis.usageScore),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${analysis.usageScore}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getUsageColor(analysis.usageScore),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Reasons
          if (analysis.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...analysis.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // Alternatives
          if (analysis.alternatives.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 6),
                      Text(
                        'Suggestions:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...analysis.alternatives.map((alt) => Padding(
                    padding: const EdgeInsets.only(left: 22, top: 3),
                    child: Text(
                      '• $alt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],

          // Potential Savings
          if (analysis.potentialSavings > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings_outlined, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Save ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.format(analysis.potentialSavings, currencyCode)}/mo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          if (analysis.recommendation == RecommendationType.cancel ||
              analysis.recommendation == RecommendationType.review) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Navigate to subscription detail
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryPink,
                      side: BorderSide(
                        color: AppColors.primaryPink.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(subscriptionNotifierProvider.notifier)
                          .cancelSubscription(analysis.subscriptionId, analysis.userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${analysis.subscriptionName} cancelled'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel Sub',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  Color _getRecommendationColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.keep:
        return AppColors.success;
      case RecommendationType.review:
        return AppColors.warning;
      case RecommendationType.downgrade:
        return AppColors.info;
      case RecommendationType.cancel:
        return AppColors.error;
      case RecommendationType.bundle:
        return AppColors.secondaryPurple;
    }
  }

  String _getRecommendationLabel(RecommendationType type) {
    switch (type) {
      case RecommendationType.keep:
        return 'Keep';
      case RecommendationType.review:
        return 'Review';
      case RecommendationType.downgrade:
        return 'Downgrade';
      case RecommendationType.cancel:
        return 'Cancel';
      case RecommendationType.bundle:
        return 'Bundle';
    }
  }

  Color _getUsageColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

