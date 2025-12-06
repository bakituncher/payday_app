/// User settings model
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    required String currency,
    required String payCycle,
    required DateTime nextPayday,
    required double incomeAmount,
    @Default('US') String market,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool paydayReminders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

