/// Authentication Controller
/// Manages authentication operations for settings screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/data_migration_service.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/home/providers/period_balance_providers.dart';

class AuthController {
  final WidgetRef ref;
  final BuildContext context;

  AuthController(this.ref, this.context);

  /// Handle Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final authService = ref.read(authServiceProvider);
      final wasAnonymous = authService.isAnonymous;
      final sourceUserId = ref.read(currentUserIdProvider);

      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        if (wasAnonymous && !userCredential.user!.isAnonymous) {
          await _migrateData(userCredential.user!.uid, sourceUserId);
        }

        _invalidateProviders();
        await _reloadSettings();

        return userCredential.user?.displayName ?? userCredential.user?.email;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Handle Apple Sign In
  Future<String?> signInWithApple() async {
    try {
      final authService = ref.read(authServiceProvider);
      final wasAnonymous = authService.isAnonymous;
      final sourceUserId = ref.read(currentUserIdProvider);

      final userCredential = await authService.signInWithApple();

      if (userCredential != null) {
        if (wasAnonymous && !userCredential.user!.isAnonymous) {
          await _migrateData(userCredential.user!.uid, sourceUserId);
        }

        _invalidateProviders();
        await _reloadSettings();

        return userCredential.user?.displayName ?? userCredential.user?.email ?? 'Apple User';
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Handle Sign Out
  Future<void> signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      _invalidateProviders();
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUserId = ref.read(currentUserIdProvider);

      // Delete user data
      final settingsRepo = ref.read(userSettingsRepositoryProvider);
      final transactionRepo = ref.read(transactionRepositoryProvider);

      await Future.wait([
        settingsRepo.deleteAllUserData(currentUserId),
        transactionRepo.deleteAllUserTransactions(currentUserId),
      ]);

      // Delete auth account
      await authService.deleteAccount();

      _invalidateProviders();
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      rethrow;
    }
  }

  /// Migrate data from anonymous to authenticated user
  Future<void> _migrateData(String targetUserId, String sourceUserId) async {
    try {
      final migrationService = ref.read(dataMigrationServiceProvider);
      await migrationService.migrateLocalToFirebase(targetUserId, sourceUserId);

      ref.invalidate(userSettingsRepositoryProvider);
      ref.invalidate(transactionRepositoryProvider);
    } catch (e) {
      debugPrint('❌ Migration error: $e');
      rethrow;
    }
  }

  /// Invalidate all providers after auth changes
  void _invalidateProviders() {
    ref.invalidate(userSettingsProvider);
    ref.invalidate(currentCycleTransactionsProvider);
    ref.invalidate(totalExpensesProvider);
    ref.invalidate(dailyAllowableSpendProvider);
    ref.invalidate(budgetHealthProvider);
    ref.invalidate(currentMonthlySummaryProvider);
    ref.invalidate(selectedPayPeriodProvider);
    ref.invalidate(selectedPeriodBalanceProvider);
  }

  /// Reload settings after auth changes
  Future<void> _reloadSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await ref.read(userSettingsProvider.future);
    } catch (e) {
      debugPrint('❌ Settings reload error: $e');
    }
  }
}

