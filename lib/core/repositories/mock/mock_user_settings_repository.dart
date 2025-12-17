/// Mock implementation of UserSettingsRepository for UI testing
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserSettingsRepository implements UserSettingsRepository {
  // In-memory storage for mock data
  UserSettings? _cachedSettings;
  bool _initialized = false;

  Future<void> _loadFromPrefs() async {
    if (_initialized && _cachedSettings != null) return;

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user_currency')) {
      _cachedSettings = UserSettings(
        userId: prefs.getString('user_id') ?? 'mock_user',
        currency: prefs.getString('user_currency') ?? 'USD',
        payCycle: prefs.getString('user_pay_cycle') ?? 'Monthly',
        nextPayday: DateTime.tryParse(prefs.getString('next_payday') ?? '') ?? DateTime.now().add(const Duration(days: 30)),
        incomeAmount: prefs.getDouble('income_amount') ?? 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    _initialized = true;
  }

  @override
  Future<UserSettings?> getUserSettings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    await _loadFromPrefs();
    return _cachedSettings;
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedSettings = settings;

    // Also save to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', settings.userId);
    await prefs.setString('user_currency', settings.currency);
    await prefs.setString('user_pay_cycle', settings.payCycle);
    await prefs.setString('next_payday', settings.nextPayday.toIso8601String());
    await prefs.setDouble('income_amount', settings.incomeAmount);
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  Future<void> updateNextPayday(String userId, DateTime nextPayday) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _loadFromPrefs();
    if (_cachedSettings != null) {
      _cachedSettings = _cachedSettings!.copyWith(
        nextPayday: nextPayday,
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('next_payday', nextPayday.toIso8601String());
    }
  }

  @override
  Future<void> updateIncomeAmount(String userId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _loadFromPrefs();
    if (_cachedSettings != null) {
      _cachedSettings = _cachedSettings!.copyWith(
        incomeAmount: amount,
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('income_amount', amount);
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? prefs.containsKey('user_currency');
  }

  @override
  Future<void> deleteAllUserData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final prefs = await SharedPreferences.getInstance();

    // Clear all user-related keys
    await prefs.remove('user_id');
    await prefs.remove('user_currency');
    await prefs.remove('user_pay_cycle');
    await prefs.remove('next_payday');
    await prefs.remove('income_amount');
    await prefs.remove('onboarding_completed');

    // Clear cache
    _cachedSettings = null;
    _initialized = false;
  }
}

