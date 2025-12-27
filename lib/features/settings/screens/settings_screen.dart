// Settings Screen - Refactored and Modularized
// Allows users to update their financial settings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/shared/widgets/payday_button.dart';

// Controllers
import 'package:payday/features/settings/controllers/settings_controller.dart';
import 'package:payday/features/settings/controllers/auth_controller.dart';

// Models
import 'package:payday/features/settings/models/settings_form_data.dart';

// Widgets
import 'package:payday/features/settings/widgets/section_title.dart';
import 'package:payday/features/settings/widgets/account_section.dart';
import 'package:payday/features/settings/widgets/premium_card.dart';
import 'package:payday/features/settings/widgets/theme_card.dart';

// New sheet
import 'package:payday/features/settings/widgets/financial_profile_sheet.dart';

// Utils
// import 'package:payday/features/settings/utils/date_picker_dialog.dart' as settings_utils;

// Screens
import 'package:payday/features/settings/screens/app_info_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsFormData? _formData;
  bool _isLoading = false;
  bool _isSigningIn = false;
  bool _isAppleSignInAvailable = false;

  late SettingsController _settingsController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController(ref, context);
    _authController = AuthController(ref, context);
    _loadCurrentSettings();
    _checkAppleSignInAvailability();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsController = SettingsController(ref, context);
    _authController = AuthController(ref, context);
  }

  Future<void> _checkAppleSignInAvailability() async {
    final isAvailable = await _settingsController.checkAppleSignInAvailability();
    if (mounted) {
      setState(() {
        _isAppleSignInAvailable = isAvailable;
      });
    }
  }

  Future<void> _loadCurrentSettings() async {
    final formData = await _settingsController.loadSettings();
    if (formData != null && mounted) {
      setState(() {
        _formData = formData;
      });
    }
  }

  @override
  void dispose() {
    _formData?.dispose();
    super.dispose();
  }

  void _openFinancialProfileEditor({String? preselectedPayCycle}) {
    if (_formData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FinancialProfileSheet(
        initialIncome: double.tryParse(_formData!.incomeController.text) ?? 0.0,
        initialCurrentBalance: double.tryParse(_formData!.currentBalanceController.text) ?? 0.0,
        initialPayCycle: preselectedPayCycle ?? _formData!.selectedPayCycle,
        initialNextPayday: _formData!.nextPayday,
        initialCurrency: _formData!.selectedCurrency,
        onSave: (income, balance, cycle, date, currency) async {
          try {
            setState(() => _isLoading = true);
            await _settingsController.updateFinancialProfile(
              income: income,
              currentBalance: balance,
              payCycle: cycle,
              nextPayday: date,
              currency: currency,
            );
            await _loadCurrentSettings();

            if (mounted) {
              HapticFeedback.mediumImpact();
              _showSuccessSnackBar('Financial profile updated successfully!');
            }
          } catch (e) {
            if (mounted) {
              _showErrorSnackBar('Error updating financial profile: $e');
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final userName = await _authController.signInWithGoogle();
      if (userName != null) {
        await _loadCurrentSettings();
        if (mounted) {
          HapticFeedback.mediumImpact();
          _showSuccessSnackBar('Signed in as $userName');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error signing in with Google: $e');
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
      final userName = await _authController.signInWithApple();
      if (userName != null) {
        await _loadCurrentSettings();
        if (mounted) {
          HapticFeedback.mediumImpact();
          _showSuccessSnackBar('Signed in as $userName');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error signing in with Apple: $e');
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
      await _authController.signOut();
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('Successfully signed out');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error signing out: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formData == null) return;

    setState(() => _isLoading = true);

    try {
      await _settingsController.saveSettings(_formData!);
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('Settings saved successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error saving settings: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.asData?.value;
    final isFullyAuthenticated = ref.watch(isFullyAuthenticatedProvider);

    if (_formData == null) {
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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppInfoScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPink,
          ),
        ),
      );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppInfoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            const SectionTitle(
              title: 'Account',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            AccountSection(
              isFullyAuthenticated: isFullyAuthenticated,
              currentUser: currentUser,
              isSigningIn: _isSigningIn,
              isAppleSignInAvailable: _isAppleSignInAvailable,
              onGoogleSignIn: _handleGoogleSignIn,
              onAppleSignIn: _handleAppleSignIn,
              onSignOut: _handleSignOut,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Premium
            const SectionTitle(
              title: 'Premium',
              icon: Icons.workspace_premium_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            const PremiumCard(),

            const SizedBox(height: AppSpacing.xl),

            // Financial Profile (single source of truth for income/cycle/payday/currency)
            const SectionTitle(
              title: 'Financial Profile',
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            _FinancialSummaryCard(
              incomeText: _formData!.incomeController.text,
              payCycle: _formData!.selectedPayCycle,
              nextPayday: _formData!.nextPayday,
              currency: _formData!.selectedCurrency,
              onTap: _openFinancialProfileEditor,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Appearance
            const SectionTitle(
              title: 'Appearance',
              icon: Icons.palette_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            const ThemeCard(),


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
}

class _FinancialSummaryCard extends StatelessWidget {
  final String incomeText;
  final String payCycle;
  final DateTime nextPayday;
  final String currency;
  final VoidCallback onTap;

  const _FinancialSummaryCard({
    required this.incomeText,
    required this.payCycle,
    required this.nextPayday,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbol = CurrencyFormatter.getSymbol(currency);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPink,
              AppColors.primaryPink.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Cycle',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payCycle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryItem(
                  label: 'Income',
                  value: '$symbol$incomeText',
                ),
                Container(width: 1, height: 28, color: Colors.white.withOpacity(0.3)),
                _SummaryItem(
                  label: 'Next Payday',
                  value: DateFormat('MMM dd').format(nextPayday),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
