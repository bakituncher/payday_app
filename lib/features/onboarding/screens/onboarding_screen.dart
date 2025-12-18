/// Onboarding Screen - Setup wizard for first-time users - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryPink.withValues(alpha: 0.1),
                      AppColors.primaryPink.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryPurple.withValues(alpha: 0.08),
                      AppColors.secondaryPurple.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: List.generate(3, (index) {
                      final isActive = index <= _currentPage;
                      final isCurrent = index == _currentPage;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            gradient: isActive ? AppColors.pinkGradient : null,
                            color: isActive ? null : AppColors.lightGray,
                            borderRadius: BorderRadius.circular(AppRadius.round),
                            boxShadow: isCurrent
                                ? [
                              BoxShadow(
                                color: AppColors.primaryPink.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Step indicator & Back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentPage + 1} of 3',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _previousPage,
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.mediumGray),
                              const SizedBox(width: 4),
                              Text(
                                'Back',
                                style: TextStyle(color: AppColors.mediumGray),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildSetupPage(theme),
                      _buildIncomePage(theme),
                    ],
                  ),
                ),

                // Navigation Button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: PaydayButton(
                    text: _currentPage == 1 ? 'Get Started' : 'Continue',
                    onPressed: _isLoading ? null : _nextPage,
                    isLoading: _isLoading,
                    width: double.infinity,
                    icon: _currentPage == 1 ? Icons.check_rounded : null,
                    trailingIcon: _currentPage < 1 ? Icons.arrow_forward_rounded : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.elevatedShadow,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Welcome to Payday',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Track your money until next payday\nCurrency auto-detected: ${CurrencyFormatter.getSymbol(_selectedCurrency)} $_selectedCurrency',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.mediumGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: AppSpacing.xxl),

          // Pay Cycle Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: AppColors.secondaryPurple, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('How Often Are You Paid?', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPayCycleOption(theme, AppConstants.payCycleWeekly, 'Weekly', 'Every 7 days', 0),
                const SizedBox(height: AppSpacing.sm),
                _buildPayCycleOption(theme, AppConstants.payCycleBiWeekly, 'Bi-Weekly', 'Every 14 days', 1),
                const SizedBox(height: AppSpacing.sm),
                _buildPayCycleOption(theme, AppConstants.payCycleMonthly, 'Monthly', 'Once a month', 2),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Next Payday Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.event_rounded, color: AppColors.primaryPink, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Next Payday', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatDate(_nextPayday),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildPayCycleOption(ThemeData theme, String payCycle, String title, String description, int index) {
    final isSelected = _selectedPayCycle == payCycle;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPayCycle = payCycle;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPink : AppColors.subtleGray,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryPink : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryPink : AppColors.lightGray,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: isSelected ? Colors.white : Colors.transparent,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildIncomePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.subtleGray, shape: BoxShape.circle),
            child: const Text('💰', style: TextStyle(fontSize: 48)),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppSpacing.xl),
          Text('What\'s Your Income?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5), textAlign: TextAlign.center).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppSpacing.sm),
          Text('Enter your per-paycheck income (after tax)', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.mediumGray), textAlign: TextAlign.center).animate().fadeIn(duration: 300.ms, delay: 150.ms),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: AppColors.cardWhite, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppColors.cardShadow),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.subtleGray, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Row(
                    children: [
                      Text(CurrencyFormatter.getSymbol(_selectedCurrency), style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryPink)),
                      Expanded(
                        child: TextFormField(
                          controller: _incomeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w500, color: AppColors.mediumGray.withValues(alpha: 0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.info.withValues(alpha: 0.3))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('We\'ll use this to calculate how much you can safely spend each day until payday', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkCharcoal.withValues(alpha: 0.8), height: 1.4)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPayday,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryPink, onPrimary: Colors.white, surface: AppColors.cardWhite, onSurface: AppColors.darkCharcoal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _nextPayday = picked;
      });
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _nextPage() async {
    if (_currentPage == 1) {
      // Last page - validate and save
      if (_incomeController.text.isEmpty || double.tryParse(_incomeController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid income amount'), backgroundColor: AppColors.error));
        return;
      }
      await _saveSettings();
    } else {
      // First page - go to next
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _saveSettings() async {
    setState(() { _isLoading = true; });
    try {
      final authService = ref.read(authServiceProvider);
      // Ensure user is logged in (anonymous if needed) before saving
      if (authService.currentUser == null) {
        await authService.signInAnonymously();
      }

      final userId = authService.currentUser?.uid ?? 'unknown';
      final repository = ref.read(userSettingsRepositoryProvider);

      final settings = UserSettings(
        userId: userId,
        currency: _selectedCurrency,
        payCycle: _selectedPayCycle,
        nextPayday: _nextPayday,
        incomeAmount: double.parse(_incomeController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save settings to repository
      await repository.saveUserSettings(settings);

      if (mounted) {
        // Point-blank fix: Clear navigation stack and go to home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving settings: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }
}