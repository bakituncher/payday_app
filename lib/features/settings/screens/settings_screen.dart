// Settings Screen - Refactored and Modularized
// Allows users to update their financial settings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/auth_providers.dart';
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
import 'package:payday/features/settings/widgets/income_card.dart';
import 'package:payday/features/settings/widgets/pay_cycle_card.dart';
import 'package:payday/features/settings/widgets/payday_card.dart';
import 'package:payday/features/settings/widgets/theme_card.dart';
import 'package:payday/features/settings/widgets/currency_card.dart';

// Utils
import 'package:payday/features/settings/utils/date_picker_dialog.dart' as settings_utils;

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

  Future<void> _selectPayday() async {
    if (_formData == null) return;

    final picked = await settings_utils.DatePickerDialog.show(
      context: context,
      initialDate: _formData!.nextPayday,
    );

    if (picked != null && mounted) {
      setState(() {
        _formData = _formData!.copyWith(nextPayday: picked);
      });
    }
  }

  void _handleCurrencyChanged(String newCurrency) {
    if (_formData == null) return;
    setState(() {
      _formData = _formData!.copyWith(selectedCurrency: newCurrency);
    });
  }

  void _handlePayCycleChanged(String newCycle, DateTime adjustedDate) {
    if (_formData == null) return;

    setState(() {
      _formData = _formData!.copyWith(
        selectedPayCycle: newCycle,
        nextPayday: adjustedDate,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pay cycle changed to "$newCycle". Next payday adjusted. Tap date to change.',
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
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final isFullyAuthenticatedAsync = ref.watch(isFullyAuthenticatedProvider);
    final isFullyAuthenticated = isFullyAuthenticatedAsync.asData?.value ?? false;

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

            // Income
            const SectionTitle(
              title: 'Income',
              icon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            IncomeCard(
              incomeController: _formData!.incomeController,
              currentBalanceController: _formData!.currentBalanceController,
              selectedCurrency: _formData!.selectedCurrency,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Pay Cycle
            const SectionTitle(
              title: 'Pay Cycle',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            PayCycleCard(
              selectedPayCycle: _formData!.selectedPayCycle,
              currentNextPayday: _formData!.nextPayday,
              onPayCycleChanged: _handlePayCycleChanged,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Next Payday
            const SectionTitle(
              title: 'Next Payday',
              icon: Icons.event_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            PaydayCard(
              nextPayday: _formData!.nextPayday,
              onTap: _selectPayday,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Theme
            const SectionTitle(
              title: 'Appearance',
              icon: Icons.palette_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            const ThemeCard(),

            const SizedBox(height: AppSpacing.lg),

            // Currency
            const SectionTitle(
              title: 'Currency',
              icon: Icons.currency_exchange_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            CurrencyCard(
              selectedCurrency: _formData!.selectedCurrency,
              onCurrencyChanged: _handleCurrencyChanged,
            ),

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

