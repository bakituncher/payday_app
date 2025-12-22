/// User settings model with bill reminders support
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:payday/core/models/converters/timestamp_converter.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    required String currency,
    required String payCycle,
    @TimestampDateTimeConverter() required DateTime nextPayday,
    required double incomeAmount,
    @Default(0.0) double currentBalance, // Total Pool Balance
    @Default('US') String market,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool paydayReminders,
    // Bill reminder settings
    @Default(true) bool billReminders,
    @Default(2) int billReminderDaysBefore, // Days before due date
    @Default(true) bool subscriptionAlerts,
    @Default(true) bool weeklySubscriptionSummary,
    @Default(true) bool unusedSubscriptionAlerts,
    @Default(30) int unusedThresholdDays, // Days before marking as unused
    // Auto-deposit tracking for Piggy Bank system
    @TimestampDateTimeConverter() DateTime? lastAutoDepositDate, // Tracks last automatic salary deposit to prevent duplicates
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
