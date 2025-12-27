/// Authentication Controller
/// Manages authentication operations for settings screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/services/data_migration_service.dart';
import 'package:payday/core/services/data_conflict_service.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/home/providers/period_balance_providers.dart';
import 'package:payday/features/auth/widgets/data_conflict_dialog.dart';

class AuthController {
  final WidgetRef ref;
  final BuildContext context;
  final DataConflictService _conflictService = DataConflictService();

  AuthController(this.ref, this.context);

  /// Handle Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final authService = ref.read(authServiceProvider);
      final wasGuest = await authService.isGuestMode;
      final sourceUserId = ref.read(currentUserIdProvider);

      // First, perform the sign-in to get the target user
      final userCredential = await authService.signInWithGoogle();

      if (userCredential == null) return null;

      final targetUserId = userCredential.user!.uid;

      // ✅ Critical Fix: Only check conflict if user ID changed AND was guest
      if (wasGuest && sourceUserId != targetUserId) {
        final conflictResult = await _conflictService.checkForConflict(
          localUserId: sourceUserId,
          remoteUserId: targetUserId,
        );

        debugPrint('📊 Conflict Result: $conflictResult');

        if (conflictResult.hasConflict) {
          // Show conflict resolution dialog (no cancel option - user already signed in)
          final choice = await _showDataConflictDialog(
            hasLocalData: conflictResult.hasLocalData,
            hasRemoteData: conflictResult.hasRemoteData,
          );


          if (choice == DataConflictChoice.keepLocal) {
            // Delete remote data and migrate local to cloud
            await _conflictService.deleteRemoteData(targetUserId);
            await _migrateData(targetUserId, sourceUserId);
          } else if (choice == DataConflictChoice.keepRemote) {
            // Delete local data and keep remote
            await _conflictService.deleteLocalData(sourceUserId);
          }
        } else if (conflictResult.hasLocalData) {
          // Only local data exists - migrate it
          await _migrateData(targetUserId, sourceUserId);
        }
        // If only remote data exists or no data anywhere, do nothing
      }

      _invalidateProviders();
      await _reloadSettings();

      return userCredential.user?.displayName ?? userCredential.user?.email;
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Handle Apple Sign In
  Future<String?> signInWithApple() async {
    try {
      final authService = ref.read(authServiceProvider);
      final wasGuest = await authService.isGuestMode;
      final sourceUserId = ref.read(currentUserIdProvider);

      // First, perform the sign-in to get the target user
      final userCredential = await authService.signInWithApple();

      if (userCredential == null) return null;

      final targetUserId = userCredential.user!.uid;

      // ✅ Critical Fix: Only check conflict if user ID changed AND was guest
      if (wasGuest && sourceUserId != targetUserId) {
        final conflictResult = await _conflictService.checkForConflict(
          localUserId: sourceUserId,
          remoteUserId: targetUserId,
        );

        debugPrint('📊 Conflict Result: $conflictResult');

        if (conflictResult.hasConflict) {
          // Show conflict resolution dialog (no cancel option - user already signed in)
          final choice = await _showDataConflictDialog(
            hasLocalData: conflictResult.hasLocalData,
            hasRemoteData: conflictResult.hasRemoteData,
          );


          if (choice == DataConflictChoice.keepLocal) {
            // Delete remote data and migrate local to cloud
            await _conflictService.deleteRemoteData(targetUserId);
            await _migrateData(targetUserId, sourceUserId);
          } else if (choice == DataConflictChoice.keepRemote) {
            // Delete local data and keep remote
            await _conflictService.deleteLocalData(sourceUserId);
          }
        } else if (conflictResult.hasLocalData) {
          // Only local data exists - migrate it
          await _migrateData(targetUserId, sourceUserId);
        }
        // If only remote data exists or no data anywhere, do nothing
      }

      _invalidateProviders();
      await _reloadSettings();

      return userCredential.user?.displayName ?? userCredential.user?.email ?? 'Apple User';
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

      // Navigate to login after sign out
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
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

      // Navigate to login after account deletion
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      rethrow;
    }
  }

  /// Show data conflict dialog and return user choice
  Future<DataConflictChoice> _showDataConflictDialog({
    required bool hasLocalData,
    required bool hasRemoteData,
  }) async {
    DataConflictChoice? choice;

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // ✅ User must make a choice
      builder: (BuildContext dialogContext) {
        return DataConflictDialog(
          hasLocalData: hasLocalData,
          hasRemoteData: hasRemoteData,
          onChoiceMade: (selectedChoice) {
            choice = selectedChoice;
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );

    // Should never be null since dialog is not dismissible
    return choice ?? DataConflictChoice.keepLocal;
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
    // ✅ Critical Fix: Refresh user auth state first
    ref.invalidate(currentUserProvider);
    ref.invalidate(isFullyAuthenticatedProvider);
    ref.invalidate(currentUserIdProvider);

    // Invalidate data providers
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

