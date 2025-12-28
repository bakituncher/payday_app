import 'dart:ui';
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
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:intl/intl.dart';

// Transaction importları
import 'package:payday/core/models/transaction.dart' as model;
import 'package:uuid/uuid.dart';

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
  final _initialBalanceController = TextEditingController();

  // Focus Nodes
  final FocusNode _incomeFocus = FocusNode();
  final FocusNode _balanceFocus = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = CurrencyFormatter.getLocalCurrencyCode();
    _recalculateNextPayday();
  }

  void _recalculateNextPayday() {
    if (_selectedPayCycle == AppConstants.payCycleSemiMonthly) {
      _nextPayday = _calculateNextSemiMonthlyPayday();
    } else {
      final daysToAdd = _selectedPayCycle == AppConstants.payCycleWeekly
          ? 7
          : _selectedPayCycle == AppConstants.payCycleBiWeekly
          ? 14
          : 30;
      _nextPayday = DateTime.now().add(Duration(days: daysToAdd));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _initialBalanceController.dispose();
    _incomeFocus.dispose();
    _balanceFocus.dispose();
    super.dispose();
  }

  DateTime _calculateNextSemiMonthlyPayday() {
    final now = DateTime.now();
    final currentDay = now.day;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

    if (currentDay < 15) {
      return DateTime(now.year, now.month, 15);
    } else if (currentDay < lastDayOfMonth) {
      return DateTime(now.year, now.month, lastDayOfMonth);
    } else {
      return DateTime(now.year, now.month + 1, 15);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPayday,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppColors.getTextPrimary(context),
              surface: AppColors.getCardBackground(context),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPink,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.getCardBackground(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              headerBackgroundColor: AppColors.primaryPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _nextPayday = picked);
    }
  }

  void _previousPage() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOutCubic);
  }

  Future<void> _nextPage() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (_currentPage == 1) {
      if (_incomeController.text.isEmpty || double.tryParse(_incomeController.text) == null) {
        _showErrorSnackBar('Please enter a valid income amount');
        return;
      }
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
      Future.delayed(450.ms, () => _balanceFocus.requestFocus());

    } else if (_currentPage == 2) {
      await _saveSettings();
    } else {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
      Future.delayed(450.ms, () => _incomeFocus.requestFocus());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() { _isLoading = true; });
    try {
      final userId = ref.read(currentUserIdProvider);
      final initialBalance = double.tryParse(_initialBalanceController.text) ?? 0.0;

      if (initialBalance > 0) {
        final transactionRepo = ref.read(transactionRepositoryProvider);
        final initialDeposit = model.Transaction(
          id: const Uuid().v4(),
          userId: userId,
          amount: initialBalance,
          isExpense: false,
          categoryId: 'initial_deposit',
          categoryName: 'Initial Deposit',
          categoryEmoji: '💰',
          date: DateTime.now(),
          note: 'Starting balance',
          isRecurring: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await transactionRepo.addTransaction(initialDeposit);
      }

      final settings = UserSettings(
        userId: userId,
        currency: _selectedCurrency,
        payCycle: _selectedPayCycle,
        nextPayday: _nextPayday,
        incomeAmount: double.parse(_incomeController.text),
        currentBalance: initialBalance,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(userSettingsRepositoryProvider).saveUserSettings(settings);
      ref.invalidate(userSettingsProvider);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_currentPage > 0) {
            _previousPage();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.getBackground(context),
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // --- Dynamic Background ---
              Positioned(
                top: -100, right: -50,
                child: AnimatedContainer(
                  duration: 2.seconds,
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        (_currentPage == 0
                            ? AppColors.primaryPink
                            : AppColors.secondaryBlue)
                            .withOpacity(isDark ? 0.18 : 0.12),
                        AppColors.secondaryPurple.withOpacity(isDark ? 0.14 : 0.10)
                      ],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50, left: -50,
                child: AnimatedContainer(
                  duration: 2.seconds,
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        (_currentPage == 2 ? AppColors.secondaryPurple : AppColors.warning)
                            .withOpacity(isDark ? 0.16 : 0.10),
                        (isDark ? AppColors.darkBackground : AppColors.backgroundWhite)
                            .withOpacity(isDark ? 0.10 : 0.06)
                      ],
                    ),
                  ),
                ),
              ),

              // --- Glassmorphism ---
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: (isDark ? AppColors.darkBackground : AppColors.backgroundWhite)
                      .withOpacity(isDark ? 0.35 : 0.40),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // --- Header ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          AnimatedOpacity(
                            opacity: _currentPage > 0 ? 1.0 : 0.0,
                            duration: 300.ms,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              color: AppColors.getTextPrimary(context),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.getCardBackground(context).withOpacity(isDark ? 0.72 : 0.92),
                                highlightColor: AppColors.getBorder(context).withOpacity(0.12),
                                elevation: 0,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.getBorder(context).withOpacity(isDark ? 0.20 : 0.26)),
                                ),
                              ),
                              onPressed: _currentPage > 0 ? _previousPage : null,
                            ),
                          ),
                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.getCardBackground(context).withOpacity(isDark ? 0.70 : 0.92),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.getBorder(context).withOpacity(isDark ? 0.18 : 0.24),
                              ),
                              boxShadow: AppColors.getCardShadow(context),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Step ${_currentPage + 1}",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.getTextPrimary(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: List.generate(3, (index) {
                                    final activeColor = _currentPage == 2
                                        ? AppColors.secondaryPurple
                                        : AppColors.primaryPink;
                                    final isActive = index == _currentPage;
                                    final isPassed = index < _currentPage;

                                    return AnimatedContainer(
                                      duration: 400.ms,
                                      curve: Curves.easeOutBack,
                                      margin: const EdgeInsets.only(left: 6),
                                      width: isActive ? 24 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? activeColor
                                            : (isPassed
                                            ? activeColor.withOpacity(0.3)
                                            : AppColors.getBorder(context).withOpacity(isDark ? 0.22 : 0.35)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),
                        ],
                      ),
                    ),

                    // --- Content PageView ---
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        children: [
                          _buildSetupPage(theme),
                          _buildMoneyInputPage(
                              theme: theme,
                              title: "What's your income?",
                              subtitle: "Enter your per-paycheck amount (after tax).",
                              controller: _incomeController,
                              focusNode: _incomeFocus,
                              color: AppColors.primaryPink,
                              icon: '💵',
                              infoText: "This amount will be added automatically on each payday."
                          ),
                          _buildMoneyInputPage(
                              theme: theme,
                              title: "Set your Pool",
                              subtitle: "How much money do you currently have?",
                              controller: _initialBalanceController,
                              focusNode: _balanceFocus,
                              color: AppColors.secondaryPurple,
                              icon: '🏦',
                              infoText: "Starting balance. Leave 0 to start fresh."
                          ),
                        ],
                      ),
                    ),

                    // --- Bottom Button ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: PaydayButton(
                        text: _currentPage == 2 ? 'Start Budgeting' : 'Continue',
                        onPressed: _isLoading ? null : _nextPage,
                        isLoading: _isLoading,
                        width: double.infinity,
                        size: PaydayButtonSize.large,
                        icon: _currentPage == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                      ).animate(target: _currentPage == 0 ? 0 : 1).shimmer(delay: 500.ms),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupPage(ThemeData theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(isDark ? 0.26 : 0.16),
                    AppColors.secondaryPurple.withOpacity(isDark ? 0.22 : 0.12),
                  ],
                ),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 40,
                color: AppColors.primaryPink,
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).moveY(begin: 8, end: 0),

          const SizedBox(height: 18),

          Text(
            "Let’s set up your pay cycle",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 80.ms),

          const SizedBox(height: 10),

          Text(
            "This helps Payday calculate your safe-to-spend limit and keep you on track until your next payday.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.getTextSecondary(context),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 140.ms),

          const SizedBox(height: 18),

          // Main glass card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context).withOpacity(isDark ? 0.60 : 0.86),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.getBorder(context).withOpacity(isDark ? 0.18 : 0.28),
                  ),
                  boxShadow: AppColors.getCardShadow(context),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pay frequency",
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(context),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Kart genişliği hesaplaması
                        final width = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildCycleCard(theme, AppConstants.payCycleWeekly, 'Weekly', '7d', width),
                            _buildCycleCard(theme, AppConstants.payCycleBiWeekly, 'Bi-Weekly', '14d', width),
                            _buildCycleCard(theme, AppConstants.payCycleSemiMonthly, 'Semi-Monthly', '2x', width),
                            _buildCycleCard(theme, AppConstants.payCycleMonthly, 'Monthly', '30d', width),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Next payday",
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(context),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context).withOpacity(isDark ? 0.52 : 0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.getBorder(context).withOpacity(isDark ? 0.16 : 0.24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink.withOpacity(isDark ? 0.18 : 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.event_rounded, color: AppColors.primaryPink, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(_nextPayday),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.getTextPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Tap to change",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.getTextSecondary(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondary(context)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(isDark ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.lock_rounded, size: 14, color: AppColors.primaryPink),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "You can change this anytime in Settings.",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
        ],
      ),
    );
  }

  // ✅ DÜZELTİLDİ: Dark Mode ve Layout Overflow Sorunları Giderildi
  Widget _buildCycleCard(ThemeData theme, String value, String title, String badge, double width) {
    final isSelected = _selectedPayCycle == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Renkleri sabitledik. Seçiliyken Pembe, Değilse Kart Rengi.
    // Bu sayede Dark mode'da Seçiliyken "Beyaz Yazı / Pembe Arka Plan" görünür.
    final Color backgroundColor = isSelected
        ? AppColors.primaryPink
        : AppColors.getCardBackground(context).withOpacity(isDark ? 0.50 : 0.92);

    final Color textColor = isSelected
        ? Colors.white
        : AppColors.getTextPrimary(context);

    final Color badgeBg = isSelected
        ? Colors.white.withOpacity(0.25)
        : AppColors.primaryPink.withOpacity(0.12);

    final Color badgeText = isSelected
        ? Colors.white
        : AppColors.primaryPink;

    final Color borderColor = isSelected
        ? Colors.transparent
        : AppColors.getBorder(context).withOpacity(isDark ? 0.15 : 0.24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedPayCycle = value;
            _recalculateNextPayday();
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          // Sabit "height: 100" kaldırıldı, yerine AspectRatio ve constraints kullanıldı
          // Bu, içeriğin taşmasını önler ve oranlı bir görünüm sağlar.
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(14), // Padding biraz azaltıldı (16->14)
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: borderColor,
                width: 1.5
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryPink.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                : AppColors.getCardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: badgeText
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, size: 18, color: Colors.white).animate().scale(),
                ],
              ),
              const SizedBox(height: 12), // Spacer yerine sabit boşluk
              FittedBox( // Metin çok uzunsa sığdırmak için küçültür
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textColor
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyInputPage({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Color color,
    required String icon,
    required String infoText,
  }) {
    final isSymbolRight = CurrencyFormatter.isSymbolOnRight(_selectedCurrency);
    final symbol = CurrencyFormatter.getSymbol(_selectedCurrency);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isSmallScreen = availableHeight < 600;

        final topPadding = isSmallScreen ? 12.0 : 20.0;
        final iconSize = isSmallScreen ? 40.0 : 48.0;
        final iconPadding = isSmallScreen ? 16.0 : 24.0;
        final spacingAfterIcon = isSmallScreen ? 20.0 : 32.0;
        final spacingAfterInput = isSmallScreen ? 24.0 : 48.0;
        final titleFontSize = isSmallScreen ? 24.0 : null;
        final inputFontSize = isSmallScreen ? 40.0 : 48.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, topPadding, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Text(icon, style: TextStyle(fontSize: iconSize)),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              SizedBox(height: spacingAfterIcon),

              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.getTextPrimary(context),
                  fontSize: titleFontSize,
                ),
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.getTextSecondary(context),
                    fontSize: isSmallScreen ? 13 : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: spacingAfterInput),

              // --- Input Area ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (!isSymbolRight)
                    Text(symbol, style: TextStyle(fontSize: isSmallScreen ? 30 : 36, fontWeight: FontWeight.bold, color: color)),

                  Flexible(
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _nextPage(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          LengthLimitingTextInputFormatter(9),
                        ],
                        style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.getTextPrimary(context),
                            fontSize: inputFontSize
                        ),
                        textAlign: TextAlign.center,
                        cursorColor: color,
                        cursorWidth: 3,
                        cursorRadius: const Radius.circular(2),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: AppColors.getBorder(context).withOpacity(isDark ? 0.45 : 0.55)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),

                  if (isSymbolRight)
                    Text(symbol, style: TextStyle(fontSize: isSmallScreen ? 30 : 36, fontWeight: FontWeight.bold, color: color)),
                ],
              ).animate().fadeIn(delay: 200.ms),

              Container(
                height: 2,
                width: isSmallScreen ? 100 : 120,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),

              SizedBox(height: spacingAfterInput),

              // --- Info Box ---
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context).withOpacity(isDark ? 0.60 : 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.getBorder(context).withOpacity(isDark ? 0.18 : 0.24)),
                    boxShadow: AppColors.getCardShadow(context)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        infoText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.getTextSecondary(context),
                          height: 1.3,
                          fontSize: isSmallScreen ? 13 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: isSmallScreen ? 12 : 20),
            ],
          ),
        );
      },
    );
  }
}