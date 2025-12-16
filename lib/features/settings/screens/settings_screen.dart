/// Settings Screen
/// Allows users to update their financial settings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _incomeController = TextEditingController();
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
        _selectedCurrency = settings.currency;
        _selectedPayCycle = settings.payCycle;
        _nextPayday = settings.nextPayday;
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _selectPayday() async {
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && mounted) {
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
      final userCredential = await authService.signInWithApple();

      if (userCredential != null && mounted) {
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
          updatedAt: DateTime.now(),
        );

        await repository.saveUserSettings(updatedSettings);

        // Refresh all related providers
        ref.invalidate(userSettingsProvider);
        ref.invalidate(currentCycleTransactionsProvider);
        ref.invalidate(totalExpensesProvider);
        ref.invalidate(dailyAllowableSpendProvider);
        ref.invalidate(budgetHealthProvider);
        ref.invalidate(currentMonthlySummaryProvider);

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
    final isSignedIn = currentUser != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.darkCharcoal,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle(theme, 'Account', Icons.person_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildAccountCard(theme, isSignedIn, currentUser),

            const SizedBox(height: AppSpacing.lg),

            // Income Section
            _buildSectionTitle(theme, 'Income', Icons.attach_money_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildIncomeCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Pay Cycle Section
            _buildSectionTitle(theme, 'Pay Cycle', Icons.calendar_today_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildPayCycleCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Next Payday Section
            _buildSectionTitle(theme, 'Next Payday', Icons.event_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildPaydayCard(theme),

            const SizedBox(height: AppSpacing.lg),

            // Currency Section
            _buildSectionTitle(theme, 'Currency', Icons.currency_exchange_rounded),
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
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryPink),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(ThemeData theme, bool isSignedIn, dynamic currentUser) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSignedIn) ...[
            // User Info
            Row(
              children: [
                // User Avatar
                Container(
                  width: 56,
                  height: 56,
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
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
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
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            // Sign Out Button
            PaydayButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              isLoading: _isSigningIn,
              width: double.infinity,
              onPressed: _handleSignOut,
              style: PaydayButtonStyle.outlined,
            ),
          ] else ...[
            // Sign In Options
            Text(
              'Sign in to sync your data across devices',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Google Sign In Button
            _buildGoogleSignInButton(),

            const SizedBox(height: AppSpacing.sm),

            // Apple Sign In Button (if available)
            if (_isAppleSignInAvailable)
              _buildAppleSignInButton(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
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
                  // Google Logo
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
                  // Apple Logo
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

  Widget _buildIncomeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Income',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
            decoration: InputDecoration(
              prefixText: AppConstants.currencySymbols[_selectedCurrency] ?? '\$',
              prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPink,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildPayCycleCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often do you get paid?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.payCycleOptions.map((cycle) {
              final isSelected = _selectedPayCycle == cycle;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedPayCycle = cycle;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.pinkGradient : null,
                    color: isSelected ? null : AppColors.subtleGray,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryPink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    cycle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : AppColors.darkCharcoal,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final daysUntil = _nextPayday.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: _selectPayday,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primaryPink,
                size: 28,
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
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysUntil > 0
                        ? '$daysUntil days away'
                        : daysUntil == 0
                            ? 'Today! 🎉'
                            : 'Date has passed - tap to update',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: daysUntil < 0 ? AppColors.error : AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your currency',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.currencies.map((currency) {
              final isSelected = _selectedCurrency == currency['code'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedCurrency = currency['code'] as String;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.pinkGradient : null,
                    color: isSelected ? null : AppColors.subtleGray,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryPink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency['symbol'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.white : AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currency['code'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : AppColors.darkCharcoal,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

