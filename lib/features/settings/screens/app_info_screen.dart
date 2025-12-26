// App Info Screen
// Contains Delete Account, Privacy Policy, Terms of Use, Contact Us, and About

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoScreen extends ConsumerStatefulWidget {
  const AppInfoScreen({super.key});

  @override
  ConsumerState<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends ConsumerState<AppInfoScreen> {
  bool _isDeleting = false;

  // --------------------------------------------------------------------------
  // ACCOUNT DELETION LOGIC
  // --------------------------------------------------------------------------

  Future<void> _showDeleteAccountDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.read(currentUserProvider).asData?.value;

    if (currentUser == null) {
      _showErrorSnackBar('You must be signed in to delete your account');
      return;
    }

    final TextEditingController confirmController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isConfirmValid = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Text(
                'Delete account?',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.darkCharcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your account and all related data will be permanently deleted. This action cannot be undone.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.mediumGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Type DELETE to confirm:',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.darkCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: confirmController,
                    onChanged: (value) {
                      setStateDialog(() {
                        isConfirmValid = value.trim().toUpperCase() == 'DELETE';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This is permanent and cannot be undone.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.mediumGray,
                      fontSize: 12,
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
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.mediumGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isConfirmValid
                      ? () {
                          Navigator.of(context).pop();
                          _handleDeleteAccount();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.error.withValues(alpha: 0.4),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
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
          const Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userSettingsRepo = ref.read(userSettingsRepositoryProvider);
      final transactionRepo = ref.read(transactionRepositoryProvider);

      await Future.wait<void>([
        userSettingsRepo.deleteAllUserData(user.uid),
        transactionRepo.deleteAllUserTransactions(user.uid),
      ]);

      await authService.deleteAccount();

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.of(context).popUntil((route) => route.isFirst);
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
        _showErrorSnackBar('An error occurred while deleting the account: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // --------------------------------------------------------------------------
  // URL LAUNCHER LOGIC
  // --------------------------------------------------------------------------

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showErrorSnackBar('Could not open link');
      }
    }
  }

  Future<void> _openContactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@codenzi.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Payday App Support',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (mounted) {
          _showErrorSnackBar('No email client found on device.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Could not open email client.');
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // UI BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    final isAuthenticated = currentUser != null;

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
          'App Info',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isDeleting
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryPink,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delete Account Section
            _buildInfoCard(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.error,
              iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
              title: 'Delete Account',
              subtitle: isAuthenticated
                  ? 'Permanently delete your account and all data'
                  : 'Sign in to delete your account',
              isDark: isDark,
              onTap: isAuthenticated ? _showDeleteAccountDialog : null,
              enabled: isAuthenticated,
            ),

            const SizedBox(height: AppSpacing.md),

            // Privacy Policy Section
            _buildInfoCard(
              icon: Icons.privacy_tip_outlined,
              iconColor: AppColors.primaryPink,
              iconBackgroundColor:
              AppColors.primaryPink.withValues(alpha: 0.1),
              title: 'Privacy Policy',
              subtitle: 'Learn how we protect your data',
              isDark: isDark,
              onTap: () =>
                  _openUrl('https://www.paydayapp.com/privacy-policy'),
            ),

            const SizedBox(height: AppSpacing.md),

            // Terms of Use Section
            _buildInfoCard(
              icon: Icons.description_outlined,
              iconColor: AppColors.secondaryBlue,
              iconBackgroundColor:
              AppColors.secondaryBlue.withValues(alpha: 0.1),
              title: 'Terms of Use',
              subtitle: 'Review our terms and conditions',
              isDark: isDark,
              onTap: () => _openUrl('https://www.paydayapp.com/terms'),
            ),

            const SizedBox(height: AppSpacing.md),

            // Contact Us Section
            _buildInfoCard(
              icon: Icons.email_outlined,
              iconColor: AppColors.success,
              iconBackgroundColor:
              AppColors.success.withValues(alpha: 0.1),
              title: 'Contact Us',
              subtitle: 'Get in touch with our support team',
              isDark: isDark,
              onTap: _openContactSupport,
            ),

            const SizedBox(height: AppSpacing.md),

            // About Section (NEW)
            _buildInfoCard(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.indigoAccent,
              iconBackgroundColor:
              Colors.indigoAccent.withValues(alpha: 0.1),
              title: 'About',
              subtitle: 'Credits, version and developer info',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutScreen()),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // App Version (Small Footer)
            Center(
              child: Text(
                'Payday v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: enabled
                              ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.darkCharcoal)
                              : AppColors.getTextSecondary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.getTextSecondary(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// ABOUT SCREEN CLASS
// --------------------------------------------------------------------------

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          'About',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // App Logo & Name Section
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/inapp.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Payday',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Version 1.0.0',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Credits Section
            _buildSectionTitle(context, 'Credits'),
            const SizedBox(height: AppSpacing.sm),

            _buildCreditItem(
              context,
              title: 'Developer',
              subtitle: 'Codenzi',
              icon: Icons.code_rounded,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Legal Section
            _buildSectionTitle(context, 'Legal'),
            const SizedBox(height: AppSpacing.sm),

            _buildCreditItem(
              context,
              title: 'Open Source Licenses',
              subtitle: 'View all licenses',
              icon: Icons.article_outlined,
              isLink: true,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Payday',
                  applicationVersion: '1.0.0',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/inapp.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Footer
            Text(
              '© 2025 Codenzi. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.getTextSecondary(context),
        ),
      ),
    );
  }

  Widget _buildCreditItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        bool isLink = false,
        VoidCallback? onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.mediumGray,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLink)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.getTextSecondary(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

