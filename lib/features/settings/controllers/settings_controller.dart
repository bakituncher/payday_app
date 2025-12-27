/// Settings Controller
/// Manages business logic for settings screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/auth_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/home/providers/period_balance_providers.dart';
import 'package:payday/features/settings/models/settings_form_data.dart';
import 'package:payday/core/services/date_cycle_service.dart';

class SettingsController {
  final WidgetRef ref;
  final BuildContext context;

  SettingsController(this.ref, this.context);

  /// Load current settings from repository
  Future<SettingsFormData?> loadSettings() async {
    try {
      final settings = await ref.read(userSettingsProvider.future);
      if (settings != null) {
        final incomeController = TextEditingController(
          text: settings.incomeAmount.toStringAsFixed(2),
        );
        final balanceController = TextEditingController(
          text: settings.currentBalance.toStringAsFixed(2),
        );

        return SettingsFormData(
          incomeController: incomeController,
          currentBalanceController: balanceController,
          selectedCurrency: settings.currency,
          selectedPayCycle: settings.payCycle,
          nextPayday: settings.nextPayday,
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      return null;
    }
  }

  /// Save settings to repository
  Future<bool> saveSettings(SettingsFormData formData) async {
    try {
      final income = double.tryParse(formData.incomeController.text) ?? 0.0;
      final currentBalance = double.tryParse(formData.currentBalanceController.text) ?? 0.0;

      if (income <= 0) {
        throw Exception('Income must be greater than zero');
      }

      final settingsRepo = ref.read(userSettingsRepositoryProvider);
      final currentUserId = ref.read(currentUserIdProvider);
      final currentSettings = await ref.read(userSettingsProvider.future);

      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          currency: formData.selectedCurrency,
          payCycle: formData.selectedPayCycle,
          nextPayday: formData.nextPayday,
          incomeAmount: income,
          currentBalance: currentBalance,
          updatedAt: DateTime.now(),
        );

        await settingsRepo.saveUserSettings(updatedSettings);
      }

      // Invalidate all dependent providers
      _invalidateProviders();

      return true;
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
      rethrow;
    }
  }

  /// Tüm finansal profili tek seferde günceller.
  ///
  /// Contract:
  /// - income: seçili pay cycle başına gelir (UI metniyle uyumlu)
  /// - payCycle: 'Weekly', 'Bi-Weekly', 'Semi-Monthly', 'Monthly'
  /// - nextPayday: bir sonraki maaş günü (DateCycleService kuralları UI'da da kullanılabilir)
  /// - currency: 'USD', 'EUR', 'TRY', ...
  Future<bool> updateFinancialProfile({
    required double income,
    required String payCycle,
    required DateTime nextPayday,
    required String currency,
    double? currentBalance,
  }) async {
    try {
      if (income <= 0) {
        throw Exception('Income must be greater than zero');
      }

      final settingsRepo = ref.read(userSettingsRepositoryProvider);
      final currentSettings = await ref.read(userSettingsProvider.future);

      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          incomeAmount: income,
          payCycle: payCycle,
          nextPayday: nextPayday,
          currency: currency,
          currentBalance: currentBalance ?? currentSettings.currentBalance,
          updatedAt: DateTime.now(),
        );

        await settingsRepo.saveUserSettings(updatedSettings);
        _invalidateProviders();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error updating financial profile: $e');
      rethrow;
    }
  }

  /// Invalidate all dependent providers after settings change
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

  /// Check if Apple Sign In is available
  Future<bool> checkAppleSignInAvailability() async {
    final authService = ref.read(authServiceProvider);
    return await authService.isAppleSignInAvailable();
  }
}
