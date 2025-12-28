/// Subscriptions Screen - Industry-grade compact UI/UX
/// Modern, minimal and highly optimized design
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/features/subscriptions/widgets/subscription_card.dart';
import 'package:payday/features/subscriptions/widgets/subscription_summary_card.dart';
import 'package:payday/features/subscriptions/widgets/upcoming_bills_card.dart';
import 'package:payday/features/subscriptions/widgets/category_filter_chips.dart';
import 'package:payday/features/subscriptions/screens/add_subscription_screen.dart';
import 'package:payday/features/subscriptions/screens/subscription_analysis_screen.dart';
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/shared/widgets/payday_banner_ad.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _didShowInterstitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didShowInterstitial) return;

      // Premium değilse göster
      if (!ref.read(isPremiumProvider)) {
        _didShowInterstitial = true;
        AdService().showInterstitial(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(filteredSubscriptionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    AppColors.primaryPink
                        .withValues(alpha: isDark ? 0.02 : 0.03),
                    AppColors.secondaryPurple
                        .withValues(alpha: isDark ? 0.02 : 0.03),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Compact Modern App Bar
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  pinned: true,
                  backgroundColor:
                      AppColors.getBackground(context).withValues(alpha: 0.8),
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
                          Icons.subscriptions_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Subscriptions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          size: 18,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionAnalysisScreen(),
                          ),
                        );
                      },
                      color: AppColors.primaryPink,
                      tooltip: 'Analysis',
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Compact Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary Card - More compact
                      const SubscriptionSummaryCard()
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 12),

                      // Upcoming Bills - More compact
                      const UpcomingBillsCard()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 50.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      // Category Filter - Cleaner
                      const CategoryFilterChips()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms),

                      const SizedBox(height: 12),
                    ]),
                  ),
                ),

                // Subscriptions List
                subscriptionsAsync.when(
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildShimmerCard(context),
                        childCount: 3,
                      ),
                    ),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: _buildErrorState(context, error),
                  ),
                  data: (subscriptions) {
                    if (subscriptions.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subscription = subscriptions[index];
                            return SubscriptionCard(
                              subscription: subscription,
                            ).animate().fadeIn(
                                  duration: 250.ms,
                                  delay: (150 + (index * 30)).ms,
                                ).slideX(begin: 0.05, end: 0);
                          },
                          childCount: subscriptions.length,
                        ),
                      ),
                    );
                  },
                ),

                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: PaydayBannerAd(adUnitId: AdService().subscriptionsBannerId),
      ),

      // Modern FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddSubscriptionScreen(
                existingSubscription: null,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 4,
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          // Icon shimmer
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray)
                      .withValues(alpha: 0.5),
                  (isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray)
                      .withValues(alpha: 0.2),
                ],
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),

                const SizedBox(height: 8),

                // Subtitle shimmer
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, delay: 100.ms, color: Colors.white.withValues(alpha: 0.3)),
              ],
            ),
          ),

          // Price shimmer
          Container(
            width: 60,
            height: 18,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
              borderRadius: BorderRadius.circular(6),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, delay: 200.ms, color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.errorLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: isDark ? 0.2 : 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.subscriptions_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No subscriptions yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your Netflix, Spotify, Gym\nand other recurring expenses',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.getTextSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddSubscriptionScreen(
                    existingSubscription: null,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Add First Subscription',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 400.ms,
    );
  }
}
