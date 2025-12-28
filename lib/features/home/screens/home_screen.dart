/// Home Screen - The Hero Feature - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/home/widgets/countdown_card.dart';
import 'package:payday/features/home/widgets/budget_overview_card.dart';
import 'package:payday/features/home/widgets/savings_card.dart';
import 'package:payday/features/home/widgets/recent_transactions_card.dart';
import 'package:payday/features/home/widgets/active_subscriptions_card.dart';
import 'package:payday/features/home/widgets/monthly_summary_card.dart';
import 'package:payday/features/transactions/screens/add_transaction_screen.dart';
import 'package:payday/features/transactions/screens/add_funds_screen.dart';
import 'package:payday/features/settings/screens/settings_screen.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:payday/shared/widgets/payday_banner_ad.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';

// ✅ DEĞİŞTİ: ConsumerWidget -> ConsumerStatefulWidget
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showPayday = true;
  late final _timer = Stream.periodic(const Duration(seconds: 4), (count) => count % 2 == 0).asBroadcastStream();

  @override
  void initState() {
    super.initState();
    // ✅ EKLENDİ: Ekran çizildikten hemen sonra Premium durumunu kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshPremiumStatus(ref);
      // Process subscriptions on app start
      final subscriptionProcessor = ref.read(subscriptionProcessorServiceProvider);
      subscriptionProcessor.checkAndProcessDueSubscriptions(
        ref.read(currentUserIdProvider),
        processHistorical: true,
      );
    });
  }

  Future<void> _onRefresh() async {
    // ✅ EKLENDİ: Kullanıcı sayfayı yenilerse premium durumunu tekrar kontrol et
    await refreshPremiumStatus(ref);

    // Process subscriptions and payday logic on pull-to-refresh
    try {
      final subscriptionProcessor = ref.read(subscriptionProcessorServiceProvider);
      await subscriptionProcessor.checkAndProcessDueSubscriptions(
        ref.read(currentUserIdProvider),
        processHistorical: true,
      );
    } catch (e) {
      print('❌ Error processing subscriptions on refresh: $e');
    }

    // Refresh all data providers
    ref.invalidate(userSettingsProvider);
    ref.invalidate(currentCycleTransactionsProvider);
    ref.invalidate(totalExpensesProvider);
    ref.invalidate(dailyAllowableSpendProvider);
    ref.invalidate(budgetHealthProvider);
    ref.invalidate(currentMonthlySummaryProvider);

    // Wait a bit for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  ({String text, String emoji}) _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    // 24 saatlik ve 12 saatlik sistemler için uyumlu
    if (hour >= 5 && hour < 12) {
      return (text: 'Good Morning', emoji: '☀️');
    } else if (hour >= 12 && hour < 18) {
      return (text: 'Good Afternoon', emoji: '👋');
    } else if (hour >= 18 && hour < 22) {
      return (text: 'Good Evening', emoji: '🌆');
    } else {
      return (text: 'Good Night', emoji: '🌙');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref artık class içinde mevcut (StatefulWidget olduğu için parametre olarak gelmiyor)
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: userSettingsAsync.when(
          loading: () => _buildLoadingState(context),
          error: (error, stack) => _buildErrorState(context, error),
          data: (settings) {
            if (settings == null) {
              return _buildOnboardingPrompt(context);
            }

            return Stack(
              children: [
                // Background decoration
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryPink.withValues(alpha: 0.1),
                          AppColors.primaryPink.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -80,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondaryPurple.withValues(alpha: 0.08),
                          AppColors.secondaryPurple.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                RefreshIndicator(
                  onRefresh: _onRefresh, // Parametre gerekmez, yukarıdaki metodu çağırır
                  color: AppColors.primaryPink,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Premium App Bar - Kompakt
                      SliverAppBar(
                        expandedHeight: 0,
                        floating: true,
                        pinned: false,
                        backgroundColor: AppColors.getBackground(context),
                        elevation: 0,
                        surfaceTintColor: Colors.transparent,
                        toolbarHeight: 56, // Daha düşük toolbar
                        titleSpacing: 16, // Sol tarafa yapışık
                        title: StreamBuilder<bool>(
                          stream: _timer,
                          initialData: true,
                          builder: (context, snapshot) {
                            final showPayday = snapshot.data ?? true;
                            final greeting = _getGreeting();

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Align(
                                key: ValueKey(showPayday),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  showPayday ? 'Payday' : greeting.text,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.getTextPrimary(context),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 22),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            color: AppColors.getTextPrimary(context),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),

                      // Content - Kompakt Layout
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 16),

                            // Countdown Card - THE HERO
                            CountdownCard(
                              nextPayday: settings.nextPayday,
                              currency: settings.currency,
                              incomeAmount: settings.incomeAmount,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 100.ms)
                                .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              curve: Curves.easeOutBack,
                            ),

                            const SizedBox(height: 12),

                            // ✅ Daily Budget + Budget birleşik kart
                            BudgetOverviewCard(
                              currency: settings.currency,
                              currentBalance: settings.currentBalance,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 200.ms)
                                .slideX(begin: -0.05, end: 0),

                            const SizedBox(height: 12),

                            // Quick Actions Row - Daha kompakt
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.add_circle_outline_rounded,
                                    label: 'Add Funds',
                                    color: AppColors.success,
                                    onTap: () => _showAddFundsSheet(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.remove_circle_outline_rounded,
                                    label: 'Add Expense',
                                    color: AppColors.primaryPink,
                                    onTap: () => _showAddTransactionSheet(context),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 250.ms)
                                .slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 12),

                            // Savings Card
                            const SavingsCard()
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 325.ms)
                                .slideX(begin: -0.1, end: 0),

                            const SizedBox(height: 12),

                            // Active Subscriptions Card
                            const ActiveSubscriptionsCard()
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 350.ms)
                                .slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 12),

                            // Monthly Summary Card
                            const MonthlySummaryCard()
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 375.ms)
                                .slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 12),

                            // Recent Transactions
                            RecentTransactionsCard(
                              currency: settings.currency,
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 400.ms)
                                .slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 12),

                            // ✅ REKLAM ALANI
                            const PaydayBannerAd()
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 500.ms),

                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ), // RefreshIndicator end
              ],
            );
          },
        ),
      ),
      // ✅ İSTEK: alttaki "Add Expense" FAB kaldırıldı
      floatingActionButton: null,
    );
  }

  /// ✅ GÜNCELLENDİ: Tam Ekran Skeleton (İskelet) Yükleme
  /// Aşağı kısımların boş kalmaması için tüm kartları simüle eden bloklar eklendi.
  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Arka plan rengine uyumlu hafif bir ton
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return SingleChildScrollView(
      // Kaydırma fiziğini kapattık çünkü sadece görsel dolgu istiyoruz,
      // ama içerik taşarsa da sorun çıkarmaması için scrollview içinde.
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Skeleton
            Container(
              width: 140,
              height: 32,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Countdown Card Skeleton (Hero Area)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 12),

            // Daily Spend Skeleton
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),

            // Budget Progress Skeleton
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 12),

            // Savings Card Skeleton
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),

            // Subscriptions & Summary Skeleton (Alt alta)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Transactions (List style)
            Container(
              height: 200, // Ekranın en altına kadar doldurması için biraz uzun
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
      duration: 1500.ms,
      color: isDark ? Colors.white10 : Colors.black12, // Shimmer parıltı rengi
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, child) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              PaydayButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  ref.invalidate(userSettingsProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPrompt(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.elevatedShadow,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 64,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Welcome to Payday!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your smart companion for tracking money\nuntil your next payday',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: AppSpacing.xxl),
            PaydayButton(
              text: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              width: double.infinity,
              onPressed: () {
                Navigator.pushNamed(context, '/onboarding');
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionScreen(),
    );
  }

  void _showAddFundsSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFundsScreen(),
    );
  }
}


class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(context),
                  fontSize: 14,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
