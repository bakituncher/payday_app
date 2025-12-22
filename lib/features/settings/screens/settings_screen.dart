/// Settings Screen
/// Allows users to update their financial settings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/theme_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/premium/screens/premium_paywall_screen.dart';
import 'package:payday/core/services/data_migration_service.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:intl/intl.dart';

// ✅ EKLENDİ: Premium durumunu kontrol etmek için gerekli
import 'package:payday/features/premium/providers/premium_providers.dart';
// ✅ EKLENDİ: Döngü hesapları için servis
import 'package:payday/core/services/date_cycle_service.dart';
// ✅ EKLENDİ: Period balance provider'larını invalidate edebilmek için
import 'package:payday/features/home/providers/period_balance_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _incomeController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  String _selectedCurrency = 'USD';
  String _selectedPayCycle = 'Monthly';
  DateTime _nextPayday = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _isSigningIn = false;
  bool _isAppleSignInAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
    _checkAppleSignInAvailability();
  }

  Future<void> _checkAppleSignInAvailability() async {
    final authService = ref.read(authServiceProvider);
    final isAvailable = await authService.isAppleSignInAvailable();
    if (mounted) {
      setState(() {
        _isAppleSignInAvailable = isAvailable;
      });
    }
  }

  Future<void> _loadCurrentSettings() async {
    final settings = await ref.read(userSettingsProvider.future);
    if (settings != null && mounted) {
      setState(() {
        _incomeController.text = settings.incomeAmount.toStringAsFixed(2);
        _currentBalanceController.text = settings.currentBalance.toStringAsFixed(2);
        _selectedCurrency = settings.currency;
        _selectedPayCycle = settings.payCycle;
        _nextPayday = settings.nextPayday;
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _currentBalanceController.dispose();
    super.dispose();
  }

  Future<void> _selectPayday() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPayday,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkTextPrimary,
            )
                : const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              ),
              bodyLarge: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              ),
              bodyMedium: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
              ),
            ),
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

  void _selectCurrency() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCurrencyPicker(
      context: context,
      theme: CurrencyPickerThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
          fontSize: 14,
        ),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search currency...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primaryPink,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.getBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkBackground : AppColors.lightGray,
        ),
        currencySignTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
          fontSize: 16,
        ),
      ),
      favorite: AppConstants.popularCurrencies,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        HapticFeedback.mediumImpact();
        setState(() {
          _selectedCurrency = currency.code;
        });
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final authService = ref.read(authServiceProvider);
      final wasAnonymous = authService.isAnonymous;
      final sourceUserId = ref.read(currentUserIdProvider);

      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        if (wasAnonymous && !userCredential.user!.isAnonymous) {
          try {
            final migrationService = ref.read(dataMigrationServiceProvider);
            await migrationService.migrateLocalToFirebase(userCredential.user!.uid, sourceUserId);

            ref.invalidate(userSettingsRepositoryProvider);
            ref.invalidate(transactionRepositoryProvider);
          } catch (e) {
            print("Migration error: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data migration failed: $e")));
            }
          }
        }

        // Firebase'den verileri yükle
        ref.invalidate(userSettingsProvider);
        ref.invalidate(currentCycleTransactionsProvider);
        ref.invalidate(totalExpensesProvider);
        ref.invalidate(dailyAllowableSpendProvider);
        ref.invalidate(budgetHealthProvider);
        ref.invalidate(currentMonthlySummaryProvider);

        // Sayfa ayarlarını yeniden yükle
        await _loadCurrentSettings();

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Signed in as ${userCredential.user?.displayName ?? userCredential.user?.email}'),
                  ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Google: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final authService = ref.read(authServiceProvider);
      final wasAnonymous = authService.isAnonymous;
      final sourceUserId = ref.read(currentUserIdProvider);

      final userCredential = await authService.signInWithApple();

      if (userCredential != null) {
        if (wasAnonymous && !userCredential.user!.isAnonymous) {
          try {
            final migrationService = ref.read(dataMigrationServiceProvider);
            await migrationService.migrateLocalToFirebase(userCredential.user!.uid, sourceUserId);

            ref.invalidate(userSettingsRepositoryProvider);
            ref.invalidate(transactionRepositoryProvider);
          } catch (e) {
            print("Migration error: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data migration failed: $e")));
            }
          }
        }

        // Firebase'den verileri yükle
        ref.invalidate(userSettingsProvider);
        ref.invalidate(currentCycleTransactionsProvider);
        ref.invalidate(totalExpensesProvider);
        ref.invalidate(dailyAllowableSpendProvider);
        ref.invalidate(budgetHealthProvider);
        ref.invalidate(currentMonthlySummaryProvider);

        // Sayfa ayarlarını yeniden yükle
        await _loadCurrentSettings();

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Signed in as ${userCredential.user?.displayName ?? userCredential.user?.email}'),
                  ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in with Apple: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isSigningIn = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Signed out successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to delete your account. This action cannot be undone!',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'The following data will be permanently deleted:',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildDeleteWarningItem('All transactions and expenses'),
              _buildDeleteWarningItem('Financial settings and preferences'),
              _buildDeleteWarningItem('Account information'),
              _buildDeleteWarningItem('Premium subscription status'),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isSigningIn = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userSettingsRepo = ref.read(userSettingsRepositoryProvider);
      final transactionRepo = ref.read(transactionRepositoryProvider);

      await Future.wait([
        userSettingsRepo.deleteAllUserData(user.uid),
        transactionRepo.deleteAllUserTransactions(user.uid),
      ]);

      await authService.deleteAccount();

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Your account has been deleted successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while deleting the account: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_incomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your income amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(userSettingsRepositoryProvider);
      final currentSettings = await ref.read(userSettingsProvider.future);

      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          currency: _selectedCurrency,
          payCycle: _selectedPayCycle,
          nextPayday: _nextPayday,
          incomeAmount: double.parse(_incomeController.text),
          currentBalance: _currentBalanceController.text.isNotEmpty
              ? double.parse(_currentBalanceController.text)
              : 0.0,
          updatedAt: DateTime.now(),
        );

        await repository.saveUserSettings(updatedSettings);

        // Provider zincirini tazele: ayarlar ve dönem bakiyeleri
        ref.invalidate(userSettingsProvider);
        ref.invalidate(currentCycleTransactionsProvider);
        ref.invalidate(totalExpensesProvider);
        ref.invalidate(dailyAllowableSpendProvider);
        ref.invalidate(budgetHealthProvider);
        ref.invalidate(currentMonthlySummaryProvider);
        // ✅ EKLENDİ: Period ve period balance
        ref.invalidate(selectedPayPeriodProvider);
        ref.invalidate(selectedPeriodBalanceProvider);

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Settings saved successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final isFullyAuthenticated = ref.watch(isFullyAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('Account', Icons.person_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildAccountCard(theme, isFullyAuthenticated, currentUser),

            const SizedBox(height: AppSpacing.xl),

            // Premium
            _buildSectionTitle('Premium', Icons.workspace_premium_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildPremiumCard(theme),

            const SizedBox(height: AppSpacing.xl),

            // Income
            _buildSectionTitle('Income', Icons.attach_money_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildIncomeCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Pay Cycle
            _buildSectionTitle('Pay Cycle', Icons.calendar_today_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildPayCycleCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Next Payday
            _buildSectionTitle('Next Payday', Icons.event_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildPaydayCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Theme
            _buildSectionTitle('Appearance', Icons.palette_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildThemeCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Currency
            _buildSectionTitle('Currency', Icons.currency_exchange_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildCurrencyCard(theme),

            const SizedBox(height: AppSpacing.xxl),

            // Save Button
            PaydayButton(
              text: 'Save Settings',
              icon: Icons.check_rounded,
              isLoading: _isLoading,
              width: double.infinity,
              onPressed: _saveSettings,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPink),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(context),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(ThemeData theme, bool isFullyAuthenticated, dynamic currentUser) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFullyAuthenticated) ...[
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.pinkGradient,
                  ),
                  child: currentUser?.photoURL != null
                      ? ClipOval(
                    child: Image.network(
                      currentUser!.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.displayName ?? 'User',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUser?.email ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            PaydayButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              isLoading: _isSigningIn,
              width: double.infinity,
              onPressed: _handleSignOut,
              style: PaydayButtonStyle.outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            PaydayButton(
              text: 'Delete Account',
              icon: Icons.delete_outline_rounded,
              isLoading: _isSigningIn,
              width: double.infinity,
              onPressed: _showDeleteAccountDialog,
              style: PaydayButtonStyle.outlined,
              textColor: AppColors.error,
            ),
          ] else ...[
            Text(
              'Sign in to sync your data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildGoogleSignInButton(),
            const SizedBox(height: AppSpacing.sm),
            if (_isAppleSignInAvailable)
              _buildAppleSignInButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSigningIn ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: Colors.black.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isSigningIn
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/google_logo.svg',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.25,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSigningIn ? null : _handleAppleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isSigningIn
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.apple,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Apple',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.31,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ GÜNCELLENEN KISIM: Premium kart artık dinamik
  Widget _buildPremiumCard(ThemeData theme) {
    // Premium durumu kontrol ediliyor
    final isPremium = ref.watch(isPremiumProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PremiumPaywallScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                // İkon dinamik değişiyor
                isPremium ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Başlık dinamik değişiyor
                    isPremium ? 'Premium Active' : 'Upgrade to Premium',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Alt metin dinamik değişiyor
                    isPremium ? 'Thank you for your support!' : 'Remove ads and unlock exclusive features',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0).shimmer(
        delay: 1000.ms,
        duration: 2000.ms,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildIncomeCard(ThemeData theme) {
    final currencySymbol = CurrencyFormatter.getSymbol(_selectedCurrency);
    final isSymbolOnRight = CurrencyFormatter.isSymbolOnRight(_selectedCurrency);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Income',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixText: isSymbolOnRight ? null : currencySymbol,
              suffixText: isSymbolOnRight ? currencySymbol : null,
              prefixStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
              suffixStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Current Balance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _currentBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixText: isSymbolOnRight ? null : currencySymbol,
              suffixText: isSymbolOnRight ? currencySymbol : null,
              prefixStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
              suffixStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.secondaryPurple, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayCycleCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often do you get paid?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: AppConstants.payCycleOptions.map((cycle) {
              final isSelected = _selectedPayCycle == cycle;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: cycle != AppConstants.payCycleOptions.last ? AppSpacing.sm : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final prevCycle = _selectedPayCycle;
                      setState(() => _selectedPayCycle = cycle);

                      // Eğer döngü tipi değiştiyse nextPayday'i yeni döngüye göre otomatik ayarla
                      if (prevCycle != cycle) {
                        final adjusted = DateCycleService.calculateNextPayday(_nextPayday, cycle);
                        setState(() => _nextPayday = adjusted);

                        // Kullanıcıya bilgi ver
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pay cycle changed to "$cycle". Next payday adjusted. Tap date to change.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primaryPink,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.pinkGradient : null,
                        color: isSelected ? null : AppColors.getSubtle(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        cycle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaydayCard(ThemeData theme) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final daysUntil = _nextPayday.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _selectPayday();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.getBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primaryPink,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(_nextPayday),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysUntil > 0
                        ? '$daysUntil days away'
                        : daysUntil == 0
                        ? 'Today! 🎉'
                        : 'Tap to update',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: daysUntil < 0
                          ? AppColors.error
                          : AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(ThemeData theme) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.getBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose theme',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  theme: theme,
                  title: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.light);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildThemeOption(
                  theme: theme,
                  title: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.dark);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildThemeOption(
                  theme: theme,
                  title: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeNotifier.setThemeMode(ThemeMode.system);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.pinkGradient : null,
          color: isSelected ? null : AppColors.getSubtle(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(ThemeData theme) {
    final currencies = CurrencyService().getAll();
    final currencyPickerCurrency = currencies.firstWhere(
          (c) => c.code == _selectedCurrency,
      orElse: () => currencies.first,
    );
    final currencySymbol = CurrencyFormatter.getSymbol(_selectedCurrency);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _selectCurrency();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.getBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  currencyPickerCurrency.flag ?? '🌍',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyPickerCurrency.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_selectedCurrency $currencySymbol',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

