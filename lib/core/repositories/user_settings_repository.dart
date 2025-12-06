/// Repository interface for user settings operations
import 'package:payday_flutter/core/models/user_settings.dart';

abstract class UserSettingsRepository {
  /// Get user settings
  Future<UserSettings?> getUserSettings(String userId);

  /// Save user settings
  Future<void> saveUserSettings(UserSettings settings);

  /// Update next payday
  Future<void> updateNextPayday(String userId, DateTime nextPayday);

  /// Update income amount
  Future<void> updateIncomeAmount(String userId, double amount);

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();
}

