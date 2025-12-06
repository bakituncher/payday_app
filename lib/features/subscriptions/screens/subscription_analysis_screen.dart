/// Subscription Analysis Screen
/// Shows potential savings and cancellation recommendations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/models/subscription_analysis.dart';
import 'package:payday_flutter/features/subscriptions/providers/subscription_providers.dart';
import 'package:intl/intl.dart';

class SubscriptionAnalysisScreen extends ConsumerWidget {
  const SubscriptionAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(subscriptionAnalysisProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: analysisAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(context, error),
          data: (summary) => _buildAnalysisContent(context, ref, summary),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context,
    WidgetRef ref,
    SubscriptionSummary summary,
  ) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: false,
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.darkCharcoal,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Savings Analysis',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Savings Potential Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
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
                            color: Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Potential Savings',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(summary.potentialMonthlySavings),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '/month',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Yearly potential:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormat.format(summary.potentialYearlySavings),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.lg),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.receipt_long_rounded,
                        label: 'Active Subs',
                        value: '${summary.totalSubscriptions}',
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.search_rounded,
                        label: 'To Review',
                        value: '${summary.subscriptionsToReview}',
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.cancel_outlined,
                        label: 'To Cancel',
                        value: '${summary.subscriptionsToCancel}',
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: AppSpacing.xl),

                // Spending by Category
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: summary.spendByCategory.entries.map((entry) {
                      final percentage = summary.totalMonthlySpend > 0
                          ? (entry.value / summary.totalMonthlySpend * 100)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatCategoryName(entry.key),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(entry.value),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 8,
                                backgroundColor: AppColors.subtleGray,
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
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.xl),

                // Recommendations
                Text(
                  'Recommendations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Based on typical usage patterns in US & EU markets',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),

        // Analysis List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final analysis = summary.analyses[index];
                return _buildAnalysisCard(context, ref, analysis, index)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (300 + index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
              childCount: summary.analyses.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
        border: analysis.recommendation == RecommendationType.cancel
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : analysis.recommendation == RecommendationType.review
                ? Border.all(color: AppColors.warning.withOpacity(0.3))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          analysis.subscriptionName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          analysis.recommendationEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormat.format(analysis.monthlyAmount)}/month',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getRecommendationColor(analysis.recommendation).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  _getRecommendationLabel(analysis.recommendation),
                  style: TextStyle(
                    color: _getRecommendationColor(analysis.recommendation),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // Usage Score
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Usage Score:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: analysis.usageScore / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.subtleGray,
                    valueColor: AlwaysStoppedAnimation(
                      _getUsageColor(analysis.usageScore),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${analysis.usageScore}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getUsageColor(analysis.usageScore),
                ),
              ),
            ],
          ),

          // Reasons
          if (analysis.reasons.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...analysis.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // Alternatives
          if (analysis.alternatives.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 6),
                      Text(
                        'Suggestions:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...analysis.alternatives.map((alt) => Padding(
                    padding: const EdgeInsets.only(left: 22, top: 2),
                    child: Text(
                      '• $alt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],

          // Potential Savings
          if (analysis.potentialSavings > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Potential savings: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '${currencyFormat.format(analysis.potentialSavings)}/month',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Button for cancel recommendations
          if (analysis.recommendation == RecommendationType.cancel ||
              analysis.recommendation == RecommendationType.review) ...[
            const SizedBox(height: AppSpacing.md),
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
                      side: BorderSide(color: AppColors.primaryPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(subscriptionNotifierProvider.notifier)
                          .cancelSubscription(analysis.subscriptionId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${analysis.subscriptionName} cancelled'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Cancel Sub'),
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
      child: CircularProgressIndicator(
        color: AppColors.primaryPink,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Could not load analysis',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(error.toString()),
        ],
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

