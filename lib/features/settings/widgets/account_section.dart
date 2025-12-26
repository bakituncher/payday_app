/// Account Section Widget
/// Displays user account information and authentication options
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/shared/widgets/payday_button.dart';

class AccountSection extends ConsumerWidget {
  final bool isFullyAuthenticated;
  final dynamic currentUser;
  final bool isSigningIn;
  final bool isAppleSignInAvailable;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onSignOut;

  const AccountSection({
    super.key,
    required this.isFullyAuthenticated,
    required this.currentUser,
    required this.isSigningIn,
    required this.isAppleSignInAvailable,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFullyAuthenticated)
            _buildAuthenticatedView(theme, context)
          else
            _buildUnauthenticatedView(theme, context),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildUserInfo(theme, context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        PaydayButton(
          text: 'Sign Out',
          icon: Icons.logout_rounded,
          isLoading: isSigningIn,
          width: double.infinity,
          onPressed: onSignOut,
          style: PaydayButtonStyle.outlined,
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign in to sync your data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GoogleSignInButton(
          isLoading: isSigningIn,
          onPressed: onGoogleSignIn,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isAppleSignInAvailable)
          AppleSignInButton(
            isLoading: isSigningIn,
            onPressed: onAppleSignIn,
          ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.pinkGradient,
      ),
      child: currentUser?.photoURL != null
          ? ClipOval(
              child: Image.network(
                currentUser!.photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentUser?.displayName ?? 'User',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          currentUser?.email ?? '',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.getTextSecondary(context),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: Colors.black.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/google_logo.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AppleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.white : Colors.black;
    final foregroundColor = isDark ? Colors.black : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: isDark ? 1 : 0,
          shadowColor: isDark ? Colors.white24 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: isDark ? BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ) : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    size: 20,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign in with Apple',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.31,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

