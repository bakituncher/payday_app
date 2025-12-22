// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get categoryEmoji => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  bool get isExpense =>
      throw _privateConstructorUsedError; // Recurring payment fields
  bool get isRecurring => throw _privateConstructorUsedError;
  TransactionFrequency? get frequency => throw _privateConstructorUsedError;
  String? get subscriptionId =>
      throw _privateConstructorUsedError; // Link to subscription if applicable
  @TimestampDateTimeConverter()
  DateTime? get nextRecurrenceDate => throw _privateConstructorUsedError; // Savings goal link
  String? get relatedGoalId =>
      throw _privateConstructorUsedError; // Link to savings goal if this is a savings transaction
  @TimestampDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    String id,
    String userId,
    double amount,
    String categoryId,
    String categoryName,
    String categoryEmoji,
    @TimestampDateTimeConverter() DateTime date,
    String note,
    bool isExpense,
    bool isRecurring,
    TransactionFrequency? frequency,
    String? subscriptionId,
    @TimestampDateTimeConverter() DateTime? nextRecurrenceDate,
    String? relatedGoalId,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryEmoji = null,
    Object? date = null,
    Object? note = null,
    Object? isExpense = null,
    Object? isRecurring = null,
    Object? frequency = freezed,
    Object? subscriptionId = freezed,
    Object? nextRecurrenceDate = freezed,
    Object? relatedGoalId = freezed,
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
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryEmoji: null == categoryEmoji
                ? _value.categoryEmoji
                : categoryEmoji // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            isExpense: null == isExpense
                ? _value.isExpense
                : isExpense // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            frequency: freezed == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as TransactionFrequency?,
            subscriptionId: freezed == subscriptionId
                ? _value.subscriptionId
                : subscriptionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextRecurrenceDate: freezed == nextRecurrenceDate
                ? _value.nextRecurrenceDate
                : nextRecurrenceDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            relatedGoalId: freezed == relatedGoalId
                ? _value.relatedGoalId
                : relatedGoalId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    double amount,
    String categoryId,
    String categoryName,
    String categoryEmoji,
    @TimestampDateTimeConverter() DateTime date,
    String note,
    bool isExpense,
    bool isRecurring,
    TransactionFrequency? frequency,
    String? subscriptionId,
    @TimestampDateTimeConverter() DateTime? nextRecurrenceDate,
    String? relatedGoalId,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryEmoji = null,
    Object? date = null,
    Object? note = null,
    Object? isExpense = null,
    Object? isRecurring = null,
    Object? frequency = freezed,
    Object? subscriptionId = freezed,
    Object? nextRecurrenceDate = freezed,
    Object? relatedGoalId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$TransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryEmoji: null == categoryEmoji
            ? _value.categoryEmoji
            : categoryEmoji // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        isExpense: null == isExpense
            ? _value.isExpense
            : isExpense // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        frequency: freezed == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as TransactionFrequency?,
        subscriptionId: freezed == subscriptionId
            ? _value.subscriptionId
            : subscriptionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextRecurrenceDate: freezed == nextRecurrenceDate
            ? _value.nextRecurrenceDate
            : nextRecurrenceDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        relatedGoalId: freezed == relatedGoalId
            ? _value.relatedGoalId
            : relatedGoalId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$TransactionImpl extends _Transaction {
  const _$TransactionImpl({
    required this.id,
    required this.userId,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
    @TimestampDateTimeConverter() required this.date,
    this.note = '',
    this.isExpense = true,
    this.isRecurring = false,
    this.frequency,
    this.subscriptionId,
    @TimestampDateTimeConverter() this.nextRecurrenceDate,
    this.relatedGoalId,
    @TimestampDateTimeConverter() this.createdAt,
    @TimestampDateTimeConverter() this.updatedAt,
  }) : super._();

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double amount;
  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final String categoryEmoji;
  @override
  @TimestampDateTimeConverter()
  final DateTime date;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final bool isExpense;
  // Recurring payment fields
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final TransactionFrequency? frequency;
  @override
  final String? subscriptionId;
  // Link to subscription if applicable
  @override
  @TimestampDateTimeConverter()
  final DateTime? nextRecurrenceDate;
  // Savings goal link
  @override
  final String? relatedGoalId;
  // Link to savings goal if this is a savings transaction
  @override
  @TimestampDateTimeConverter()
  final DateTime? createdAt;
  @override
  @TimestampDateTimeConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, amount: $amount, categoryId: $categoryId, categoryName: $categoryName, categoryEmoji: $categoryEmoji, date: $date, note: $note, isExpense: $isExpense, isRecurring: $isRecurring, frequency: $frequency, subscriptionId: $subscriptionId, nextRecurrenceDate: $nextRecurrenceDate, relatedGoalId: $relatedGoalId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryEmoji, categoryEmoji) ||
                other.categoryEmoji == categoryEmoji) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isExpense, isExpense) ||
                other.isExpense == isExpense) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.nextRecurrenceDate, nextRecurrenceDate) ||
                other.nextRecurrenceDate == nextRecurrenceDate) &&
            (identical(other.relatedGoalId, relatedGoalId) ||
                other.relatedGoalId == relatedGoalId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    amount,
    categoryId,
    categoryName,
    categoryEmoji,
    date,
    note,
    isExpense,
    isRecurring,
    frequency,
    subscriptionId,
    nextRecurrenceDate,
    relatedGoalId,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction extends Transaction {
  const factory _Transaction({
    required final String id,
    required final String userId,
    required final double amount,
    required final String categoryId,
    required final String categoryName,
    required final String categoryEmoji,
    @TimestampDateTimeConverter() required final DateTime date,
    final String note,
    final bool isExpense,
    final bool isRecurring,
    final TransactionFrequency? frequency,
    final String? subscriptionId,
    @TimestampDateTimeConverter() final DateTime? nextRecurrenceDate,
    final String? relatedGoalId,
    @TimestampDateTimeConverter() final DateTime? createdAt,
    @TimestampDateTimeConverter() final DateTime? updatedAt,
  }) = _$TransactionImpl;
  const _Transaction._() : super._();

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get amount;
  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  String get categoryEmoji;
  @override
  @TimestampDateTimeConverter()
  DateTime get date;
  @override
  String get note;
  @override
  bool get isExpense; // Recurring payment fields
  @override
  bool get isRecurring;
  @override
  TransactionFrequency? get frequency;
  @override
  String? get subscriptionId; // Link to subscription if applicable
  @override
  @TimestampDateTimeConverter()
  DateTime? get nextRecurrenceDate; // Savings goal link
  @override
  String? get relatedGoalId; // Link to savings goal if this is a savings transaction
  @override
  @TimestampDateTimeConverter()
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  DateTime? get updatedAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
