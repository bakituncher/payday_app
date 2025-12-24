import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:payday/features/subscriptions/screens/add_subscription_screen.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyCodeProvider);
    final dateFormat = DateFormat('d MMM yyyy');

    // Aktiflik kontrolü
    final bool isActive = subscription.status == SubscriptionStatus.active;

    // Progress Bar Hesabı
    double calculateProgress() {
      if (!isActive) return 0.0;

      final now = DateTime.now();
      final cycleDuration = subscription.frequency == 'yearly' ? 365 : 30;
      final estimatedStartDate = subscription.nextBillingDate.subtract(Duration(days: cycleDuration));

      final totalMilliseconds = subscription.nextBillingDate.difference(estimatedStartDate).inMilliseconds;
      final elapsedMilliseconds = now.difference(estimatedStartDate).inMilliseconds;

      if (totalMilliseconds == 0) return 0.0;

      double progress = elapsedMilliseconds / totalMilliseconds;
      return progress.clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- HEADER ---
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.getBackground(context),
            elevation: 0,
            // Sol: Geri Dön
            leading: _buildGlassIconButton(
              context,
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            // Sağ: Edit Butonu (Tek başına)
            actions: [
              _buildGlassIconButton(
                context,
                icon: Icons.edit_rounded,
                onTap: () => _handleMenuAction(context, ref, 'edit'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                    ),
                  ),
                  // Dekoratif Daire
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'sub_icon_${subscription.id}',
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                subscription.emoji,
                                style: const TextStyle(fontSize: 42),
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Hero(
                          tag: 'sub_name_${subscription.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              subscription.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 8),
                        _buildStatusBadge(subscription.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FİYAT KARTI ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.getCardShadow(context),
                      border: Border.all(color: AppColors.getBorder(context).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current Plan',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.getTextSecondary(context),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.format(subscription.amount, currencyCode),
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.getTextPrimary(context),
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              ' /${subscription.frequencyText.toLowerCase()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.getTextSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (isActive) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Billing Cycle', style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context), fontWeight: FontWeight.w600)),
                              Text('${subscription.daysUntilBilling} days left', style: TextStyle(fontSize: 12, color: subscription.daysUntilBilling <= 3 ? AppColors.error : AppColors.primaryPink, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: calculateProgress(),
                              minHeight: 8,
                              backgroundColor: AppColors.getBackground(context),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  subscription.daysUntilBilling <= 3 ? AppColors.error : AppColors.primaryPink
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Next: ${dateFormat.format(subscription.nextBillingDate)}',
                              style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_outlined, color: AppColors.getTextSecondary(context)),
                                const SizedBox(width: 8),
                                Text('Subscription Cancelled', style: TextStyle(color: AppColors.getTextSecondary(context), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  ).animate().moveY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  // --- BİLGİ KUTULARI (Bento Grid) ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          title: 'Yearly Cost',
                          value: CurrencyFormatter.format(subscription.yearlyCost, currencyCode),
                          icon: Icons.savings_rounded,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          title: 'Category',
                          value: subscription.category.name,
                          icon: Icons.category_rounded,
                          color: Colors.orangeAccent,
                          isCapitalize: true,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // --- DETAYLAR LİSTESİ ---
                  Text(
                    'Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.getCardShadow(context),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.calendar_today_rounded,
                          title: 'Start Date',
                          value: subscription.startDate != null
                              ? dateFormat.format(subscription.startDate!)
                              : 'Unknown',
                        ),
                        _buildDivider(context),
                        _buildListTile(
                          context,
                          icon: Icons.autorenew_rounded,
                          title: 'Auto-Renewal',
                          value: subscription.autoRenew ? 'On' : 'Off',
                          valueColor: subscription.autoRenew ? AppColors.success : AppColors.getTextSecondary(context),
                          trailing: Switch.adaptive(
                            value: subscription.autoRenew,
                            activeColor: AppColors.primaryPink,
                            onChanged: (val) => _toggleAutoRenew(context, ref, val),
                          ),
                        ),
                        _buildDivider(context),
                        _buildListTile(
                          context,
                          icon: Icons.notifications_active_rounded,
                          title: 'Reminders',
                          value: subscription.reminderEnabled
                              ? '${subscription.reminderDaysBefore} days before'
                              : 'Disabled',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // --- AKSİYON BUTONLARI (TAŞMA VE PAUSE GİDERİLDİ) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Cancel / Resume
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: isActive ? 'Cancel Subscription' : 'Resume',
                          icon: isActive ? Icons.cancel_outlined : Icons.play_arrow_rounded,
                          color: isActive ? Colors.orange : AppColors.success,
                          onTap: () => _handleMenuAction(
                              context,
                              ref,
                              isActive ? 'cancel' : 'resume'
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 2. Delete
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.error,
                          isDestructive: true,
                          onTap: () => _handleMenuAction(context, ref, 'delete'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  // Alt boşluk (Güvenli alan + ekstra)
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildGlassIconButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color color;
    switch (status) {
      case SubscriptionStatus.active: color = const Color(0xFF4ADE80); break; // Green
      case SubscriptionStatus.cancelled: color = const Color(0xFF9CA3AF); break; // Grey
      default: color = const Color(0xFF9CA3AF); // Default Grey
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isCapitalize = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCapitalize ? value[0].toUpperCase() + value.substring(1) : value,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryPink, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (trailing == null)
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.getTextPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: AppColors.getBorder(context).withValues(alpha: 0.5),
    );
  }

  // ESNEK BUTON YAPISI (TAŞMAYI ÖNLER)
  Widget _buildActionButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final bgColor = isDestructive ? Colors.transparent : color.withValues(alpha: 0.1);
    final fgColor = color;
    final borderSide = isDestructive ? BorderSide(color: color.withValues(alpha: 0.5)) : BorderSide.none;

    return FilledButton.tonal(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      style: FilledButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        side: borderSide,
        // Sabit yükseklik yerine esnek padding
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // İçeriği sıkıştır
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 6),
          // Yazı sığmazsa otomatik küçülür, overflow hatası vermez
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  Future<void> _toggleAutoRenew(BuildContext context, WidgetRef ref, bool value) async {
    HapticFeedback.selectionClick();
    final updatedSub = subscription.copyWith(
      autoRenew: value,
      updatedAt: DateTime.now(),
    );

    await ref.read(subscriptionNotifierProvider.notifier).updateSubscription(updatedSub);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Auto-renewal enabled' : 'Auto-renewal disabled'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkCharcoal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    final userId = subscription.userId;

    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddSubscriptionScreen(
              existingSubscription: subscription,
            ),
          ),
        );
        break;

      case 'resume':
        await ref.read(subscriptionNotifierProvider.notifier).resumeSubscription(subscription.id, userId);
        if (context.mounted) _showSnack(context, 'Subscription resumed', isSuccess: true);
        break;

      case 'cancel':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Cancel Subscription?',
          message: 'This will prevent future billing cycles but keep history.',
        );
        if (confirmed == true) {
          await ref.read(subscriptionNotifierProvider.notifier).cancelSubscription(subscription.id, userId);
          // İptal edince pop yapmıyoruz, ekranda kalıp durumun değiştiğini görüyor
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          context,
          title: 'Delete Subscription?',
          message: 'This will permanently delete this subscription. This action cannot be undone.',
          isDestructive: true,
        );
        if (confirmed == true) {
          await ref.read(subscriptionNotifierProvider.notifier).deleteSubscription(subscription.id, userId);
          if (context.mounted) Navigator.of(context).pop();
        }
        break;
    }
  }

  void _showSnack(BuildContext context, String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? AppColors.success : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        backgroundColor: AppColors.getCardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Keep', style: TextStyle(color: AppColors.getTextSecondary(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isDestructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}