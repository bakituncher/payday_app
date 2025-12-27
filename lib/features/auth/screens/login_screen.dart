import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/theme/app_theme.dart';

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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // --- Logo ---
              Image.asset(
                'assets/inapp.png',
                height: 120,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 48),

              // --- Title & Subtitle ---
              Text(
                "Welcome to Payday",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Track expenses, manage subscriptions,\nand master your budget.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGray,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // --- Action Buttons ---
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.primaryPink)
              else ...[
                // Google Button
                _LoginButton(
                  text: "Continue with Google",
                  iconWidget: SvgPicture.asset(
                      'assets/google_logo.svg',
                      height: 24,
                      width: 24
                  ),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => _handleSocialLogin(() => authService.signInWithGoogle()),
                ),

                const SizedBox(height: 16),

                // ✅ Apple Button (Platform kontrolü kaldırıldı, her yerde görünür)
                _LoginButton(
                  text: "Continue with Apple",
                  iconWidget: Icon(Icons.apple, size: 28, color: isDarkMode ? Colors.black : Colors.white),
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  textColor: isDarkMode ? Colors.black : Colors.white,
                  onPressed: () => _handleSocialLogin(() => authService.signInWithApple()),
                ),

                const SizedBox(height: 8),

                // Guest Button
                TextButton(
                  onPressed: _handleGuestLogin,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    "Continue as Guest",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final Widget iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final BorderSide borderSide;
  final VoidCallback onPressed;

  const _LoginButton({
    required this.text,
    required this.iconWidget,
    required this.backgroundColor,
    required this.textColor,
    this.borderSide = BorderSide.none,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}