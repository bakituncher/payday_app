/// Repository interface for user settings operations
import 'package:payday/core/models/user_settings.dart';

abstract class UserSettingsRepository {
  /// Get user settings
  Future<UserSettings?> getUserSettings(String userId);

  /// Save user settings
  Future<void> saveUserSettings(UserSettings settings);

  /// Atomically increment balance by delta. Returns true if handled atomically.
  Future<bool> incrementBalance(String userId, double delta) async {
    // Default implementation falls back to read-modify-write in callers
    return false;
  }

  /// Update next payday
  Future<void> updateNextPayday(String userId, DateTime nextPayday);

  /// Update income amount
  Future<void> updateIncomeAmount(String userId, double amount);

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Delete all user data
  Future<void> deleteAllUserData(String userId);
}
