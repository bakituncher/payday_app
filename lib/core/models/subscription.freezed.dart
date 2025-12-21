// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  RecurrenceFrequency get frequency => throw _privateConstructorUsedError;
  SubscriptionCategory get category => throw _privateConstructorUsedError;
  DateTime get nextBillingDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  bool get reminderEnabled => throw _privateConstructorUsedError;
  int get reminderDaysBefore => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime? get trialEndsAt => throw _privateConstructorUsedError;
  DateTime? get pausedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    double amount,
    String currency,
    RecurrenceFrequency frequency,
    SubscriptionCategory category,
    DateTime nextBillingDate,
    String description,
    String logoUrl,
    String emoji,
    SubscriptionStatus status,
    bool reminderEnabled,
    int reminderDaysBefore,
    DateTime? startDate,
    DateTime? cancelledAt,
    DateTime? trialEndsAt,
    DateTime? pausedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? amount = null,
    Object? currency = null,
    Object? frequency = null,
    Object? category = null,
    Object? nextBillingDate = null,
    Object? description = null,
    Object? logoUrl = null,
    Object? emoji = null,
    Object? status = null,
    Object? reminderEnabled = null,
    Object? reminderDaysBefore = null,
    Object? startDate = freezed,
    Object? cancelledAt = freezed,
    Object? trialEndsAt = freezed,
    Object? pausedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as RecurrenceFrequency,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as SubscriptionCategory,
            nextBillingDate: null == nextBillingDate
                ? _value.nextBillingDate
                : nextBillingDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUrl: null == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            reminderEnabled: null == reminderEnabled
                ? _value.reminderEnabled
                : reminderEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderDaysBefore: null == reminderDaysBefore
                ? _value.reminderDaysBefore
                : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            trialEndsAt: freezed == trialEndsAt
                ? _value.trialEndsAt
                : trialEndsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            pausedAt: freezed == pausedAt
                ? _value.pausedAt
                : pausedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    double amount,
    String currency,
    RecurrenceFrequency frequency,
    SubscriptionCategory category,
    DateTime nextBillingDate,
    String description,
    String logoUrl,
    String emoji,
    SubscriptionStatus status,
    bool reminderEnabled,
    int reminderDaysBefore,
    DateTime? startDate,
    DateTime? cancelledAt,
    DateTime? trialEndsAt,
    DateTime? pausedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? amount = null,
    Object? currency = null,
    Object? frequency = null,
    Object? category = null,
    Object? nextBillingDate = null,
    Object? description = null,
    Object? logoUrl = null,
    Object? emoji = null,
    Object? status = null,
    Object? reminderEnabled = null,
    Object? reminderDaysBefore = null,
    Object? startDate = freezed,
    Object? cancelledAt = freezed,
    Object? trialEndsAt = freezed,
    Object? pausedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as RecurrenceFrequency,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as SubscriptionCategory,
        nextBillingDate: null == nextBillingDate
            ? _value.nextBillingDate
            : nextBillingDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        logoUrl: null == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        reminderEnabled: null == reminderEnabled
            ? _value.reminderEnabled
            : reminderEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderDaysBefore: null == reminderDaysBefore
            ? _value.reminderDaysBefore
            : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        trialEndsAt: freezed == trialEndsAt
            ? _value.trialEndsAt
            : trialEndsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        pausedAt: freezed == pausedAt
            ? _value.pausedAt
            : pausedAt // ignore: cast_nullable_to_non_nullable
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
class _$SubscriptionImpl extends _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.category,
    required this.nextBillingDate,
    this.description = '',
    this.logoUrl = '',
    this.emoji = '💳',
    this.status = SubscriptionStatus.active,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 2,
    this.startDate,
    this.cancelledAt,
    this.trialEndsAt,
    this.pausedAt,
    this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final RecurrenceFrequency frequency;
  @override
  final SubscriptionCategory category;
  @override
  final DateTime nextBillingDate;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String logoUrl;
  @override
  @JsonKey()
  final String emoji;
  @override
  @JsonKey()
  final SubscriptionStatus status;
  @override
  @JsonKey()
  final bool reminderEnabled;
  @override
  @JsonKey()
  final int reminderDaysBefore;
  @override
  final DateTime? startDate;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime? trialEndsAt;
  @override
  final DateTime? pausedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Subscription(id: $id, userId: $userId, name: $name, amount: $amount, currency: $currency, frequency: $frequency, category: $category, nextBillingDate: $nextBillingDate, description: $description, logoUrl: $logoUrl, emoji: $emoji, status: $status, reminderEnabled: $reminderEnabled, reminderDaysBefore: $reminderDaysBefore, startDate: $startDate, cancelledAt: $cancelledAt, trialEndsAt: $trialEndsAt, pausedAt: $pausedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.nextBillingDate, nextBillingDate) ||
                other.nextBillingDate == nextBillingDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reminderEnabled, reminderEnabled) ||
                other.reminderEnabled == reminderEnabled) &&
            (identical(other.reminderDaysBefore, reminderDaysBefore) ||
                other.reminderDaysBefore == reminderDaysBefore) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.trialEndsAt, trialEndsAt) ||
                other.trialEndsAt == trialEndsAt) &&
            (identical(other.pausedAt, pausedAt) ||
                other.pausedAt == pausedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    name,
    amount,
    currency,
    frequency,
    category,
    nextBillingDate,
    description,
    logoUrl,
    emoji,
    status,
    reminderEnabled,
    reminderDaysBefore,
    startDate,
    cancelledAt,
    trialEndsAt,
    pausedAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription extends Subscription {
  const factory _Subscription({
    required final String id,
    required final String userId,
    required final String name,
    required final double amount,
    required final String currency,
    required final RecurrenceFrequency frequency,
    required final SubscriptionCategory category,
    required final DateTime nextBillingDate,
    final String description,
    final String logoUrl,
    final String emoji,
    final SubscriptionStatus status,
    final bool reminderEnabled,
    final int reminderDaysBefore,
    final DateTime? startDate,
    final DateTime? cancelledAt,
    final DateTime? trialEndsAt,
    final DateTime? pausedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$SubscriptionImpl;
  const _Subscription._() : super._();

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  double get amount;
  @override
  String get currency;
  @override
  RecurrenceFrequency get frequency;
  @override
  SubscriptionCategory get category;
  @override
  DateTime get nextBillingDate;
  @override
  String get description;
  @override
  String get logoUrl;
  @override
  String get emoji;
  @override
  SubscriptionStatus get status;
  @override
  bool get reminderEnabled;
  @override
  int get reminderDaysBefore;
  @override
  DateTime? get startDate;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime? get trialEndsAt;
  @override
  DateTime? get pausedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
