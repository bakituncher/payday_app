// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BudgetGoal _$BudgetGoalFromJson(Map<String, dynamic> json) {
  return _BudgetGoal.fromJson(json);
}

/// @nodoc
mixin _$BudgetGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get categoryEmoji => throw _privateConstructorUsedError;
  double get limitAmount => throw _privateConstructorUsedError;
  double get spentAmount => throw _privateConstructorUsedError;
  BudgetPeriod get period => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get notifyOnWarning => throw _privateConstructorUsedError;
  int get warningThreshold => throw _privateConstructorUsedError; // Percentage
  @TimestampDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BudgetGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetGoalCopyWith<BudgetGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetGoalCopyWith<$Res> {
  factory $BudgetGoalCopyWith(
    BudgetGoal value,
    $Res Function(BudgetGoal) then,
  ) = _$BudgetGoalCopyWithImpl<$Res, BudgetGoal>;
  @useResult
  $Res call({
    String id,
    String userId,
    String categoryId,
    String categoryName,
    String categoryEmoji,
    double limitAmount,
    double spentAmount,
    BudgetPeriod period,
    bool isActive,
    bool notifyOnWarning,
    int warningThreshold,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class _$BudgetGoalCopyWithImpl<$Res, $Val extends BudgetGoal>
    implements $BudgetGoalCopyWith<$Res> {
  _$BudgetGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryEmoji = null,
    Object? limitAmount = null,
    Object? spentAmount = null,
    Object? period = null,
    Object? isActive = null,
    Object? notifyOnWarning = null,
    Object? warningThreshold = null,
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
            limitAmount: null == limitAmount
                ? _value.limitAmount
                : limitAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            spentAmount: null == spentAmount
                ? _value.spentAmount
                : spentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as BudgetPeriod,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnWarning: null == notifyOnWarning
                ? _value.notifyOnWarning
                : notifyOnWarning // ignore: cast_nullable_to_non_nullable
                      as bool,
            warningThreshold: null == warningThreshold
                ? _value.warningThreshold
                : warningThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$BudgetGoalImplCopyWith<$Res>
    implements $BudgetGoalCopyWith<$Res> {
  factory _$$BudgetGoalImplCopyWith(
    _$BudgetGoalImpl value,
    $Res Function(_$BudgetGoalImpl) then,
  ) = __$$BudgetGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String categoryId,
    String categoryName,
    String categoryEmoji,
    double limitAmount,
    double spentAmount,
    BudgetPeriod period,
    bool isActive,
    bool notifyOnWarning,
    int warningThreshold,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class __$$BudgetGoalImplCopyWithImpl<$Res>
    extends _$BudgetGoalCopyWithImpl<$Res, _$BudgetGoalImpl>
    implements _$$BudgetGoalImplCopyWith<$Res> {
  __$$BudgetGoalImplCopyWithImpl(
    _$BudgetGoalImpl _value,
    $Res Function(_$BudgetGoalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryEmoji = null,
    Object? limitAmount = null,
    Object? spentAmount = null,
    Object? period = null,
    Object? isActive = null,
    Object? notifyOnWarning = null,
    Object? warningThreshold = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BudgetGoalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        limitAmount: null == limitAmount
            ? _value.limitAmount
            : limitAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        spentAmount: null == spentAmount
            ? _value.spentAmount
            : spentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as BudgetPeriod,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnWarning: null == notifyOnWarning
            ? _value.notifyOnWarning
            : notifyOnWarning // ignore: cast_nullable_to_non_nullable
                  as bool,
        warningThreshold: null == warningThreshold
            ? _value.warningThreshold
            : warningThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$BudgetGoalImpl extends _BudgetGoal {
  const _$BudgetGoalImpl({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
    required this.limitAmount,
    required this.spentAmount,
    required this.period,
    this.isActive = true,
    this.notifyOnWarning = true,
    this.warningThreshold = 80,
    @TimestampDateTimeConverter() this.createdAt,
    @TimestampDateTimeConverter() this.updatedAt,
  }) : super._();

  factory _$BudgetGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final String categoryEmoji;
  @override
  final double limitAmount;
  @override
  final double spentAmount;
  @override
  final BudgetPeriod period;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool notifyOnWarning;
  @override
  @JsonKey()
  final int warningThreshold;
  // Percentage
  @override
  @TimestampDateTimeConverter()
  final DateTime? createdAt;
  @override
  @TimestampDateTimeConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BudgetGoal(id: $id, userId: $userId, categoryId: $categoryId, categoryName: $categoryName, categoryEmoji: $categoryEmoji, limitAmount: $limitAmount, spentAmount: $spentAmount, period: $period, isActive: $isActive, notifyOnWarning: $notifyOnWarning, warningThreshold: $warningThreshold, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryEmoji, categoryEmoji) ||
                other.categoryEmoji == categoryEmoji) &&
            (identical(other.limitAmount, limitAmount) ||
                other.limitAmount == limitAmount) &&
            (identical(other.spentAmount, spentAmount) ||
                other.spentAmount == spentAmount) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notifyOnWarning, notifyOnWarning) ||
                other.notifyOnWarning == notifyOnWarning) &&
            (identical(other.warningThreshold, warningThreshold) ||
                other.warningThreshold == warningThreshold) &&
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
    categoryId,
    categoryName,
    categoryEmoji,
    limitAmount,
    spentAmount,
    period,
    isActive,
    notifyOnWarning,
    warningThreshold,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetGoalImplCopyWith<_$BudgetGoalImpl> get copyWith =>
      __$$BudgetGoalImplCopyWithImpl<_$BudgetGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetGoalImplToJson(this);
  }
}

abstract class _BudgetGoal extends BudgetGoal {
  const factory _BudgetGoal({
    required final String id,
    required final String userId,
    required final String categoryId,
    required final String categoryName,
    required final String categoryEmoji,
    required final double limitAmount,
    required final double spentAmount,
    required final BudgetPeriod period,
    final bool isActive,
    final bool notifyOnWarning,
    final int warningThreshold,
    @TimestampDateTimeConverter() final DateTime? createdAt,
    @TimestampDateTimeConverter() final DateTime? updatedAt,
  }) = _$BudgetGoalImpl;
  const _BudgetGoal._() : super._();

  factory _BudgetGoal.fromJson(Map<String, dynamic> json) =
      _$BudgetGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  String get categoryEmoji;
  @override
  double get limitAmount;
  @override
  double get spentAmount;
  @override
  BudgetPeriod get period;
  @override
  bool get isActive;
  @override
  bool get notifyOnWarning;
  @override
  int get warningThreshold; // Percentage
  @override
  @TimestampDateTimeConverter()
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  DateTime? get updatedAt;

  /// Create a copy of BudgetGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetGoalImplCopyWith<_$BudgetGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
