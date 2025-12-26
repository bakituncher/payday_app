/// Data Conflict Service
/// Manages data conflicts when signing in with existing accounts
import 'package:flutter/material.dart';
import 'package:payday/core/repositories/local/local_user_settings_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_user_settings_repository.dart';
import 'package:payday/core/repositories/local/local_transaction_repository.dart';
import 'package:payday/core/repositories/firebase/firebase_transaction_repository.dart';

class DataConflictService {
  final LocalUserSettingsRepository _localSettingsRepo = LocalUserSettingsRepository();
  final FirebaseUserSettingsRepository _firebaseSettingsRepo = FirebaseUserSettingsRepository();
  final LocalTransactionRepository _localTxRepo = LocalTransactionRepository();
  final FirebaseTransactionRepository _firebaseTxRepo = FirebaseTransactionRepository();

  /// Check if local device has meaningful data
  Future<bool> hasLocalData(String localUserId) async {
    try {
      final settings = await _localSettingsRepo.getUserSettings(localUserId);
      final transactions = await _localTxRepo.getTransactions(localUserId);

      // Consider data meaningful if:
      // 1. Has completed onboarding
      // 2. Has transactions OR has modified balance
      final hasOnboarding = await _localSettingsRepo.hasCompletedOnboarding();
      final hasTransactions = transactions.isNotEmpty;
      final hasModifiedBalance = settings != null && settings.currentBalance != 0;

      debugPrint('📱 Local Data Check: Onboarding=$hasOnboarding, Transactions=${transactions.length}, Balance=${settings?.currentBalance}');

      return hasOnboarding && (hasTransactions || hasModifiedBalance);
    } catch (e) {
      debugPrint('❌ Error checking local data: $e');
      return false;
    }
  }

  /// Check if remote account has meaningful data
  Future<bool> hasRemoteData(String remoteUserId) async {
    try {
      final settings = await _firebaseSettingsRepo.getUserSettings(remoteUserId);
      final transactions = await _firebaseTxRepo.getTransactions(remoteUserId);

      // Consider data meaningful if settings exist with meaningful values
      final hasSettings = settings != null;
      final hasTransactions = transactions.isNotEmpty;
      final hasModifiedBalance = settings != null && settings.currentBalance != 0;

      debugPrint('☁️ Remote Data Check: Settings=$hasSettings, Transactions=${transactions.length}, Balance=${settings?.currentBalance}');

      return hasSettings && (hasTransactions || hasModifiedBalance);
    } catch (e) {
      debugPrint('❌ Error checking remote data: $e');
      return false;
    }
  }

  /// Check if there's a data conflict
  Future<DataConflictResult> checkForConflict({
    required String localUserId,
    required String remoteUserId,
  }) async {
    final hasLocal = await hasLocalData(localUserId);
    final hasRemote = await hasRemoteData(remoteUserId);

    debugPrint('🔍 Conflict Check: Local=$hasLocal, Remote=$hasRemote');

    return DataConflictResult(
      hasLocalData: hasLocal,
      hasRemoteData: hasRemote,
      hasConflict: hasLocal && hasRemote,
    );
  }

  /// Delete local data (when user chooses to keep remote)
  Future<void> deleteLocalData(String localUserId) async {
    try {
      debugPrint('🗑️ Deleting local data for user: $localUserId');

      await Future.wait([
        _localSettingsRepo.deleteAllUserData(localUserId),
        _localTxRepo.deleteAllUserTransactions(localUserId),
      ]);

      debugPrint('✅ Local data deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting local data: $e');
      rethrow;
    }
  }

  /// Delete remote data (when user chooses to keep local)
  Future<void> deleteRemoteData(String remoteUserId) async {
    try {
      debugPrint('🗑️ Deleting remote data for user: $remoteUserId');

      await Future.wait([
        _firebaseSettingsRepo.deleteAllUserData(remoteUserId),
        _firebaseTxRepo.deleteAllUserTransactions(remoteUserId),
      ]);

      debugPrint('✅ Remote data deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting remote data: $e');
      rethrow;
    }
  }
}

class DataConflictResult {
  final bool hasLocalData;
  final bool hasRemoteData;
  final bool hasConflict;

  DataConflictResult({
    required this.hasLocalData,
    required this.hasRemoteData,
    required this.hasConflict,
  });

  @override
  String toString() {
    return 'DataConflictResult(local: $hasLocalData, remote: $hasRemoteData, conflict: $hasConflict)';
  }
}

