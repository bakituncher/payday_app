import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/shared/widgets/payday_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.enterGuestMode();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialLogin(Future<dynamic> Function() signInMethod) async {
    setState(() => _isLoading = true);
    try {
      final cred = await signInMethod();

      if (cred != null && mounted) {
        final settingsRepo = ref.read(userSettingsRepositoryProvider);
        final hasCompletedOnboarding = await settingsRepo.hasCompletedOnboarding();

        if (mounted) {
          if (hasCompletedOnboarding) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        }
      }
    } catch (e) {
      _showError("Sign in failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = ref.read(authServiceProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Theme-aware premium background (same vibe as FeatureIntro)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppColors.primaryPink.withOpacity(0.18),
                              AppColors.secondaryPurple.withOpacity(0.14),
                              AppColors.darkBackground,
                            ]
                          : [
                              AppColors.primaryPink.withOpacity(0.10),
                              AppColors.secondaryPurple.withOpacity(0.08),
                              AppColors.backgroundWhite,
                            ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(),

                  // --- App Mark ---
                  Image.asset(
                    'assets/inapp.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Welcome to Payday",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextPrimary(context),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Track expenses, manage subscriptions,\nand master your budget.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextSecondary(context),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // --- Glass Card (actions) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context).withOpacity(isDark ? 0.62 : 0.82),
                          border: Border.all(
                            color: AppColors.getBorder(context).withOpacity(isDark ? 0.22 : 0.30),
                          ),
                          boxShadow: AppColors.getCardShadow(context),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                        child: Column(
                          children: [
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: CircularProgressIndicator(color: AppColors.primaryPink),
                              )
                            else ...[
                              // Google
                              _OAuthButton(
                                label: 'Continue with Google',
                                icon: SvgPicture.asset('assets/google_logo.svg', height: 22, width: 22),
                                onPressed: () => _handleSocialLogin(() => authService.signInWithGoogle()),
                              ),
                              const SizedBox(height: 12),

                              // Apple
                              _OAuthButton(
                                label: 'Continue with Apple',
                                icon: Icon(
                                  Icons.apple,
                                  size: 24,
                                  color: AppColors.getTextPrimary(context),
                                ),
                                onPressed: () => _handleSocialLogin(() => authService.signInWithApple()),
                              ),
                              const SizedBox(height: 12),

                              // Guest (subtle CTA to match OAuth buttons)
                              _OAuthButton(
                                label: 'Continue as Guest',
                                icon: Icon(
                                  Icons.person_outline,
                                  size: 24,
                                  color: AppColors.getTextPrimary(context),
                                ),
                                onPressed: _handleGuestLogin,
                              ),
                            ],

                            const SizedBox(height: 12),

                            Text(
                              'Your data stays yours. No spam — just clarity.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.getTextSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'By continuing, you agree to a better money routine.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getCardBackground(context).withOpacity(isDark ? 0.50 : 0.90),
          foregroundColor: AppColors.getTextPrimary(context),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColors.getBorder(context).withOpacity(isDark ? 0.22 : 0.32),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}