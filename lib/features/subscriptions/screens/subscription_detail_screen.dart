/// Subscription Detail Screen
/// Shows detailed information about a subscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:payday/features/subscriptions/screens/add_subscription_screen.dart';
import 'package:payday/shared/widgets/payday_button.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  @override
  ConsumerState<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends ConsumerState<SubscriptionDetailScreen> {
  late Subscription _currentSubscription;

  @override
  void initState() {
    super.initState();
    _currentSubscription = widget.subscription;
  }

  Future<void> _refreshSubscription() async {
    // Fetch updated subscription from provider
    final repository = ref.read(subscriptionRepositoryProvider);
    final updatedSub = await repository.getSubscription(_currentSubscription.id);
    if (updatedSub != null && mounted) {
      setState(() {
        _currentSubscription = updatedSub;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = _currentSubscription;
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.getBackground(context),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _handleMenuAction(context, ref, 'edit'),
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              subscription.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subscription.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                          child: Text(
                            subscription.status.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.getCardShadow(context),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.getSubtle(context).withValues(alpha: 0.4)
                            : AppColors.getSubtle(context).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.frequencyText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.getTextSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(subscription.amount, currencyCode),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.payments_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Next Billing
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.getCardShadow(context),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
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
                                  color: AppColors.getTextSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(subscription.nextBillingDate),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextPrimary(context),
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
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.getSubtle(context),
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                          child: Text(
                            '${subscription.daysUntilBilling} days',
                            style: TextStyle(
                              color: subscription.daysUntilBilling <= 3
                                  ? AppColors.warning
                                  : AppColors.getTextSecondary(context),
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
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppColors.getCardShadow(context),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Category', subscription.category.name.toUpperCase(), subscription.categoryEmoji),
                        const Divider(height: 24),
                        _buildDetailRow('Annual Cost', CurrencyFormatter.format(subscription.yearlyCost, currencyCode), '💰', valueColor: AppColors.primaryPink),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Auto-Renewal',
                          subscription.autoRenew ? 'On' : 'Off',
                          '♻️',
                          valueColor: subscription.autoRenew ? AppColors.success : AppColors.error,
                        ),
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

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: PaydayButton(
                          text: 'Cancel',
                          icon: Icons.cancel_outlined,
                          backgroundColor: AppColors.warning,
                          onPressed: () => _handleMenuAction(context, ref, 'cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PaydayButton(
                          text: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          backgroundColor: AppColors.error,
                          onPressed: () => _handleMenuAction(context, ref, 'delete'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 350.ms),


                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String emoji, {Color? valueColor}) {
    return Builder(
      builder: (context) => Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.getTextPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    // userId'yi abonelik nesnesinden alıyoruz
    final userId = _currentSubscription.userId;

    switch (action) {
      case 'edit':
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => AddSubscriptionScreen(
              existingSubscription: _currentSubscription,
            ),
          ),
        );

        // If edit was successful, refresh the subscription
        if (result == true) {
          await _refreshSubscription();
        }
        break;

      case 'cancel':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Cancel Subscription?',
          message: 'This will mark ${_currentSubscription.name} as cancelled. You can resume it later.',
        );
        if (confirmed == true) {
          // userId parametresini ekledik
          await ref.read(subscriptionNotifierProvider.notifier).cancelSubscription(_currentSubscription.id, userId);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Delete Subscription?',
          message: 'This will permanently delete ${_currentSubscription.name}. This action cannot be undone.',
          isDestructive: true,
        );
        if (confirmed == true) {
          // userId parametresini ekledik
          await ref.read(subscriptionNotifierProvider.notifier).deleteSubscription(_currentSubscription.id, userId);
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