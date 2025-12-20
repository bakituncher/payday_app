import 'dart:ui'; // Blur efekti için gerekli
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String _selectedCurrency = AppConstants.defaultCurrency;
  String _selectedPayCycle = AppConstants.payCycleMonthly;
  DateTime _nextPayday = DateTime.now().add(const Duration(days: 30));
  final _incomeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = CurrencyFormatter.getLocalCurrencyCode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  // --- Logic Helpers (Aynen korundu) ---
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPayday,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _nextPayday = picked);
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOutCubic);
  }

  Future<void> _nextPage() async {
    if (_currentPage == 1) {
      if (_incomeController.text.isEmpty || double.tryParse(_incomeController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.error),
        );
        return;
      }
      await _saveSettings();
    } else {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
    }
  }

  Future<void> _saveSettings() async {
    setState(() { _isLoading = true; });
    try {
      // Anonymous otomatik giriş KALDIRILDI.
      // Onboarding yerel çalışır; buluta yedekleme istenirse ayarlardan giriş yapılır.
      final userId = ref.read(currentUserIdProvider);

      final settings = UserSettings(
        userId: userId,
        currency: _selectedCurrency,
        payCycle: _selectedPayCycle,
        nextPayday: _nextPayday,
        incomeAmount: double.parse(_incomeController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(userSettingsRepositoryProvider).saveUserSettings(settings);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Çok açık gri/beyaz premium zemin
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Modern Background Blobs with Blur
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPink.withOpacity(0.2),
                    AppColors.secondaryPurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.1),
                    AppColors.secondaryPurple.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Glassmorphism Blur Effect over blobs
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.white.withOpacity(0.3)),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          color: AppColors.darkCharcoal,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _previousPage,
                        ).animate().scale(),
                      const Spacer(),
                      // Şık Progress Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Step ${_currentPage + 1}",
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.darkCharcoal),
                            ),
                            Text(
                              " / 2",
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.mediumGray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    children: [
                      _buildSetupPage(theme),
                      _buildIncomePage(theme),
                    ],
                  ),
                ),

                // Bottom Action Button (Floating & Glassy)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF8F9FC).withOpacity(0),
                        const Color(0xFFF8F9FC),
                      ],
                    ),
                  ),
                  child: PaydayButton(
                    text: _currentPage == 1 ? 'Start Budgeting' : 'Continue',
                    onPressed: _isLoading ? null : _nextPage,
                    isLoading: _isLoading,
                    width: double.infinity,
                    size: PaydayButtonSize.large,
                    icon: _currentPage == 1 ? Icons.rocket_launch_rounded : null,
                  ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Setup your\nPay Cycle",
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
              height: 1.1,
              letterSpacing: -1,
            ),
          ).animate().fadeIn().slideX(),

          const SizedBox(height: 8),
          Text(
            "This helps us calculate your daily safe-to-spend limit.",
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mediumGray),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 32),

          // Section 1: Frequency
          Text("HOW OFTEN?", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.mediumGray)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildCompactCycleOption(theme, AppConstants.payCycleWeekly, 'Weekly', '7d')),
              const SizedBox(width: 12),
              Expanded(child: _buildCompactCycleOption(theme, AppConstants.payCycleBiWeekly, 'Bi-Weekly', '14d')),
              const SizedBox(width: 12),
              Expanded(child: _buildCompactCycleOption(theme, AppConstants.payCycleMonthly, 'Monthly', '30d')),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Section 2: Date Picker (Hero Card)
          Text("NEXT PAYDAY", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.mediumGray)),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryPink.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                ],
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(_nextPayday),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to change date",
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryPink),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_today_rounded, color: AppColors.primaryPink, size: 24),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(curve: Curves.elasticOut, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildCompactCycleOption(ThemeData theme, String value, String title, String badge) {
    final isSelected = _selectedPayCycle == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedPayCycle = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.darkCharcoal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 8))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white.withOpacity(0.6) : AppColors.primaryPink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: const Icon(Icons.check_circle, size: 16, color: AppColors.primaryPink)
                    .animate().scale(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Icon Animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('🤑', style: TextStyle(fontSize: 40)),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            "What's your income?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 8),
          Text(
            "Enter per-paycheck amount (after tax)",
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mediumGray),
          ),

          const SizedBox(height: 48),

          // Huge Input Field
          Column(
            children: [
              Text(
                  CurrencyFormatter.getSymbol(_selectedCurrency),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.mediumGray.withOpacity(0.5))
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                    fontSize: 48, // Massive font size
                  ),
                  textAlign: TextAlign.center,
                  cursorColor: AppColors.primaryPink,
                  cursorWidth: 3,
                  cursorRadius: const Radius.circular(2),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.lightGray.withOpacity(0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                height: 2,
                width: 100,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 48),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.mediumGray),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Your financial data is stored locally and never shared.",
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mediumGray, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}