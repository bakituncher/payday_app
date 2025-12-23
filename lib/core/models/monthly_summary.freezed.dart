// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) {
  return _MonthlySummary.fromJson(json);
}

/// @nodoc
mixin _$MonthlySummary {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  double get totalIncome => throw _privateConstructorUsedError;
  double get totalExpenses => throw _privateConstructorUsedError;
  double get totalSubscriptions => throw _privateConstructorUsedError;
  double get leftoverAmount => throw _privateConstructorUsedError;
  FinancialHealth get healthStatus => throw _privateConstructorUsedError;
  SpendingTrend get trend => throw _privateConstructorUsedError;
  Map<String, double> get expensesByCategory =>
      throw _privateConstructorUsedError;
  List<SpendingInsight> get insights => throw _privateConstructorUsedError;
  List<LeftoverSuggestion> get leftoverSuggestions =>
      throw _privateConstructorUsedError;
  double get savingsGoalProgress => throw _privateConstructorUsedError;
  double get emergencyFundProgress => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime? get finalizedAt => throw _privateConstructorUsedError;

  /// Serializes this MonthlySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlySummaryCopyWith<MonthlySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlySummaryCopyWith<$Res> {
  factory $MonthlySummaryCopyWith(
    MonthlySummary value,
    $Res Function(MonthlySummary) then,
  ) = _$MonthlySummaryCopyWithImpl<$Res, MonthlySummary>;
  @useResult
  $Res call({
    String id,
    String userId,
    int year,
    int month,
    double totalIncome,
    double totalExpenses,
    double totalSubscriptions,
    double leftoverAmount,
    FinancialHealth healthStatus,
    SpendingTrend trend,
    Map<String, double> expensesByCategory,
    List<SpendingInsight> insights,
    List<LeftoverSuggestion> leftoverSuggestions,
    double savingsGoalProgress,
    double emergencyFundProgress,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? finalizedAt,
  });
}

/// @nodoc
class _$MonthlySummaryCopyWithImpl<$Res, $Val extends MonthlySummary>
    implements $MonthlySummaryCopyWith<$Res> {
  _$MonthlySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? year = null,
    Object? month = null,
    Object? totalIncome = null,
    Object? totalExpenses = null,
    Object? totalSubscriptions = null,
    Object? leftoverAmount = null,
    Object? healthStatus = null,
    Object? trend = null,
    Object? expensesByCategory = null,
    Object? insights = null,
    Object? leftoverSuggestions = null,
    Object? savingsGoalProgress = null,
    Object? emergencyFundProgress = null,
    Object? createdAt = freezed,
    Object? finalizedAt = freezed,
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
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as int,
            totalIncome: null == totalIncome
                ? _value.totalIncome
                : totalIncome // ignore: cast_nullable_to_non_nullable
                      as double,
            totalExpenses: null == totalExpenses
                ? _value.totalExpenses
                : totalExpenses // ignore: cast_nullable_to_non_nullable
                      as double,
            totalSubscriptions: null == totalSubscriptions
                ? _value.totalSubscriptions
                : totalSubscriptions // ignore: cast_nullable_to_non_nullable
                      as double,
            leftoverAmount: null == leftoverAmount
                ? _value.leftoverAmount
                : leftoverAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            healthStatus: null == healthStatus
                ? _value.healthStatus
                : healthStatus // ignore: cast_nullable_to_non_nullable
                      as FinancialHealth,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as SpendingTrend,
            expensesByCategory: null == expensesByCategory
                ? _value.expensesByCategory
                : expensesByCategory // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            insights: null == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as List<SpendingInsight>,
            leftoverSuggestions: null == leftoverSuggestions
                ? _value.leftoverSuggestions
                : leftoverSuggestions // ignore: cast_nullable_to_non_nullable
                      as List<LeftoverSuggestion>,
            savingsGoalProgress: null == savingsGoalProgress
                ? _value.savingsGoalProgress
                : savingsGoalProgress // ignore: cast_nullable_to_non_nullable
                      as double,
            emergencyFundProgress: null == emergencyFundProgress
                ? _value.emergencyFundProgress
                : emergencyFundProgress // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            finalizedAt: freezed == finalizedAt
                ? _value.finalizedAt
                : finalizedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlySummaryImplCopyWith<$Res>
    implements $MonthlySummaryCopyWith<$Res> {
  factory _$$MonthlySummaryImplCopyWith(
    _$MonthlySummaryImpl value,
    $Res Function(_$MonthlySummaryImpl) then,
  ) = __$$MonthlySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    int year,
    int month,
    double totalIncome,
    double totalExpenses,
    double totalSubscriptions,
    double leftoverAmount,
    FinancialHealth healthStatus,
    SpendingTrend trend,
    Map<String, double> expensesByCategory,
    List<SpendingInsight> insights,
    List<LeftoverSuggestion> leftoverSuggestions,
    double savingsGoalProgress,
    double emergencyFundProgress,
    @TimestampDateTimeConverter() DateTime? createdAt,
    @TimestampDateTimeConverter() DateTime? finalizedAt,
  });
}

/// @nodoc
class __$$MonthlySummaryImplCopyWithImpl<$Res>
    extends _$MonthlySummaryCopyWithImpl<$Res, _$MonthlySummaryImpl>
    implements _$$MonthlySummaryImplCopyWith<$Res> {
  __$$MonthlySummaryImplCopyWithImpl(
    _$MonthlySummaryImpl _value,
    $Res Function(_$MonthlySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? year = null,
    Object? month = null,
    Object? totalIncome = null,
    Object? totalExpenses = null,
    Object? totalSubscriptions = null,
    Object? leftoverAmount = null,
    Object? healthStatus = null,
    Object? trend = null,
    Object? expensesByCategory = null,
    Object? insights = null,
    Object? leftoverSuggestions = null,
    Object? savingsGoalProgress = null,
    Object? emergencyFundProgress = null,
    Object? createdAt = freezed,
    Object? finalizedAt = freezed,
  }) {
    return _then(
      _$MonthlySummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as int,
        totalIncome: null == totalIncome
            ? _value.totalIncome
            : totalIncome // ignore: cast_nullable_to_non_nullable
                  as double,
        totalExpenses: null == totalExpenses
            ? _value.totalExpenses
            : totalExpenses // ignore: cast_nullable_to_non_nullable
                  as double,
        totalSubscriptions: null == totalSubscriptions
            ? _value.totalSubscriptions
            : totalSubscriptions // ignore: cast_nullable_to_non_nullable
                  as double,
        leftoverAmount: null == leftoverAmount
            ? _value.leftoverAmount
            : leftoverAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        healthStatus: null == healthStatus
            ? _value.healthStatus
            : healthStatus // ignore: cast_nullable_to_non_nullable
                  as FinancialHealth,
        trend: null == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as SpendingTrend,
        expensesByCategory: null == expensesByCategory
            ? _value._expensesByCategory
            : expensesByCategory // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        insights: null == insights
            ? _value._insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as List<SpendingInsight>,
        leftoverSuggestions: null == leftoverSuggestions
            ? _value._leftoverSuggestions
            : leftoverSuggestions // ignore: cast_nullable_to_non_nullable
                  as List<LeftoverSuggestion>,
        savingsGoalProgress: null == savingsGoalProgress
            ? _value.savingsGoalProgress
            : savingsGoalProgress // ignore: cast_nullable_to_non_nullable
                  as double,
        emergencyFundProgress: null == emergencyFundProgress
            ? _value.emergencyFundProgress
            : emergencyFundProgress // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        finalizedAt: freezed == finalizedAt
            ? _value.finalizedAt
            : finalizedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlySummaryImpl extends _MonthlySummary {
  const _$MonthlySummaryImpl({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSubscriptions,
    required this.leftoverAmount,
    required this.healthStatus,
    required this.trend,
    final Map<String, double> expensesByCategory = const {},
    final List<SpendingInsight> insights = const [],
    final List<LeftoverSuggestion> leftoverSuggestions = const [],
    this.savingsGoalProgress = 0,
    this.emergencyFundProgress = 0,
    @TimestampDateTimeConverter() this.createdAt,
    @TimestampDateTimeConverter() this.finalizedAt,
  }) : _expensesByCategory = expensesByCategory,
       _insights = insights,
       _leftoverSuggestions = leftoverSuggestions,
       super._();

  factory _$MonthlySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlySummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final int year;
  @override
  final int month;
  @override
  final double totalIncome;
  @override
  final double totalExpenses;
  @override
  final double totalSubscriptions;
  @override
  final double leftoverAmount;
  @override
  final FinancialHealth healthStatus;
  @override
  final SpendingTrend trend;
  final Map<String, double> _expensesByCategory;
  @override
  @JsonKey()
  Map<String, double> get expensesByCategory {
    if (_expensesByCategory is EqualUnmodifiableMapView)
      return _expensesByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_expensesByCategory);
  }

  final List<SpendingInsight> _insights;
  @override
  @JsonKey()
  List<SpendingInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  final List<LeftoverSuggestion> _leftoverSuggestions;
  @override
  @JsonKey()
  List<LeftoverSuggestion> get leftoverSuggestions {
    if (_leftoverSuggestions is EqualUnmodifiableListView)
      return _leftoverSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_leftoverSuggestions);
  }

  @override
  @JsonKey()
  final double savingsGoalProgress;
  @override
  @JsonKey()
  final double emergencyFundProgress;
  @override
  @TimestampDateTimeConverter()
  final DateTime? createdAt;
  @override
  @TimestampDateTimeConverter()
  final DateTime? finalizedAt;

  @override
  String toString() {
    return 'MonthlySummary(id: $id, userId: $userId, year: $year, month: $month, totalIncome: $totalIncome, totalExpenses: $totalExpenses, totalSubscriptions: $totalSubscriptions, leftoverAmount: $leftoverAmount, healthStatus: $healthStatus, trend: $trend, expensesByCategory: $expensesByCategory, insights: $insights, leftoverSuggestions: $leftoverSuggestions, savingsGoalProgress: $savingsGoalProgress, emergencyFundProgress: $emergencyFundProgress, createdAt: $createdAt, finalizedAt: $finalizedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlySummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpenses, totalExpenses) ||
                other.totalExpenses == totalExpenses) &&
            (identical(other.totalSubscriptions, totalSubscriptions) ||
                other.totalSubscriptions == totalSubscriptions) &&
            (identical(other.leftoverAmount, leftoverAmount) ||
                other.leftoverAmount == leftoverAmount) &&
            (identical(other.healthStatus, healthStatus) ||
                other.healthStatus == healthStatus) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            const DeepCollectionEquality().equals(
              other._expensesByCategory,
              _expensesByCategory,
            ) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            const DeepCollectionEquality().equals(
              other._leftoverSuggestions,
              _leftoverSuggestions,
            ) &&
            (identical(other.savingsGoalProgress, savingsGoalProgress) ||
                other.savingsGoalProgress == savingsGoalProgress) &&
            (identical(other.emergencyFundProgress, emergencyFundProgress) ||
                other.emergencyFundProgress == emergencyFundProgress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.finalizedAt, finalizedAt) ||
                other.finalizedAt == finalizedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    year,
    month,
    totalIncome,
    totalExpenses,
    totalSubscriptions,
    leftoverAmount,
    healthStatus,
    trend,
    const DeepCollectionEquality().hash(_expensesByCategory),
    const DeepCollectionEquality().hash(_insights),
    const DeepCollectionEquality().hash(_leftoverSuggestions),
    savingsGoalProgress,
    emergencyFundProgress,
    createdAt,
    finalizedAt,
  );

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      __$$MonthlySummaryImplCopyWithImpl<_$MonthlySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlySummaryImplToJson(this);
  }
}

abstract class _MonthlySummary extends MonthlySummary {
  const factory _MonthlySummary({
    required final String id,
    required final String userId,
    required final int year,
    required final int month,
    required final double totalIncome,
    required final double totalExpenses,
    required final double totalSubscriptions,
    required final double leftoverAmount,
    required final FinancialHealth healthStatus,
    required final SpendingTrend trend,
    final Map<String, double> expensesByCategory,
    final List<SpendingInsight> insights,
    final List<LeftoverSuggestion> leftoverSuggestions,
    final double savingsGoalProgress,
    final double emergencyFundProgress,
    @TimestampDateTimeConverter() final DateTime? createdAt,
    @TimestampDateTimeConverter() final DateTime? finalizedAt,
  }) = _$MonthlySummaryImpl;
  const _MonthlySummary._() : super._();

  factory _MonthlySummary.fromJson(Map<String, dynamic> json) =
      _$MonthlySummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get year;
  @override
  int get month;
  @override
  double get totalIncome;
  @override
  double get totalExpenses;
  @override
  double get totalSubscriptions;
  @override
  double get leftoverAmount;
  @override
  FinancialHealth get healthStatus;
  @override
  SpendingTrend get trend;
  @override
  Map<String, double> get expensesByCategory;
  @override
  List<SpendingInsight> get insights;
  @override
  List<LeftoverSuggestion> get leftoverSuggestions;
  @override
  double get savingsGoalProgress;
  @override
  double get emergencyFundProgress;
  @override
  @TimestampDateTimeConverter()
  DateTime? get createdAt;
  @override
  @TimestampDateTimeConverter()
  DateTime? get finalizedAt;

  /// Create a copy of MonthlySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpendingInsight _$SpendingInsightFromJson(Map<String, dynamic> json) {
  return _SpendingInsight.fromJson(json);
}

/// @nodoc
mixin _$SpendingInsight {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  InsightType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get actionText => throw _privateConstructorUsedError;

  /// Serializes this SpendingInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpendingInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpendingInsightCopyWith<SpendingInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingInsightCopyWith<$Res> {
  factory $SpendingInsightCopyWith(
    SpendingInsight value,
    $Res Function(SpendingInsight) then,
  ) = _$SpendingInsightCopyWithImpl<$Res, SpendingInsight>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String emoji,
    InsightType type,
    double amount,
    String category,
    String actionText,
  });
}

/// @nodoc
class _$SpendingInsightCopyWithImpl<$Res, $Val extends SpendingInsight>
    implements $SpendingInsightCopyWith<$Res> {
  _$SpendingInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpendingInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? emoji = null,
    Object? type = null,
    Object? amount = null,
    Object? category = null,
    Object? actionText = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as InsightType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            actionText: null == actionText
                ? _value.actionText
                : actionText // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpendingInsightImplCopyWith<$Res>
    implements $SpendingInsightCopyWith<$Res> {
  factory _$$SpendingInsightImplCopyWith(
    _$SpendingInsightImpl value,
    $Res Function(_$SpendingInsightImpl) then,
  ) = __$$SpendingInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String emoji,
    InsightType type,
    double amount,
    String category,
    String actionText,
  });
}

/// @nodoc
class __$$SpendingInsightImplCopyWithImpl<$Res>
    extends _$SpendingInsightCopyWithImpl<$Res, _$SpendingInsightImpl>
    implements _$$SpendingInsightImplCopyWith<$Res> {
  __$$SpendingInsightImplCopyWithImpl(
    _$SpendingInsightImpl _value,
    $Res Function(_$SpendingInsightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SpendingInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? emoji = null,
    Object? type = null,
    Object? amount = null,
    Object? category = null,
    Object? actionText = null,
  }) {
    return _then(
      _$SpendingInsightImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as InsightType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        actionText: null == actionText
            ? _value.actionText
            : actionText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SpendingInsightImpl implements _SpendingInsight {
  const _$SpendingInsightImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    this.amount = 0,
    this.category = '',
    this.actionText = '',
  });

  factory _$SpendingInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpendingInsightImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String emoji;
  @override
  final InsightType type;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final String actionText;

  @override
  String toString() {
    return 'SpendingInsight(id: $id, title: $title, description: $description, emoji: $emoji, type: $type, amount: $amount, category: $category, actionText: $actionText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingInsightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.actionText, actionText) ||
                other.actionText == actionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    emoji,
    type,
    amount,
    category,
    actionText,
  );

  /// Create a copy of SpendingInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingInsightImplCopyWith<_$SpendingInsightImpl> get copyWith =>
      __$$SpendingInsightImplCopyWithImpl<_$SpendingInsightImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SpendingInsightImplToJson(this);
  }
}

abstract class _SpendingInsight implements SpendingInsight {
  const factory _SpendingInsight({
    required final String id,
    required final String title,
    required final String description,
    required final String emoji,
    required final InsightType type,
    final double amount,
    final String category,
    final String actionText,
  }) = _$SpendingInsightImpl;

  factory _SpendingInsight.fromJson(Map<String, dynamic> json) =
      _$SpendingInsightImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get emoji;
  @override
  InsightType get type;
  @override
  double get amount;
  @override
  String get category;
  @override
  String get actionText;

  /// Create a copy of SpendingInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpendingInsightImplCopyWith<_$SpendingInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeftoverSuggestion _$LeftoverSuggestionFromJson(Map<String, dynamic> json) {
  return _LeftoverSuggestion.fromJson(json);
}

/// @nodoc
mixin _$LeftoverSuggestion {
  String get id => throw _privateConstructorUsedError;
  LeftoverAction get action => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get suggestedAmount => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError; // 1 = highest
  String get emoji => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this LeftoverSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeftoverSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeftoverSuggestionCopyWith<LeftoverSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeftoverSuggestionCopyWith<$Res> {
  factory $LeftoverSuggestionCopyWith(
    LeftoverSuggestion value,
    $Res Function(LeftoverSuggestion) then,
  ) = _$LeftoverSuggestionCopyWithImpl<$Res, LeftoverSuggestion>;
  @useResult
  $Res call({
    String id,
    LeftoverAction action,
    String title,
    String description,
    double suggestedAmount,
    int priority,
    String emoji,
    bool isSelected,
  });
}

/// @nodoc
class _$LeftoverSuggestionCopyWithImpl<$Res, $Val extends LeftoverSuggestion>
    implements $LeftoverSuggestionCopyWith<$Res> {
  _$LeftoverSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeftoverSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? title = null,
    Object? description = null,
    Object? suggestedAmount = null,
    Object? priority = null,
    Object? emoji = null,
    Object? isSelected = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as LeftoverAction,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestedAmount: null == suggestedAmount
                ? _value.suggestedAmount
                : suggestedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeftoverSuggestionImplCopyWith<$Res>
    implements $LeftoverSuggestionCopyWith<$Res> {
  factory _$$LeftoverSuggestionImplCopyWith(
    _$LeftoverSuggestionImpl value,
    $Res Function(_$LeftoverSuggestionImpl) then,
  ) = __$$LeftoverSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    LeftoverAction action,
    String title,
    String description,
    double suggestedAmount,
    int priority,
    String emoji,
    bool isSelected,
  });
}

/// @nodoc
class __$$LeftoverSuggestionImplCopyWithImpl<$Res>
    extends _$LeftoverSuggestionCopyWithImpl<$Res, _$LeftoverSuggestionImpl>
    implements _$$LeftoverSuggestionImplCopyWith<$Res> {
  __$$LeftoverSuggestionImplCopyWithImpl(
    _$LeftoverSuggestionImpl _value,
    $Res Function(_$LeftoverSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeftoverSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? title = null,
    Object? description = null,
    Object? suggestedAmount = null,
    Object? priority = null,
    Object? emoji = null,
    Object? isSelected = null,
  }) {
    return _then(
      _$LeftoverSuggestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as LeftoverAction,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestedAmount: null == suggestedAmount
            ? _value.suggestedAmount
            : suggestedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeftoverSuggestionImpl extends _LeftoverSuggestion {
  const _$LeftoverSuggestionImpl({
    required this.id,
    required this.action,
    required this.title,
    required this.description,
    required this.suggestedAmount,
    required this.priority,
    this.emoji = '💰',
    this.isSelected = false,
  }) : super._();

  factory _$LeftoverSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeftoverSuggestionImplFromJson(json);

  @override
  final String id;
  @override
  final LeftoverAction action;
  @override
  final String title;
  @override
  final String description;
  @override
  final double suggestedAmount;
  @override
  final int priority;
  // 1 = highest
  @override
  @JsonKey()
  final String emoji;
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'LeftoverSuggestion(id: $id, action: $action, title: $title, description: $description, suggestedAmount: $suggestedAmount, priority: $priority, emoji: $emoji, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeftoverSuggestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.suggestedAmount, suggestedAmount) ||
                other.suggestedAmount == suggestedAmount) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    action,
    title,
    description,
    suggestedAmount,
    priority,
    emoji,
    isSelected,
  );

  /// Create a copy of LeftoverSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeftoverSuggestionImplCopyWith<_$LeftoverSuggestionImpl> get copyWith =>
      __$$LeftoverSuggestionImplCopyWithImpl<_$LeftoverSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeftoverSuggestionImplToJson(this);
  }
}

abstract class _LeftoverSuggestion extends LeftoverSuggestion {
  const factory _LeftoverSuggestion({
    required final String id,
    required final LeftoverAction action,
    required final String title,
    required final String description,
    required final double suggestedAmount,
    required final int priority,
    final String emoji,
    final bool isSelected,
  }) = _$LeftoverSuggestionImpl;
  const _LeftoverSuggestion._() : super._();

  factory _LeftoverSuggestion.fromJson(Map<String, dynamic> json) =
      _$LeftoverSuggestionImpl.fromJson;

  @override
  String get id;
  @override
  LeftoverAction get action;
  @override
  String get title;
  @override
  String get description;
  @override
  double get suggestedAmount;
  @override
  int get priority; // 1 = highest
  @override
  String get emoji;
  @override
  bool get isSelected;

  /// Create a copy of LeftoverSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeftoverSuggestionImplCopyWith<_$LeftoverSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeftoverAllocation _$LeftoverAllocationFromJson(Map<String, dynamic> json) {
  return _LeftoverAllocation.fromJson(json);
}

/// @nodoc
mixin _$LeftoverAllocation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get summaryId => throw _privateConstructorUsedError;
  LeftoverAction get action => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @TimestampDateTimeConverter()
  DateTime get allocatedAt => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Serializes this LeftoverAllocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeftoverAllocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeftoverAllocationCopyWith<LeftoverAllocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeftoverAllocationCopyWith<$Res> {
  factory $LeftoverAllocationCopyWith(
    LeftoverAllocation value,
    $Res Function(LeftoverAllocation) then,
  ) = _$LeftoverAllocationCopyWithImpl<$Res, LeftoverAllocation>;
  @useResult
  $Res call({
    String id,
    String userId,
    String summaryId,
    LeftoverAction action,
    double amount,
    @TimestampDateTimeConverter() DateTime allocatedAt,
    String note,
  });
}

/// @nodoc
class _$LeftoverAllocationCopyWithImpl<$Res, $Val extends LeftoverAllocation>
    implements $LeftoverAllocationCopyWith<$Res> {
  _$LeftoverAllocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeftoverAllocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? summaryId = null,
    Object? action = null,
    Object? amount = null,
    Object? allocatedAt = null,
    Object? note = null,
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
            summaryId: null == summaryId
                ? _value.summaryId
                : summaryId // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as LeftoverAction,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            allocatedAt: null == allocatedAt
                ? _value.allocatedAt
                : allocatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeftoverAllocationImplCopyWith<$Res>
    implements $LeftoverAllocationCopyWith<$Res> {
  factory _$$LeftoverAllocationImplCopyWith(
    _$LeftoverAllocationImpl value,
    $Res Function(_$LeftoverAllocationImpl) then,
  ) = __$$LeftoverAllocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String summaryId,
    LeftoverAction action,
    double amount,
    @TimestampDateTimeConverter() DateTime allocatedAt,
    String note,
  });
}

/// @nodoc
class __$$LeftoverAllocationImplCopyWithImpl<$Res>
    extends _$LeftoverAllocationCopyWithImpl<$Res, _$LeftoverAllocationImpl>
    implements _$$LeftoverAllocationImplCopyWith<$Res> {
  __$$LeftoverAllocationImplCopyWithImpl(
    _$LeftoverAllocationImpl _value,
    $Res Function(_$LeftoverAllocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeftoverAllocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? summaryId = null,
    Object? action = null,
    Object? amount = null,
    Object? allocatedAt = null,
    Object? note = null,
  }) {
    return _then(
      _$LeftoverAllocationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        summaryId: null == summaryId
            ? _value.summaryId
            : summaryId // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as LeftoverAction,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        allocatedAt: null == allocatedAt
            ? _value.allocatedAt
            : allocatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeftoverAllocationImpl implements _LeftoverAllocation {
  const _$LeftoverAllocationImpl({
    required this.id,
    required this.userId,
    required this.summaryId,
    required this.action,
    required this.amount,
    @TimestampDateTimeConverter() required this.allocatedAt,
    this.note = '',
  });

  factory _$LeftoverAllocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeftoverAllocationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String summaryId;
  @override
  final LeftoverAction action;
  @override
  final double amount;
  @override
  @TimestampDateTimeConverter()
  final DateTime allocatedAt;
  @override
  @JsonKey()
  final String note;

  @override
  String toString() {
    return 'LeftoverAllocation(id: $id, userId: $userId, summaryId: $summaryId, action: $action, amount: $amount, allocatedAt: $allocatedAt, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeftoverAllocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.summaryId, summaryId) ||
                other.summaryId == summaryId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.allocatedAt, allocatedAt) ||
                other.allocatedAt == allocatedAt) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    summaryId,
    action,
    amount,
    allocatedAt,
    note,
  );

  /// Create a copy of LeftoverAllocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeftoverAllocationImplCopyWith<_$LeftoverAllocationImpl> get copyWith =>
      __$$LeftoverAllocationImplCopyWithImpl<_$LeftoverAllocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeftoverAllocationImplToJson(this);
  }
}

abstract class _LeftoverAllocation implements LeftoverAllocation {
  const factory _LeftoverAllocation({
    required final String id,
    required final String userId,
    required final String summaryId,
    required final LeftoverAction action,
    required final double amount,
    @TimestampDateTimeConverter() required final DateTime allocatedAt,
    final String note,
  }) = _$LeftoverAllocationImpl;

  factory _LeftoverAllocation.fromJson(Map<String, dynamic> json) =
      _$LeftoverAllocationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get summaryId;
  @override
  LeftoverAction get action;
  @override
  double get amount;
  @override
  @TimestampDateTimeConverter()
  DateTime get allocatedAt;
  @override
  String get note;

  /// Create a copy of LeftoverAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeftoverAllocationImplCopyWith<_$LeftoverAllocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
