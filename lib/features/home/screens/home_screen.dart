/// Home Screen - The Hero Feature - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/home/widgets/countdown_card.dart';
import 'package:payday/features/home/widgets/daily_spend_card.dart';
import 'package:payday/features/home/widgets/budget_progress_card.dart';
import 'package:payday/features/home/widgets/recent_transactions_card.dart';
import 'package:payday/features/home/widgets/active_subscriptions_card.dart';
import 'package:payday/features/home/widgets/monthly_summary_card.dart';
import 'package:payday/features/transactions/screens/add_transaction_screen.dart';
import 'package:payday/features/settings/screens/settings_screen.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettingsAsync = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: userSettingsAsync.when(
          loading: () => _buildLoadingState(),
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
                          AppColors.primaryPink.withOpacity(0.1),
                          AppColors.primaryPink.withOpacity(0.0),
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
                          AppColors.secondaryPurple.withOpacity(0.08),
                          AppColors.secondaryPurple.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                RefreshIndicator(
                  onRefresh: () => _onRefresh(ref),
                  color: AppColors.primaryPink,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                    // Premium App Bar
                    SliverAppBar(
                      expandedHeight: 0,
                      floating: true,
                      pinned: false,
                      backgroundColor: AppColors.backgroundWhite,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.pinkGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Payday',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // TODO: Navigate to notifications
                            },
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: AppSpacing.sm),

                          // Greeting
                          _GreetingSection()
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.1, end: 0),

                          const SizedBox(height: AppSpacing.md),

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

                          const SizedBox(height: AppSpacing.sm),

                          // Daily Allowable Spend Card
                          const DailySpendCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideX(begin: -0.1, end: 0),

                          const SizedBox(height: AppSpacing.sm),

                          // Budget Progress Card
                          BudgetProgressCard(
                            currency: settings.currency,
                            incomeAmount: settings.incomeAmount,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 300.ms)
                              .slideX(begin: 0.1, end: 0),

                          const SizedBox(height: AppSpacing.sm),

                          // Active Subscriptions Card
                          const ActiveSubscriptionsCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 350.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: AppSpacing.sm),

                          // Monthly Summary Card
                          const MonthlySummaryCard()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 375.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: AppSpacing.sm),

                          // Recent Transactions
                          RecentTransactionsCard(
                            currency: settings.currency,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 400.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 120), // Space for FAB
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
      floatingActionButton: userSettingsAsync.maybeWhen(
        data: (settings) => settings != null
            ? _PremiumFAB(
                onPressed: () => _showAddTransactionSheet(context),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  )
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 40,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(duration: 800.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading your finances...',
            style: TextStyle(
              color: AppColors.mediumGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
                  color: AppColors.mediumGray,
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
}

class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greeting.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              greeting.text,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Here\'s your financial overview',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  ({String text, String emoji}) _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return (text: 'Good Morning', emoji: '☀️');
    } else if (hour < 17) {
      return (text: 'Good Afternoon', emoji: '👋');
    } else {
      return (text: 'Good Evening', emoji: '🌙');
    }
  }
}

class _PremiumFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _PremiumFAB({required this.onPressed});

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(AppRadius.round),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: _isPressed ? 15 : 25,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Add Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

