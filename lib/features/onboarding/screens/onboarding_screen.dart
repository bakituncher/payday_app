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
import 'package:payday/features/home/providers/home_providers.dart';

// ✅ EKLENDİ: Transaction oluşturmak için gerekli importlar
import 'package:payday/core/models/transaction.dart' as model; // Alias kullanıyoruz
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = CurrencyFormatter.getLocalCurrencyCode();

    // Varsayılan ödeme döngüsü için başlangıç tarihini ayarla
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
    super.dispose();
  }

  // Semi-monthly için sonraki maaş gününü hesapla (15. gün veya ayın son günü)
  DateTime _calculateNextSemiMonthlyPayday() {
    final now = DateTime.now();
    final currentDay = now.day;

    // Ayın son gününü bul
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

    // Eğer bugün 15'ten önceyse, bu ayın 15'i
    if (currentDay < 15) {
      return DateTime(now.year, now.month, 15);
    }
    // Eğer bugün 15 ile son gün arasındaysa, bu ayın son günü
    else if (currentDay < lastDayOfMonth) {
      return DateTime(now.year, now.month, lastDayOfMonth);
    }
    // Eğer bugün son günse veya sonrasıysa, gelecek ayın 15'i
    else {
      return DateTime(now.year, now.month + 1, 15);
    }
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
            colorScheme: const ColorScheme.light(
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
          const SnackBar(content: Text('Please enter a valid income amount'), backgroundColor: AppColors.error),
        );
        return;
      }
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
    } else if (_currentPage == 2) {
      await _saveSettings();
    } else {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
    }
  }

  Future<void> _saveSettings() async {
    setState(() { _isLoading = true; });
    try {
      final userId = ref.read(currentUserIdProvider);
      final initialBalance = double.tryParse(_initialBalanceController.text) ?? 0.0;

      // 1. Transaction Oluştur (Eğer bakiye > 0 ise)
      // ✅ DÜZELTİLDİ: Transaction model yapınıza uygun parametreler kullanıldı.
      if (initialBalance > 0) {
        final transactionRepo = ref.read(transactionRepositoryProvider);

        final initialDeposit = model.Transaction(
          id: const Uuid().v4(),
          userId: userId,
          amount: initialBalance,

          // isExpense: FALSE (Bu bir gelirdir)
          isExpense: false,

          // Kategori Bilgileri (Zorunlu alanlar)
          categoryId: 'initial_deposit',
          categoryName: 'Initial Deposit',
          categoryEmoji: '💰',

          date: DateTime.now(),

          // Açıklama (Title yerine Note kullanılıyor)
          note: 'Starting balance',

          isRecurring: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await transactionRepo.addTransaction(initialDeposit);
      }

      // 2. Ayarları Kaydet
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

      // 3. Provider'ları Sıfırla
      ref.invalidate(userSettingsProvider);

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

    return PopScope(
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
        backgroundColor: const Color(0xFFF8F9FC),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned(
              top: -100, right: -50,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryPink.withOpacity(0.2), AppColors.secondaryPurple.withOpacity(0.1)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50, left: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.withOpacity(0.1), AppColors.secondaryPurple.withOpacity(0.1)],
                  ),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.3)),
            ),

            SafeArea(
              child: Column(
                children: [
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            children: [
                              Text("Step ${_currentPage + 1}", style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
                              Text(" / 3", style: theme.textTheme.labelMedium?.copyWith(color: AppColors.mediumGray)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      children: [
                        _buildSetupPage(theme),
                        _buildIncomePage(theme),
                        _buildInitialBalancePage(theme),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [const Color(0xFFF8F9FC).withOpacity(0), const Color(0xFFF8F9FC)],
                      ),
                    ),
                    child: PaydayButton(
                      text: _currentPage == 2 ? 'Start Budgeting' : 'Continue',
                      onPressed: _isLoading ? null : _nextPage,
                      isLoading: _isLoading,
                      width: double.infinity,
                      size: PaydayButtonSize.large,
                      icon: _currentPage == 2 ? Icons.rocket_launch_rounded : null,
                    ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
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

          Text("HOW OFTEN?", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.mediumGray)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 2,
                child: _buildCompactCycleOption(theme, AppConstants.payCycleWeekly, 'Weekly', '7d'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 2,
                child: _buildCompactCycleOption(theme, AppConstants.payCycleBiWeekly, 'Bi-Weekly', '14d'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 2,
                child: _buildCompactCycleOption(theme, AppConstants.payCycleSemiMonthly, 'Semi-Monthly', '15d'),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 2,
                child: _buildCompactCycleOption(theme, AppConstants.payCycleMonthly, 'Monthly', '30d'),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

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
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
                      ),
                      const SizedBox(height: 4),
                      Text("Tap to change date", style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryPink)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryPink, size: 24),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(curve: Curves.elasticOut, duration: 600.ms),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCompactCycleOption(ThemeData theme, String value, String title, String badge) {
    final isSelected = _selectedPayCycle == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedPayCycle = value;

          // Semi-monthly seçildiğinde otomatik maaş gününü ayarla
          if (value == AppConstants.payCycleSemiMonthly) {
            _nextPayday = _calculateNextSemiMonthlyPayday();
          } else {
            // Diğer döngüler için varsayılan hesaplama
            final daysToAdd = value == AppConstants.payCycleWeekly
                ? 7
                : value == AppConstants.payCycleBiWeekly
                    ? 14
                    : 30;
            _nextPayday = DateTime.now().add(Duration(days: daysToAdd));
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2), width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.darkCharcoal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 8))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white.withOpacity(0.6) : AppColors.primaryPink),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14, color: isSelected ? Colors.white : AppColors.darkCharcoal),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: const Icon(Icons.check_circle, size: 16, color: AppColors.primaryPink).animate().scale(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomePage(ThemeData theme) {
    final isSymbolRight = CurrencyFormatter.isSymbolOnRight(_selectedCurrency);
    final symbol = CurrencyFormatter.getSymbol(_selectedCurrency);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), shape: BoxShape.circle),
            child: const Text('💵', style: TextStyle(fontSize: 40)),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            "What's your income?",
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
          ).animate().fadeIn(),

          const SizedBox(height: 8),
          Text(
            "Enter your per-paycheck amount (after tax)",
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mediumGray),
          ),

          const SizedBox(height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (!isSymbolRight)
                Text(symbol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mediumGray)),

              IntrinsicWidth(
                child: TextField(
                  controller: _incomeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkCharcoal, fontSize: 48),
                  textAlign: TextAlign.center,
                  cursorColor: AppColors.primaryPink,
                  cursorWidth: 3,
                  cursorRadius: const Radius.circular(2),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.lightGray.withOpacity(0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),

              if (isSymbolRight)
                Text(symbol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mediumGray)),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          Container(
            height: 2, width: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
          ),

          const SizedBox(height: 48),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lightGray.withOpacity(0.5))),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.mediumGray),
                const SizedBox(width: 12),
                Expanded(child: Text("This amount will be automatically added to your pool on each payday.", style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mediumGray, height: 1.4))),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildInitialBalancePage(ThemeData theme) {
    final isSymbolRight = CurrencyFormatter.isSymbolOnRight(_selectedCurrency);
    final symbol = CurrencyFormatter.getSymbol(_selectedCurrency);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.secondaryPurple.withOpacity(0.1), shape: BoxShape.circle),
            child: const Text('🏦', style: TextStyle(fontSize: 40)),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            "Set your Pool",
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
          ).animate().fadeIn(),

          const SizedBox(height: 8),
          Text(
            "How much money do you currently have in your accounts/pocket?",
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mediumGray),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (!isSymbolRight)
                Text(symbol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondaryPurple)),

              IntrinsicWidth(
                child: TextField(
                  controller: _initialBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkCharcoal, fontSize: 48),
                  textAlign: TextAlign.center,
                  cursorColor: AppColors.secondaryPurple,
                  cursorWidth: 3,
                  cursorRadius: const Radius.circular(2),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.lightGray.withOpacity(0.5)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),

              if (isSymbolRight)
                Text(symbol, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondaryPurple)),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          Container(
            height: 2, width: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: AppColors.secondaryPurple.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
          ),

          const SizedBox(height: 48),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lightGray.withOpacity(0.5))),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined, size: 18, color: AppColors.secondaryPurple),
                const SizedBox(width: 12),
                Expanded(child: Text("This is your starting pool. All income and expenses will be tracked from here. Leave at 0 to start fresh.", style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mediumGray, height: 1.4))),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lightGray.withOpacity(0.5))),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.mediumGray),
                const SizedBox(width: 12),
                Expanded(child: Text("Your financial data is stored locally and never shared.", style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mediumGray, height: 1.4))),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}