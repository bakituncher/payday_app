/// Auto Deposit Service
/// Handles automatic salary deposits on payday using the Piggy Bank / Pool system.
/// This service ensures income is properly recorded as a transaction when payday arrives.
library;

import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';
import 'package:payday/core/services/transaction_manager_service.dart';
import 'package:payday/core/services/date_cycle_service.dart';
import 'package:uuid/uuid.dart';

/// Result of auto deposit processing
class AutoDepositResult {
  final bool success;
  final bool depositMade;
  final double? depositAmount;
  final String? message;

  AutoDepositResult({
    required this.success,
    this.depositMade = false,
    this.depositAmount,
    this.message,
  });
}

/// AutoDepositService - Manages automatic salary deposits
///
/// Core Logic:
/// - Checks if payday has arrived (today or passed since last login)
/// - If payday occurred and no deposit was made yet, creates an Income transaction
/// - Updates lastAutoDepositDate to prevent duplicate deposits
/// - Advances nextPayday to the next cycle
class AutoDepositService {
  final UserSettingsRepository _settingsRepo;
  final TransactionManagerService _transactionManager;
  final Uuid _uuid = const Uuid();

  AutoDepositService({
    required UserSettingsRepository settingsRepo,
    required TransactionManagerService transactionManager,
  })  : _settingsRepo = settingsRepo,
        _transactionManager = transactionManager;

  /// Process automatic payday deposit
  ///
  /// Returns [AutoDepositResult] with details about the operation.
  ///
  /// Logic:
  /// 1. Get current user settings
  /// 2. Check if payday has arrived (effectivePayday <= today)
  /// 3. Check if deposit was already made (lastAutoDepositDate >= effectivePayday)
  /// 4. If deposit needed: create income transaction, update balance, advance nextPayday
  Future<AutoDepositResult> processPaydayDeposit(String userId) async {
    print('💰 AutoDepositService: Checking payday deposit for user $userId');

    try {
      final settings = await _settingsRepo.getUserSettings(userId);

      if (settings == null) {
        print('💰 AutoDepositService: No settings found for user');
        return AutoDepositResult(
          success: false,
          message: 'User settings not found',
        );
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Normalize stored nextPayday and apply weekend adjustment
      DateTime effectivePayday = DateTime(
        settings.nextPayday.year,
        settings.nextPayday.month,
        settings.nextPayday.day,
      );

      // Weekend adjustment: Move to Friday if falls on weekend
      if (effectivePayday.weekday == DateTime.saturday) {
        effectivePayday = effectivePayday.subtract(const Duration(days: 1));
      } else if (effectivePayday.weekday == DateTime.sunday) {
        effectivePayday = effectivePayday.subtract(const Duration(days: 2));
      }

      // Check if payday is due (today or in the past)
      final isPaydayDue = !effectivePayday.isAfter(today);

      if (!isPaydayDue) {
        print('💰 AutoDepositService: Payday not due yet. Next payday: $effectivePayday');
        return AutoDepositResult(
          success: true,
          depositMade: false,
          message: 'Payday not due yet',
        );
      }

      // Check if deposit was already made for this pay period
      final lastDeposit = settings.lastAutoDepositDate;
      if (lastDeposit != null) {
        final normalizedLastDeposit = DateTime(
          lastDeposit.year,
          lastDeposit.month,
          lastDeposit.day,
        );

        // If last deposit was on or after the effective payday, skip
        if (!normalizedLastDeposit.isBefore(effectivePayday)) {
          print('💰 AutoDepositService: Deposit already made for this period (last: $normalizedLastDeposit)');
          return AutoDepositResult(
            success: true,
            depositMade: false,
            message: 'Deposit already processed for this pay period',
          );
        }
      }

      print('💰 AutoDepositService: Processing payday deposit of ${settings.incomeAmount}');

      // Create the salary deposit transaction
      final depositTransaction = Transaction(
        id: _uuid.v4(),
        userId: userId,
        amount: settings.incomeAmount,
        categoryId: 'income_salary',
        categoryName: 'Payday Deposit',
        categoryEmoji: '💵',
        date: effectivePayday, // Use the actual payday date
        note: 'Automatic salary deposit',
        isExpense: false, // This is INCOME, not expense
      );

      // Process the transaction (adds to history AND updates balance)
      await _transactionManager.processTransaction(
        userId: userId,
        transaction: depositTransaction,
      );

      print('💰 AutoDepositService: Deposit transaction created successfully');

      // Calculate next payday
      final nextPayday = DateCycleService.calculateNextPayday(
        effectivePayday.add(const Duration(days: 1)), // Start from day after current payday
        settings.payCycle,
      );

      // Update settings with new nextPayday and lastAutoDepositDate
      // Note: Balance was already updated by TransactionManagerService
      final freshSettings = await _settingsRepo.getUserSettings(userId);
      final updatedSettings = (freshSettings ?? settings).copyWith(
        nextPayday: nextPayday,
        lastAutoDepositDate: today, // Mark deposit as done today
        updatedAt: DateTime.now(),
      );

      await _settingsRepo.saveUserSettings(updatedSettings);

      print('💰 AutoDepositService: Settings updated - Next payday: $nextPayday');
      print('✅ AutoDepositService: Payday deposit completed successfully');

      return AutoDepositResult(
        success: true,
        depositMade: true,
        depositAmount: settings.incomeAmount,
        message: 'Payday deposit of ${settings.incomeAmount} processed',
      );
    } catch (e) {
      print('❌ AutoDepositService: Error processing payday deposit: $e');
      return AutoDepositResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Check if payday deposit is pending (for UI indicators)
  Future<bool> isPaydayDepositPending(String userId) async {
    final settings = await _settingsRepo.getUserSettings(userId);
    if (settings == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime effectivePayday = DateTime(
      settings.nextPayday.year,
      settings.nextPayday.month,
      settings.nextPayday.day,
    );

    if (effectivePayday.weekday == DateTime.saturday) {
      effectivePayday = effectivePayday.subtract(const Duration(days: 1));
    } else if (effectivePayday.weekday == DateTime.sunday) {
      effectivePayday = effectivePayday.subtract(const Duration(days: 2));
    }

    final isPaydayDue = !effectivePayday.isAfter(today);
    if (!isPaydayDue) return false;

    final lastDeposit = settings.lastAutoDepositDate;
    if (lastDeposit == null) return true;

    final normalizedLastDeposit = DateTime(
      lastDeposit.year,
      lastDeposit.month,
      lastDeposit.day,
    );

    return normalizedLastDeposit.isBefore(effectivePayday);
  }
}

