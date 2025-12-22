// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
  String get userId => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get payCycle => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get nextPayday => throw _privateConstructorUsedError;
  double get incomeAmount => throw _privateConstructorUsedError;
  double get currentBalance =>
      throw _privateConstructorUsedError; // Total Pool Balance
  String get market => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get paydayReminders =>
      throw _privateConstructorUsedError; // Bill reminder settings
  bool get billReminders => throw _privateConstructorUsedError;
  int get billReminderDaysBefore =>
      throw _privateConstructorUsedError; // Days before due date
  bool get subscriptionAlerts => throw _privateConstructorUsedError;
  bool get weeklySubscriptionSummary => throw _privateConstructorUsedError;
  bool get unusedSubscriptionAlerts => throw _privateConstructorUsedError;
  int get unusedThresholdDays =>
      throw _privateConstructorUsedError; // Days before marking as unused
  // Auto-deposit tracking for Piggy Bank system
  @TimestampDateTimeConverter()
  DateTime? get lastAutoDepositDate => throw _privateConstructorUsedError; // Tracks last automatic salary deposit to prevent duplicates
  @TimestampDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
    UserSettings value,
    $Res Function(UserSettings) then,
  ) = _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call({
    String userId,
    String currency,
    String payCycle,
    @TimestampDateTimeConverter() DateTime nextPayday,
    double incomeAmount,
    double currentBalance,
    String market,
    bool notificationsEnabled,
    bool paydayReminders,
    bool billReminders,
    int billReminderDaysBefore,
    bool subscriptionAlerts,
    bool weeklySubscriptionSummary,
    bool unusedSubscriptionAlerts,
    int unusedThresholdDays,
    @TimestampDateTimeConverter() DateTime? lastAutoDepositDate,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currency = null,
    Object? payCycle = null,
    Object? nextPayday = null,
    Object? incomeAmount = null,
    Object? currentBalance = null,
    Object? market = null,
    Object? notificationsEnabled = null,
    Object? paydayReminders = null,
    Object? billReminders = null,
    Object? billReminderDaysBefore = null,
    Object? subscriptionAlerts = null,
    Object? weeklySubscriptionSummary = null,
    Object? unusedSubscriptionAlerts = null,
    Object? unusedThresholdDays = null,
    Object? lastAutoDepositDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            payCycle: null == payCycle
                ? _value.payCycle
                : payCycle // ignore: cast_nullable_to_non_nullable
                      as String,
            nextPayday: null == nextPayday
                ? _value.nextPayday
                : nextPayday // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            incomeAmount: null == incomeAmount
                ? _value.incomeAmount
                : incomeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            market: null == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            paydayReminders: null == paydayReminders
                ? _value.paydayReminders
                : paydayReminders // ignore: cast_nullable_to_non_nullable
                      as bool,
            billReminders: null == billReminders
                ? _value.billReminders
                : billReminders // ignore: cast_nullable_to_non_nullable
                      as bool,
            billReminderDaysBefore: null == billReminderDaysBefore
                ? _value.billReminderDaysBefore
                : billReminderDaysBefore // ignore: cast_nullable_to_non_nullable
                      as int,
            subscriptionAlerts: null == subscriptionAlerts
                ? _value.subscriptionAlerts
                : subscriptionAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            weeklySubscriptionSummary: null == weeklySubscriptionSummary
                ? _value.weeklySubscriptionSummary
                : weeklySubscriptionSummary // ignore: cast_nullable_to_non_nullable
                      as bool,
            unusedSubscriptionAlerts: null == unusedSubscriptionAlerts
                ? _value.unusedSubscriptionAlerts
                : unusedSubscriptionAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            unusedThresholdDays: null == unusedThresholdDays
                ? _value.unusedThresholdDays
                : unusedThresholdDays // ignore: cast_nullable_to_non_nullable
                      as int,
            lastAutoDepositDate: freezed == lastAutoDepositDate
                ? _value.lastAutoDepositDate
                : lastAutoDepositDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
    _$UserSettingsImpl value,
    $Res Function(_$UserSettingsImpl) then,
  ) = __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String currency,
    String payCycle,
    @TimestampDateTimeConverter() DateTime nextPayday,
    double incomeAmount,
    double currentBalance,
    String market,
    bool notificationsEnabled,
    bool paydayReminders,
    bool billReminders,
    int billReminderDaysBefore,
    bool subscriptionAlerts,
    bool weeklySubscriptionSummary,
    bool unusedSubscriptionAlerts,
    int unusedThresholdDays,
    @TimestampDateTimeConverter() DateTime? lastAutoDepositDate,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
    _$UserSettingsImpl _value,
    $Res Function(_$UserSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currency = null,
    Object? payCycle = null,
    Object? nextPayday = null,
    Object? incomeAmount = null,
    Object? currentBalance = null,
    Object? market = null,
    Object? notificationsEnabled = null,
    Object? paydayReminders = null,
    Object? billReminders = null,
    Object? billReminderDaysBefore = null,
    Object? subscriptionAlerts = null,
    Object? weeklySubscriptionSummary = null,
    Object? unusedSubscriptionAlerts = null,
    Object? unusedThresholdDays = null,
    Object? lastAutoDepositDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserSettingsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        payCycle: null == payCycle
            ? _value.payCycle
            : payCycle // ignore: cast_nullable_to_non_nullable
                  as String,
        nextPayday: null == nextPayday
            ? _value.nextPayday
            : nextPayday // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        incomeAmount: null == incomeAmount
            ? _value.incomeAmount
            : incomeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        market: null == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        paydayReminders: null == paydayReminders
            ? _value.paydayReminders
            : paydayReminders // ignore: cast_nullable_to_non_nullable
                  as bool,
        billReminders: null == billReminders
            ? _value.billReminders
            : billReminders // ignore: cast_nullable_to_non_nullable
                  as bool,
        billReminderDaysBefore: null == billReminderDaysBefore
            ? _value.billReminderDaysBefore
            : billReminderDaysBefore // ignore: cast_nullable_to_non_nullable
                  as int,
        subscriptionAlerts: null == subscriptionAlerts
            ? _value.subscriptionAlerts
            : subscriptionAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        weeklySubscriptionSummary: null == weeklySubscriptionSummary
            ? _value.weeklySubscriptionSummary
            : weeklySubscriptionSummary // ignore: cast_nullable_to_non_nullable
                  as bool,
        unusedSubscriptionAlerts: null == unusedSubscriptionAlerts
            ? _value.unusedSubscriptionAlerts
            : unusedSubscriptionAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        unusedThresholdDays: null == unusedThresholdDays
            ? _value.unusedThresholdDays
            : unusedThresholdDays // ignore: cast_nullable_to_non_nullable
                  as int,
        lastAutoDepositDate: freezed == lastAutoDepositDate
            ? _value.lastAutoDepositDate
            : lastAutoDepositDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl({
    required this.userId,
    required this.currency,
    required this.payCycle,
    @TimestampDateTimeConverter() required this.nextPayday,
    required this.incomeAmount,
    this.currentBalance = 0.0,
    this.market = 'US',
    this.notificationsEnabled = true,
    this.paydayReminders = true,
    this.billReminders = true,
    this.billReminderDaysBefore = 2,
    this.subscriptionAlerts = true,
    this.weeklySubscriptionSummary = true,
    this.unusedSubscriptionAlerts = true,
    this.unusedThresholdDays = 30,
    @TimestampDateTimeConverter() this.lastAutoDepositDate,
    @TimestampDateTimeConverter() this.createdAt,
    @TimestampDateTimeConverter() this.updatedAt,
  });

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

  @override
  final String userId;
  @override
  final String currency;
  @override
  final String payCycle;
  @override
  @TimestampDateTimeConverter()
  final DateTime nextPayday;
  @override
  final double incomeAmount;
  @override
  @JsonKey()
  final double currentBalance;
  // Total Pool Balance
  @override
  @JsonKey()
  final String market;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool paydayReminders;
  // Bill reminder settings
  @override
  @JsonKey()
  final bool billReminders;
  @override
  @JsonKey()
  final int billReminderDaysBefore;
  // Days before due date
  @override
  @JsonKey()
  final bool subscriptionAlerts;
  @override
  @JsonKey()
  final bool weeklySubscriptionSummary;
  @override
  @JsonKey()
  final bool unusedSubscriptionAlerts;
  @override
  @JsonKey()
  final int unusedThresholdDays;
  // Days before marking as unused
  // Auto-deposit tracking for Piggy Bank system
  @override
  @TimestampDateTimeConverter()
  final DateTime? lastAutoDepositDate;
  // Tracks last automatic salary deposit to prevent duplicates
  @override
  @TimestampDateTimeConverter()
  final DateTime? createdAt;
  @override
  @TimestampDateTimeConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserSettings(userId: $userId, currency: $currency, payCycle: $payCycle, nextPayday: $nextPayday, incomeAmount: $incomeAmount, currentBalance: $currentBalance, market: $market, notificationsEnabled: $notificationsEnabled, paydayReminders: $paydayReminders, billReminders: $billReminders, billReminderDaysBefore: $billReminderDaysBefore, subscriptionAlerts: $subscriptionAlerts, weeklySubscriptionSummary: $weeklySubscriptionSummary, unusedSubscriptionAlerts: $unusedSubscriptionAlerts, unusedThresholdDays: $unusedThresholdDays, lastAutoDepositDate: $lastAutoDepositDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.payCycle, payCycle) ||
                other.payCycle == payCycle) &&
            (identical(other.nextPayday, nextPayday) ||
                other.nextPayday == nextPayday) &&
            (identical(other.incomeAmount, incomeAmount) ||
                other.incomeAmount == incomeAmount) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.paydayReminders, paydayReminders) ||
                other.paydayReminders == paydayReminders) &&
            (identical(other.billReminders, billReminders) ||
                other.billReminders == billReminders) &&
            (identical(other.billReminderDaysBefore, billReminderDaysBefore) ||
                other.billReminderDaysBefore == billReminderDaysBefore) &&
            (identical(other.subscriptionAlerts, subscriptionAlerts) ||
                other.subscriptionAlerts == subscriptionAlerts) &&
            (identical(
                  other.weeklySubscriptionSummary,
                  weeklySubscriptionSummary,
                ) ||
                other.weeklySubscriptionSummary == weeklySubscriptionSummary) &&
            (identical(
                  other.unusedSubscriptionAlerts,
                  unusedSubscriptionAlerts,
                ) ||
                other.unusedSubscriptionAlerts == unusedSubscriptionAlerts) &&
            (identical(other.unusedThresholdDays, unusedThresholdDays) ||
                other.unusedThresholdDays == unusedThresholdDays) &&
            (identical(other.lastAutoDepositDate, lastAutoDepositDate) ||
                other.lastAutoDepositDate == lastAutoDepositDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    currency,
    payCycle,
    nextPayday,
    incomeAmount,
    currentBalance,
    market,
    notificationsEnabled,
    paydayReminders,
    billReminders,
    billReminderDaysBefore,
    subscriptionAlerts,
    weeklySubscriptionSummary,
    unusedSubscriptionAlerts,
    unusedThresholdDays,
    lastAutoDepositDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(this);
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings({
    required final String userId,
    required final String currency,
    required final String payCycle,
    @TimestampDateTimeConverter() required final DateTime nextPayday,
    required final double incomeAmount,
    final double currentBalance,
    final String market,
    final bool notificationsEnabled,
    final bool paydayReminders,
    final bool billReminders,
    final int billReminderDaysBefore,
    final bool subscriptionAlerts,
    final bool weeklySubscriptionSummary,
    final bool unusedSubscriptionAlerts,
    final int unusedThresholdDays,
    @TimestampDateTimeConverter() final DateTime? lastAutoDepositDate,
    @TimestampDateTimeConverter() final DateTime? createdAt,
    @TimestampDateTimeConverter() final DateTime? updatedAt,
  }) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override
  String get userId;
  @override
  String get currency;
  @override
  String get payCycle;
  @override
  @TimestampDateTimeConverter()
  DateTime get nextPayday;
  @override
  double get incomeAmount;
  @override
  double get currentBalance; // Total Pool Balance
  @override
  String get market;
  @override
  bool get notificationsEnabled;
  @override
  bool get paydayReminders; // Bill reminder settings
  @override
  bool get billReminders;
  @override
  int get billReminderDaysBefore; // Days before due date
  @override
  bool get subscriptionAlerts;
  @override
  bool get weeklySubscriptionSummary;
  @override
  bool get unusedSubscriptionAlerts;
  @override
  int get unusedThresholdDays; // Days before marking as unused
  // Auto-deposit tracking for Piggy Bank system
  @override
  @TimestampDateTimeConverter()
  DateTime? get lastAutoDepositDate; // Tracks last automatic salary deposit to prevent duplicates
  @override
  @TimestampDateTimeConverter()
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  DateTime? get updatedAt;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
