/// Premium Card Widget
/// Displays premium status and upgrade options
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';
import 'package:payday/features/premium/screens/premium_paywall_screen.dart';

class PremiumCard extends ConsumerWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PremiumPaywallScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isPremium ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium Active' : 'Upgrade to Premium',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? 'Thank you for your support!'
                        : 'Remove ads and unlock exclusive features',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.1, end: 0)
          .shimmer(
            delay: 1000.ms,
            duration: 2000.ms,
            color: Colors.white.withValues(alpha: 0.3),
          ),
    );
  }
}

