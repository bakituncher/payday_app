import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/providers/app_launch_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/feature_intro/models/feature_intro_page.dart';
import 'package:payday/shared/widgets/payday_button.dart';

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
      icon: Icons.pie_chart_outline_rounded,
      title: 'Know where your\nmoney goes',
      description:
      'Track expenses in seconds and see your spending clearly — without the clutter.',
      bullets: [
        'Smart categorization',
        'Clean monthly overview',
        'Private & secure on your device',
      ],
    ),
    const FeatureIntroPage(
      icon: Icons.calendar_today_rounded,
      title: 'Built around\nyour payday',
      description:
      'Set your pay cycle and we’ll organize your budget by the dates that actually matter.',
      bullets: [
        'Supports all pay cycles',
        'Cycle-aware summaries',
        'Pacing until next payday',
      ],
    ),
    const FeatureIntroPage(
      icon: Icons.notifications_active_outlined,
      title: 'Subscriptions,\nunder control',
      description:
      'Spot recurring costs and keep unwanted subscriptions from draining your balance.',
      bullets: [
        'Recurring bill detection',
        'Renewal reminders',
        'Cancel/Keep decisions',
      ],
    ),
    const FeatureIntroPage(
      icon: Icons.insights_rounded,
      title: 'Smarter spending,\neffortless',
      description:
      'Payday turns your numbers into simple insights so you can make decisions faster.',
      bullets: [
        'Spending trends',
        'Financial health check',
        'Intentional money routine',
      ],
    ),
  ];

  Future<void> _markSeenAndContinue() async {
    await ref.read(appLaunchFlagsRepositoryProvider).setFeatureIntroSeen(seen: true);

    if (!mounted) return;

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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
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
    final isDark = theme.brightness == Brightness.dark;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // --- Ambient Animated Background ---
          const _AmbientBackground(),

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                // Top Bar (Skip) - Premium style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.getTextSecondary(context).withOpacity(0.1),
                        ),
                        child: TextButton(
                          onPressed: _markSeenAndContinue,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.getTextSecondary(context),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Skip',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _IntroCard(
                          page: _pages[i],
                          isActive: i == _index,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                  child: Column(
                    children: [
                      _Dots(count: _pages.length, index: _index),
                      const SizedBox(height: 36),
                      PaydayButton(
                        width: double.infinity,
                        text: isLast ? 'Get Started' : 'Continue',
                        onPressed: _next,
                        backgroundColor: AppColors.primaryPink,
                        size: PaydayButtonSize.large,
                      )
                          .animate(target: isLast ? 1 : 0)
                          .shimmer(duration: 1.5.seconds, delay: 600.ms), // Subtle shimmer on last step
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A visually rich card with glassmorphism and animations
class _IntroCard extends StatelessWidget {
  final FeatureIntroPage page;
  final bool isActive;

  const _IntroCard({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Glass styles
    final cardColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.65);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.6);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container - Premium Style
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                        AppColors.primaryPink.withOpacity(0.25),
                        AppColors.secondaryPurple.withOpacity(0.15),
                      ]
                          : [
                        AppColors.primaryPink.withOpacity(0.15),
                        AppColors.secondaryPurple.withOpacity(0.08),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withOpacity(isDark ? 0.3 : 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: AppColors.secondaryPurple.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    page.icon,
                    size: 52,
                    color: AppColors.primaryPink,
                  ),
                ).animate(target: isActive ? 1 : 0).scale(
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.7, 0.7),
                ),

                const SizedBox(height: 36),

                // Title - Premium Typography
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                    color: AppColors.getTextPrimary(context),
                  ),
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut).moveY(begin: 20, end: 0),

                const SizedBox(height: 20),

                // Description - Clean and readable
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.getTextSecondary(context),
                    height: 1.6,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

                const SizedBox(height: 40),

                // Bullets - Aligned and Premium
                Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: page.bullets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final text = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Premium Check Icon with gradient background
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondaryPurple.withOpacity(0.2),
                                    AppColors.primaryPink.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.secondaryPurple,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Text with flex to handle long content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.getTextPrimary(context),
                                    height: 1.4,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                        delay: (200 + (index * 80)).ms,
                        duration: 400.ms,
                      ).moveX(begin: -20, end: 0);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated background blobs for a premium feel - Enhanced
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Top Left Blob - Smooth animation
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryPink.withOpacity(isDark ? 0.2 : 0.12),
                  AppColors.primaryPink.withOpacity(isDark ? 0.05 : 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
            begin: const Offset(0, 0),
            end: const Offset(25, 25),
            duration: 5.seconds,
            curve: Curves.easeInOut,
          ),
        ),

        // Center Right Blob - Gentle pulse
        Positioned(
          top: 180,
          right: -180,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryPurple.withOpacity(isDark ? 0.18 : 0.1),
                  AppColors.secondaryPurple.withOpacity(isDark ? 0.06 : 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: 6.seconds,
            curve: Curves.easeInOut,
          ),
        ),

        // Bottom Left Blob - Smooth float
        Positioned(
          bottom: -80,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryPink.withOpacity(isDark ? 0.15 : 0.08),
                  AppColors.primaryPink.withOpacity(isDark ? 0.04 : 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
            begin: const Offset(0, 0),
            end: const Offset(-15, 30),
            duration: 7.seconds,
            curve: Curves.easeInOut,
          ),
        ),

        // Global Blur - Softer and more premium
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern Page Indicator - Instagram-style
class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: selected ? 36 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: selected
                ? LinearGradient(
              colors: [
                AppColors.primaryPink,
                AppColors.secondaryPurple,
              ],
            )
                : null,
            color: !selected
                ? AppColors.getTextSecondary(context).withOpacity(0.25)
                : null,
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
        );
      }),
    );
  }
}