/// Premium Paywall Screen
/// Industry-grade premium UI for ad-free subscription with RevenueCat Integration
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';
import 'package:payday/core/services/revenue_cat_service.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isProcessing = false;

  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.purchasePackage(_selectedPackage!);

      if (mounted) {
        setState(() => _isProcessing = false);

        if (customerInfo != null) {
          final isPremium = customerInfo.entitlements.all[RevenueCatService.premiumEntitlementId]?.isActive ?? false;

          if (isPremium) {
            await refreshPremiumStatus(ref);
            // Satın alma bitince ekranı kapatmaya gerek yok,
            // build metodu isPremium true olduğu için otomatik olarak "Already Premium" arayüzüne dönecek.
            if (mounted) {
              _showSuccessSnackBar('Welcome to Premium!');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.restorePurchases();

      if (mounted) {
        setState(() => _isProcessing = false);
        final isPremium = customerInfo?.entitlements.all[RevenueCatService.premiumEntitlementId]?.isActive ?? false;

        if (isPremium) {
          await refreshPremiumStatus(ref);
          if (mounted) {
            _showSuccessSnackBar('Purchases restored successfully!');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active subscription found to restore.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ YENİ EKLENDİ: Premium durumunu kontrol et
    final isAlreadyPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.darkCharcoal,
      body: Stack(
        children: [
          // Arkaplan
          _buildAnimatedBackground(),

          // ✅ YENİ EKLENDİ: Eğer kullanıcı zaten premium ise özel ekran göster
          if (isAlreadyPremium)
            _buildAlreadyPremiumView(theme)
          else
            _buildPaywallContent(theme), // Değilse normal ödeme ekranını göster

          // Kapatma butonu (Her zaman görünür)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ YENİ WIDGET: Zaten Premium Olanlar İçin Görünüm
  Widget _buildAlreadyPremiumView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ]
              ),
              child: const Icon(
                FontAwesomeIcons.crown,
                size: 56,
                color: Color(0xFFFFD700), // Altın rengi
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text(
              'You are Premium!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 10),

            Text(
              'Thank you for supporting Payday.\nEnjoy your ad-free experience.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 36),

            PaydayButton(
              text: 'Awesome!',
              width: 200,
              onPressed: () => Navigator.pop(context),
              gradient: AppColors.premiumGradient,
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                try {
                  final service = ref.read(revenueCatServiceProvider);
                  await service.showManagementUI();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Could not open subscription management.'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Subscription',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  // Eski build içeriği buraya taşındı
  Widget _buildPaywallContent(ThemeData theme) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return SafeArea(
      child: offeringsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Could not load offers.\nPlease check your internet connection.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
        data: (offerings) {
          final currentOffering = offerings?.current;

          if (currentOffering == null || (currentOffering.monthly == null && currentOffering.annual == null)) {
            return Center(
              child: Text(
                'No subscription offers available right now.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            );
          }

          if (_selectedPackage == null) {
            _selectedPackage = currentOffering.annual ?? currentOffering.monthly;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                children: [
                  _buildPremiumBadge()
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 12),

                  Text(
                    'Remove Ads',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 4),

                  Text(
                    'Focus on your finances without distractions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  _buildFeaturesList()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  _buildPricingCards(currentOffering)
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .scale(delay: 500.ms),

                  const SizedBox(height: 16),

                  PaydayButton(
                    text: _isProcessing ? 'Processing...' : 'Subscribe Now',
                    icon: _isProcessing ? null : FontAwesomeIcons.crown,
                    isLoading: _isProcessing,
                    width: double.infinity,
                    size: PaydayButtonSize.large,
                    onPressed: _handlePurchase,
                    gradient: AppColors.premiumGradient,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: _isProcessing ? null : _restorePurchases,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Restore Purchases',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLink('Terms of Service'),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildLink('Privacy Policy'),
                    ],
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Diğer yardımcı widgetlar (Background, Badge, Features, PricingCards) AYNI KALACAK
  // Sadece yukarıdaki değişiklikleri yapman yeterli.

  // ... _buildAnimatedBackground ...
  // ... _buildPremiumBadge ...
  // ... _buildFeaturesList ...
  // ... _buildPricingCards ...
  // ... _buildPricingCard ...
  // ... _buildLink ...
  // ... _PricingCardContent class ...

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double pinkOffset = 25 * math.sin(2 * math.pi * _animationController.value);
        final double purpleOffset = 25 * math.sin(2 * math.pi * _animationController.value + math.pi);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkCharcoal,
                const Color(0xFF1F1B2E),
                const Color(0xFF2D1B3D),
              ],
              stops: [
                0.0,
                0.5 + (_animationController.value * 0.1),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100 + pinkOffset,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryPink.withValues(alpha: 0.3),
                        AppColors.primaryPink.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 150 + purpleOffset,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondaryPurple.withValues(alpha: 0.3),
                        AppColors.secondaryPurple.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.premiumGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: const FaIcon(
          FontAwesomeIcons.rectangleAd,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': FontAwesomeIcons.ban,
        'title': 'No Ads',
        'description': 'Enjoy Payday completely ad-free',
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: FaIcon(
                  feature['icon'] as IconData,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 23,
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn()
            .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildPricingCards(Offering offering) {
    return Column(
      children: [
        if (offering.annual != null) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              margin: const EdgeInsets.only(bottom: 10, right: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 2000.ms,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),

          _buildPricingCard(
            package: offering.annual!,
            isRecommended: true,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPackage = offering.annual);
            },
          ),
          const SizedBox(height: 10),
        ],

        if (offering.monthly != null)
          _buildPricingCard(
            package: offering.monthly!,
            isRecommended: false,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPackage = offering.monthly);
            },
          ),
      ],
    );
  }

  Widget _buildPricingCard({
    required Package package,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPackage == package;
    final product = package.storeProduct;

    String description;
    String? savings;

    if (package.packageType == PackageType.annual) {
      final monthlyPrice = product.price / 12;
      description = '${product.currencyCode} ${monthlyPrice.toStringAsFixed(2)} / month';
      savings = 'Save 60%';
    } else {
      description = 'Billed monthly';
      savings = null;
    }

    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;

    final contentWidget = _PricingCardContent(
      title: package.packageType == PackageType.annual ? 'Yearly' : 'Monthly',
      description: description,
      price: product.priceString,
      period: package.packageType == PackageType.annual ? '/year' : '/month',
      savings: savings,
      isSelected: isSelected,
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Opacity(
              opacity: isSelected ? 0 : 1,
              child: _PricingCardContent(
                title: package.packageType == PackageType.annual ? 'Yearly' : 'Monthly',
                description: description,
                price: product.priceString,
                period: package.packageType == PackageType.annual ? '/year' : '/month',
                savings: savings,
                isSelected: false,
              ),
            ),
          ),

          Positioned.fill(
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.transparent, width: 2),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: isSelected ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: contentWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String text) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _PricingCardContent extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String period;
  final String? savings;
  final bool isSelected;

  const _PricingCardContent({
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    required this.savings,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;

    return Row(
      children: [
        AnimatedContainer(
          duration: duration,
          curve: curve,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: duration,
              curve: Curves.elasticOut,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.premiumGradient,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: curve,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                child: Text(description),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            if (savings != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  savings!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}