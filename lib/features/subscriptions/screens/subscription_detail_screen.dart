/// Subscription Detail Screen
/// Shows detailed information about a subscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.getBackground(context),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                color: AppColors.darkCharcoal,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: AppColors.darkCharcoal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'pause', child: Text('Pause')),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel Subscription', style: TextStyle(color: AppColors.error)),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                  onSelected: (value) => _handleMenuAction(context, ref, value),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Center(
                          child: Text(
                            subscription.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        subscription.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.round),
                        ),
                        child: Text(
                          subscription.status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cost Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currencyFormat.format(subscription.amount),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                Text(
                                  subscription.frequencyText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    currencyFormat.format(subscription.yearlyCost),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                  Text(
                                    '/year',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Next Billing
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.event_note_rounded,
                            color: AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Billing Date',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(subscription.nextBillingDate),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: subscription.daysUntilBilling <= 3
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                          child: Text(
                            '${subscription.daysUntilBilling} days',
                            style: TextStyle(
                              color: subscription.daysUntilBilling <= 3
                                  ? AppColors.warning
                                  : AppColors.mediumGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Details Section
                  Text(
                    'Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Category', subscription.category.name.toUpperCase(), subscription.categoryEmoji),
                        const Divider(height: 24),
                        _buildDetailRow('Currency', subscription.currency, '💵'),
                        if (subscription.startDate != null) ...[
                          const Divider(height: 24),
                          _buildDetailRow('Started', dateFormat.format(subscription.startDate!), '📅'),
                        ],
                        if (subscription.reminderEnabled) ...[
                          const Divider(height: 24),
                          _buildDetailRow('Reminder', '${subscription.reminderDaysBefore} days before', '🔔'),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          onTap: () => _handleMenuAction(context, ref, 'edit'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: subscription.status == SubscriptionStatus.active
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: subscription.status == SubscriptionStatus.active
                              ? 'Pause'
                              : 'Resume',
                          onTap: () => _handleMenuAction(
                            context,
                            ref,
                            subscription.status == SubscriptionStatus.active ? 'pause' : 'resume',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.cancel_outlined,
                          label: 'Cancel',
                          color: AppColors.error,
                          onTap: () => _handleMenuAction(context, ref, 'cancel'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.primaryPink;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    // userId'yi abonelik nesnesinden alıyoruz
    final userId = subscription.userId;

    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        break;

      case 'pause':
        // userId parametresini ekledik
        await ref.read(subscriptionNotifierProvider.notifier).pauseSubscription(subscription.id, userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subscription.name} paused'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
        break;

      case 'resume':
        // userId parametresini ekledik
        await ref.read(subscriptionNotifierProvider.notifier).resumeSubscription(subscription.id, userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subscription.name} resumed'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
        break;

      case 'cancel':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Cancel Subscription?',
          message: 'This will mark ${subscription.name} as cancelled. You can resume it later.',
        );
        if (confirmed == true) {
          // userId parametresini ekledik
          await ref.read(subscriptionNotifierProvider.notifier).cancelSubscription(subscription.id, userId);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Delete Subscription?',
          message: 'This will permanently delete ${subscription.name}. This action cannot be undone.',
          isDestructive: true,
        );
        if (confirmed == true) {
          // userId parametresini ekledik
          await ref.read(subscriptionNotifierProvider.notifier).deleteSubscription(subscription.id, userId);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
        break;
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.primaryPink,
            ),
            child: Text(isDestructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}

