// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BillReminder _$BillReminderFromJson(Map<String, dynamic> json) {
  return _BillReminder.fromJson(json);
}

/// @nodoc
mixin _$BillReminder {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get subscriptionId => throw _privateConstructorUsedError;
  String get subscriptionName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  DateTime get reminderDate => throw _privateConstructorUsedError;
  ReminderStatus get status => throw _privateConstructorUsedError;
  ReminderPriority get priority => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get dismissedAt => throw _privateConstructorUsedError;
  DateTime? get snoozeUntil => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BillReminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BillReminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillReminderCopyWith<BillReminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillReminderCopyWith<$Res> {
  factory $BillReminderCopyWith(
    BillReminder value,
    $Res Function(BillReminder) then,
  ) = _$BillReminderCopyWithImpl<$Res, BillReminder>;
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String subscriptionName,
    double amount,
    String currency,
    DateTime dueDate,
    DateTime reminderDate,
    ReminderStatus status,
    ReminderPriority priority,
    String note,
    String emoji,
    DateTime? sentAt,
    DateTime? dismissedAt,
    DateTime? snoozeUntil,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$BillReminderCopyWithImpl<$Res, $Val extends BillReminder>
    implements $BillReminderCopyWith<$Res> {
  _$BillReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillReminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? subscriptionName = null,
    Object? amount = null,
    Object? currency = null,
    Object? dueDate = null,
    Object? reminderDate = null,
    Object? status = null,
    Object? priority = null,
    Object? note = null,
    Object? emoji = null,
    Object? sentAt = freezed,
    Object? dismissedAt = freezed,
    Object? snoozeUntil = freezed,
    Object? createdAt = freezed,
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
            subscriptionId: null == subscriptionId
                ? _value.subscriptionId
                : subscriptionId // ignore: cast_nullable_to_non_nullable
                      as String,
            subscriptionName: null == subscriptionName
                ? _value.subscriptionName
                : subscriptionName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reminderDate: null == reminderDate
                ? _value.reminderDate
                : reminderDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReminderStatus,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ReminderPriority,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dismissedAt: freezed == dismissedAt
                ? _value.dismissedAt
                : dismissedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            snoozeUntil: freezed == snoozeUntil
                ? _value.snoozeUntil
                : snoozeUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BillReminderImplCopyWith<$Res>
    implements $BillReminderCopyWith<$Res> {
  factory _$$BillReminderImplCopyWith(
    _$BillReminderImpl value,
    $Res Function(_$BillReminderImpl) then,
  ) = __$$BillReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String subscriptionName,
    double amount,
    String currency,
    DateTime dueDate,
    DateTime reminderDate,
    ReminderStatus status,
    ReminderPriority priority,
    String note,
    String emoji,
    DateTime? sentAt,
    DateTime? dismissedAt,
    DateTime? snoozeUntil,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$BillReminderImplCopyWithImpl<$Res>
    extends _$BillReminderCopyWithImpl<$Res, _$BillReminderImpl>
    implements _$$BillReminderImplCopyWith<$Res> {
  __$$BillReminderImplCopyWithImpl(
    _$BillReminderImpl _value,
    $Res Function(_$BillReminderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillReminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? subscriptionName = null,
    Object? amount = null,
    Object? currency = null,
    Object? dueDate = null,
    Object? reminderDate = null,
    Object? status = null,
    Object? priority = null,
    Object? note = null,
    Object? emoji = null,
    Object? sentAt = freezed,
    Object? dismissedAt = freezed,
    Object? snoozeUntil = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$BillReminderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionId: null == subscriptionId
            ? _value.subscriptionId
            : subscriptionId // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionName: null == subscriptionName
            ? _value.subscriptionName
            : subscriptionName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reminderDate: null == reminderDate
            ? _value.reminderDate
            : reminderDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReminderStatus,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ReminderPriority,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dismissedAt: freezed == dismissedAt
            ? _value.dismissedAt
            : dismissedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        snoozeUntil: freezed == snoozeUntil
            ? _value.snoozeUntil
            : snoozeUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BillReminderImpl extends _BillReminder {
  const _$BillReminderImpl({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.amount,
    this.currency = 'USD',
    required this.dueDate,
    required this.reminderDate,
    this.status = ReminderStatus.pending,
    this.priority = ReminderPriority.medium,
    this.note = '',
    this.emoji = '💳',
    this.sentAt,
    this.dismissedAt,
    this.snoozeUntil,
    this.createdAt,
  }) : super._();

  factory _$BillReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillReminderImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String subscriptionId;
  @override
  final String subscriptionName;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  final DateTime dueDate;
  @override
  final DateTime reminderDate;
  @override
  @JsonKey()
  final ReminderStatus status;
  @override
  @JsonKey()
  final ReminderPriority priority;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final String emoji;
  @override
  final DateTime? sentAt;
  @override
  final DateTime? dismissedAt;
  @override
  final DateTime? snoozeUntil;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'BillReminder(id: $id, userId: $userId, subscriptionId: $subscriptionId, subscriptionName: $subscriptionName, amount: $amount, currency: $currency, dueDate: $dueDate, reminderDate: $reminderDate, status: $status, priority: $priority, note: $note, emoji: $emoji, sentAt: $sentAt, dismissedAt: $dismissedAt, snoozeUntil: $snoozeUntil, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.subscriptionName, subscriptionName) ||
                other.subscriptionName == subscriptionName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.reminderDate, reminderDate) ||
                other.reminderDate == reminderDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.dismissedAt, dismissedAt) ||
                other.dismissedAt == dismissedAt) &&
            (identical(other.snoozeUntil, snoozeUntil) ||
                other.snoozeUntil == snoozeUntil) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    subscriptionId,
    subscriptionName,
    amount,
    currency,
    dueDate,
    reminderDate,
    status,
    priority,
    note,
    emoji,
    sentAt,
    dismissedAt,
    snoozeUntil,
    createdAt,
  );

  /// Create a copy of BillReminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillReminderImplCopyWith<_$BillReminderImpl> get copyWith =>
      __$$BillReminderImplCopyWithImpl<_$BillReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillReminderImplToJson(this);
  }
}

abstract class _BillReminder extends BillReminder {
  const factory _BillReminder({
    required final String id,
    required final String userId,
    required final String subscriptionId,
    required final String subscriptionName,
    required final double amount,
    final String currency,
    required final DateTime dueDate,
    required final DateTime reminderDate,
    final ReminderStatus status,
    final ReminderPriority priority,
    final String note,
    final String emoji,
    final DateTime? sentAt,
    final DateTime? dismissedAt,
    final DateTime? snoozeUntil,
    final DateTime? createdAt,
  }) = _$BillReminderImpl;
  const _BillReminder._() : super._();

  factory _BillReminder.fromJson(Map<String, dynamic> json) =
      _$BillReminderImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get subscriptionId;
  @override
  String get subscriptionName;
  @override
  double get amount;
  @override
  String get currency;
  @override
  DateTime get dueDate;
  @override
  DateTime get reminderDate;
  @override
  ReminderStatus get status;
  @override
  ReminderPriority get priority;
  @override
  String get note;
  @override
  String get emoji;
  @override
  DateTime? get sentAt;
  @override
  DateTime? get dismissedAt;
  @override
  DateTime? get snoozeUntil;
  @override
  DateTime? get createdAt;

  /// Create a copy of BillReminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillReminderImplCopyWith<_$BillReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
