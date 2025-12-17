/// Local implementation of UserSettingsRepository using SharedPreferences
/// This replaces MockUserSettingsRepository with cleaner implementation
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserSettingsRepository implements UserSettingsRepository {
  // Cache for settings
  UserSettings? _cachedSettings;
  bool _initialized = false;

  Future<void> _loadFromPrefs() async {
    if (_initialized && _cachedSettings != null) return;

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user_currency')) {
      _cachedSettings = UserSettings(
        userId: prefs.getString('user_id') ?? 'local_user',
        currency: prefs.getString('user_currency') ?? 'USD',
        payCycle: prefs.getString('user_pay_cycle') ?? 'Monthly',
        nextPayday: DateTime.tryParse(prefs.getString('next_payday') ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        incomeAmount: prefs.getDouble('income_amount') ?? 0.0,
        market: prefs.getString('user_market') ?? 'US',
        notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
        paydayReminders: prefs.getBool('payday_reminders') ?? true,
        billReminders: prefs.getBool('bill_reminders') ?? true,
        billReminderDaysBefore: prefs.getInt('bill_reminder_days') ?? 2,
        subscriptionAlerts: prefs.getBool('subscription_alerts') ?? true,
        weeklySubscriptionSummary: prefs.getBool('weekly_subscription_summary') ?? true,
        unusedSubscriptionAlerts: prefs.getBool('unused_subscription_alerts') ?? true,
        unusedThresholdDays: prefs.getInt('unused_threshold_days') ?? 30,
        createdAt: DateTime.tryParse(prefs.getString('settings_created_at') ?? ''),
        updatedAt: DateTime.now(),
      );
    }
    _initialized = true;
  }

  @override
  Future<UserSettings?> getUserSettings(String userId) async {
    await _loadFromPrefs();
    return _cachedSettings;
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    _cachedSettings = settings;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', settings.userId);
    await prefs.setString('user_currency', settings.currency);
    await prefs.setString('user_pay_cycle', settings.payCycle);
    await prefs.setString('next_payday', settings.nextPayday.toIso8601String());
    await prefs.setDouble('income_amount', settings.incomeAmount);
    await prefs.setString('user_market', settings.market);
    await prefs.setBool('notifications_enabled', settings.notificationsEnabled);
    await prefs.setBool('payday_reminders', settings.paydayReminders);
    await prefs.setBool('bill_reminders', settings.billReminders);
    await prefs.setInt('bill_reminder_days', settings.billReminderDaysBefore);
    await prefs.setBool('subscription_alerts', settings.subscriptionAlerts);
    await prefs.setBool('weekly_subscription_summary', settings.weeklySubscriptionSummary);
    await prefs.setBool('unused_subscription_alerts', settings.unusedSubscriptionAlerts);
    await prefs.setInt('unused_threshold_days', settings.unusedThresholdDays);
    await prefs.setString('settings_created_at',
        (settings.createdAt ?? DateTime.now()).toIso8601String());
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  Future<void> updateNextPayday(String userId, DateTime nextPayday) async {
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
    return prefs.getBool('onboarding_completed') ??
           prefs.containsKey('user_currency');
  }

  /// Clear cache to force reload from storage
  void clearCache() {
    _cachedSettings = null;
    _initialized = false;
  }
}

