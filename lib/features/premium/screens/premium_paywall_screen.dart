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

// ✅ EKSİK OLAN IMPORTLAR EKLENDİ
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:payday/features/premium/providers/premium_providers.dart'; // Provider'lar burada
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

  // ✅ String yerine gerçek RevenueCat Paketi tutuyoruz
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

  // ✅ GERÇEK SATIN ALMA İŞLEMİ
  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      // Servis üzerinden satın al
      final customerInfo = await service.purchasePackage(_selectedPackage!);

      if (mounted) {
        setState(() => _isProcessing = false);

        // İşlem başarılı mı kontrol et (İptal edilmediyse customerInfo döner)
        if (customerInfo != null) {
          final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;

          if (isPremium) {
            // Global state'i güncelle
            ref.read(isPremiumProvider.notifier).state = true;

            Navigator.pop(context); // Ekranı kapat
            _showSuccessSnackBar('Welcome to Premium!');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        // Hata durumunda kullanıcıya bilgi ver (İptal hariç)
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

  // ✅ RESTORE (GERİ YÜKLEME) İŞLEMİ
  Future<void> _restorePurchases() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.restorePurchases();

      if (mounted) {
        setState(() => _isProcessing = false);
        final isPremium = customerInfo?.entitlements.all['premium']?.isActive ?? false;

        if (isPremium) {
          ref.read(isPremiumProvider.notifier).state = true;
          Navigator.pop(context);
          _showSuccessSnackBar('Purchases restored successfully!');
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
    // ✅ RevenueCat verilerini dinliyoruz
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkCharcoal,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: offeringsAsync.when(
              // Yükleniyor durumu
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              // Hata durumu
              error: (err, stack) => Center(
                child: Text(
                  'Could not load offers.\nPlease check your internet connection.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
              // Veri geldiğinde
              data: (offerings) {
                final currentOffering = offerings?.current;

                // Paket kontrolü: Panelde paket yoksa uyarı göster
                if (currentOffering == null || (currentOffering.monthly == null && currentOffering.annual == null)) {
                  return Center(
                    child: Text(
                      'No subscription offers available right now.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  );
                }

                // Varsayılan seçim mantığı (Yıllık varsa onu seç, yoksa aylık)
                if (_selectedPackage == null) {
                  _selectedPackage = currentOffering.annual ?? currentOffering.monthly;
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    child: Column(
                      children: [
                        // Premium badge
                        _buildPremiumBadge()
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'Remove Ads',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Focus on your finances without distractions',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 28),

                        // Features list
                        _buildFeaturesList()
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 28),

                        // Pricing cards - Dinamik oluşturuyoruz
                        _buildPricingCards(currentOffering)
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .scale(delay: 500.ms),

                        const SizedBox(height: 24),

                        // Subscribe button
                        PaydayButton(
                          text: _isProcessing ? 'Processing...' : 'Subscribe Now',
                          icon: _isProcessing ? null : FontAwesomeIcons.crown,
                          isLoading: _isProcessing,
                          width: double.infinity,
                          size: PaydayButtonSize.large,
                          onPressed: _handlePurchase,
                          gradient: AppColors.premiumGradient,
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 12),

                        // Restore purchases
                        TextButton(
                          onPressed: _isProcessing ? null : _restorePurchases,
                          child: Text(
                            'Restore Purchases',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms),

                        const SizedBox(height: 8),

                        // Terms
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fadeIn(delay: 800.ms),

                        const SizedBox(height: 16),

                        // Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLink('Terms of Service'),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildLink('Privacy Policy'),
                          ],
                        ).animate().fadeIn(delay: 900.ms),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Close button (overlay)
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.premiumGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.5),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: const FaIcon(
          FontAwesomeIcons.rectangleAd,
          size: 44,
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: FaIcon(
                  feature['icon'] as IconData,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 15),
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

  // ✅ Dinamik Pricing Cards Oluşturucu
  Widget _buildPricingCards(Offering offering) {
    return Column(
      children: [
        if (offering.annual != null) ...[
          // Best Value Badge
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

          // Yearly Card
          _buildPricingCard(
            package: offering.annual!,
            isRecommended: true,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPackage = offering.annual);
            },
          ),

          const SizedBox(height: 14),
        ],

        if (offering.monthly != null)
        // Monthly Card
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

  // ✅ Dinamik Kart Widget'ı (Package alır)
  Widget _buildPricingCard({
    required Package package,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPackage == package;
    final product = package.storeProduct;

    // Yıllık pakette aylık maliyet hesabı
    // Monthly için sadece "Billed monthly" yazısı
    String description;
    String? savings;

    if (package.packageType == PackageType.annual) {
      final monthlyPrice = product.price / 12;
      // Örn: $0.83 / month
      description = '${product.currencyCode} ${monthlyPrice.toStringAsFixed(2)} / month';
      savings = 'Save 60%'; // Bunu dinamik hesaplamak da mümkün ama sabit kalsın şimdilik
    } else {
      description = 'Billed monthly';
      savings = null;
    }

    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // KATMAN 1: Pasif Arkaplan
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            // Hayalet içerik (boyut korumak için)
            child: Opacity(
              opacity: 0,
              child: _PricingCardContent(
                title: 'Ghost',
                description: 'Ghost',
                price: 'Ghost',
                period: 'Ghost',
                savings: null,
                isSelected: false,
              ),
            ),
          ),

          // KATMAN 2: Aktif Arkaplan (Gradient & Glow)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(16),
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

          // KATMAN 3: İçerik
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _PricingCardContent(
                title: package.packageType == PackageType.annual ? 'Yearly' : 'Monthly',
                description: description,
                price: product.priceString, // Örn: ₺329.99
                period: package.packageType == PackageType.annual ? '/year' : '/month',
                savings: savings,
                isSelected: isSelected,
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
        // Radio Button
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

        // Plan details
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

        // Price
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