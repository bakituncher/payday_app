import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/providers/app_launch_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/feature_intro/models/feature_intro_page.dart';

class FeatureIntroScreen extends ConsumerStatefulWidget {
  const FeatureIntroScreen({super.key});

  @override
  ConsumerState<FeatureIntroScreen> createState() => _FeatureIntroScreenState();
}

class _FeatureIntroScreenState extends ConsumerState<FeatureIntroScreen> {
  final _controller = PageController();
  int _index = 0;

  List<FeatureIntroPage> get _pages => [
        const FeatureIntroPage(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Know where your money is going',
          description:
              'Track expenses in seconds and see your spending clearly — without the clutter.',
          bullets: [
            'Quick add with smart categories',
            'Clean monthly overview',
            'Helpful insights that stay private on your device',
          ],
        ),
        const FeatureIntroPage(
          icon: Icons.calendar_month_rounded,
          title: 'Built around your payday',
          description:
              'Set your pay cycle and we’ll organize your budget by the dates that matter to you.',
          bullets: [
            'Weekly, bi-weekly, monthly & semi-monthly cycles',
            'Pay-cycle aware summaries',
            'Stay on track until the next payday',
          ],
        ),
        const FeatureIntroPage(
          icon: Icons.subscriptions_rounded,
          title: 'Subscriptions, under control',
          description:
              'Spot recurring costs and keep your subscriptions from quietly draining your balance.',
          bullets: [
            'See what’s recurring at a glance',
            'Make better cancel/keep decisions',
            'Plan ahead with confidence',
          ],
        ),
        const FeatureIntroPage(
          icon: Icons.auto_graph_rounded,
          title: 'Smarter spending, effortless',
          description:
              'Payday turns your numbers into simple recommendations so you can make decisions faster.',
          bullets: [
            'Trends and highlights',
            'Monthly summaries',
            'A calmer, more intentional money routine',
          ],
        ),
      ];

  Future<void> _markSeenAndContinue() async {
    await ref
        .read(appLaunchFlagsRepositoryProvider)
        .setFeatureIntroSeen(seen: true);

    if (!mounted) return;

    // Decide next screen based on current auth + onboarding completion.
    final user = ref.read(currentUserProvider).asData?.value;

    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final settingsRepo = ref.read(userSettingsRepositoryProvider);
    final hasCompleted = await settingsRepo.hasCompletedOnboarding();

    if (!mounted) return;

    if (hasCompleted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _markSeenAndContinue();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle premium gradient background
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.10),
                        theme.colorScheme.secondary.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _markSeenAndContinue,
                        child: Text(
                          'Skip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _IntroCard(page: p),
                      ).animate().fadeIn(duration: 250.ms).moveY(begin: 10, end: 0);
                    },
                  ),
                ),

                // Indicator + CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                    children: [
                      _Dots(count: _pages.length, index: _index),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            isLast ? 'Get started' : 'Continue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You’re in control — not your budget.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final FeatureIntroPage page;

  const _IntroCard({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.cardColor.withOpacity(0.75),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.20),
                        theme.colorScheme.secondary.withOpacity(0.16),
                      ],
                    ),
                  ),
                  child: Icon(
                    page.icon,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ...page.bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Made for real life, not spreadsheets.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: selected ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.35),
          ),
        );
      }),
    );
  }
}
