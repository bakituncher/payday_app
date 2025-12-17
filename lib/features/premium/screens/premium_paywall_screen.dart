/// Premium Paywall Screen
/// Industry-grade premium UI for ad-free subscription
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isProcessing = false;
  String _selectedPlan = 'yearly'; // 'monthly' or 'yearly'

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
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    // Simulate purchase process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      // TODO: Implement actual purchase logic with in-app purchases
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Purchase flow would start for $_selectedPlan plan'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _restorePurchases() async {
    HapticFeedback.lightImpact();
    // TODO: Implement restore purchases logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore purchases would be triggered here'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get localized price with user's currency
  String _getLocalizedPrice(double usdPrice) {
    final currencyCode = ref.read(syncCurrencyCodeProvider);
    final currencySymbol = ref.read(syncCurrencySymbolProvider);

    // Simple conversion rates (in real app, use actual exchange rates API)
    final conversionRates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'TRY': 32.50,
      'CAD': 1.36,
      'AUD': 1.53,
      'JPY': 149.0,
      'INR': 83.0,
    };

    final rate = conversionRates[currencyCode] ?? 1.0;
    final convertedPrice = usdPrice * rate;

    return '$currencySymbol${convertedPrice.toStringAsFixed(2)}';
  }

  /// Get localized monthly price description
  String _getLocalizedMonthlyPrice(double usdMonthlyPrice) {
    final currencyCode = ref.read(syncCurrencyCodeProvider);
    final currencySymbol = ref.read(syncCurrencySymbolProvider);

    final conversionRates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'TRY': 32.50,
      'CAD': 1.36,
      'AUD': 1.53,
      'JPY': 149.0,
      'INR': 83.0,
    };

    final rate = conversionRates[currencyCode] ?? 1.0;
    final convertedPrice = usdMonthlyPrice * rate;

    return 'Just $currencySymbol${convertedPrice.toStringAsFixed(2)}/month';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.darkCharcoal,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  children: [
                    // Premium badge with glow effect
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

                    // Pricing cards
                    _buildPricingCards()
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .scale(delay: 500.ms),

                    const SizedBox(height: 24),

                    // Subscribe button
                    PaydayButton(
                      text: 'Remove Ads',
                      icon: FontAwesomeIcons.ban,
                      isLoading: _isProcessing,
                      width: double.infinity,
                      size: PaydayButtonSize.large,
                      onPressed: _handlePurchase,
                      gradient: AppColors.premiumGradient,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    // Restore purchases
                    TextButton(
                      onPressed: _restorePurchases,
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

  Widget _buildPricingCards() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
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
          isSelected: _selectedPlan == 'yearly',
          isRecommended: true,
          title: 'Yearly',
          price: _getLocalizedPrice(9.99),
          period: '/year',
          savings: 'Save 60%',
          description: _getLocalizedMonthlyPrice(0.83),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPlan = 'yearly');
          },
        ),

        const SizedBox(height: 14),

        _buildPricingCard(
          isSelected: _selectedPlan == 'monthly',
          isRecommended: false,
          title: 'Monthly',
          price: _getLocalizedPrice(1.99),
          period: '/month',
          savings: null,
          description: 'Billed monthly',
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPlan = 'monthly');
          },
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required bool isSelected,
    required bool isRecommended,
    required String title,
    required String price,
    required String period,
    required String? savings,
    required String description,
    required VoidCallback onTap,
  }) {
    // Animasyon süresi
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // KATMAN 1: Pasif Arkaplan (Sürekli altta durur)
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
            // İçeriği burada boş bir Container ile dolduruyoruz ki yükseklik aynı kalsın
            // (Asıl içerik Stack'in en üstünde olacak)
            child: const Opacity(
              opacity: 0,
              child: _PricingCardContent(
                title: '',
                description: '',
                price: '',
                period: '',
                savings: null,
                isSelected: false,
              ),
            ),
          ),

          // KATMAN 2: Aktif Arkaplan (Gradient & Glow)
          // AnimatedContainer yerine AnimatedOpacity kullanarak "cross-fade" yapıyoruz.
          // Bu sayede gradient ve solid color arasındaki geçiş pürüzsüz olur.
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
                  // Seçiliyken border'ı transparan yapıyoruz ki double border olmasın
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
                title: title,
                description: description,
                price: price,
                period: period,
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

// İçerik widget'ını ayırdım ki Stack içinde temiz kalsın
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
              curve: Curves.elasticOut, // Pıt diye çıkma efekti
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