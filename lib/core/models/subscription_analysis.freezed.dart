// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionAnalysis _$SubscriptionAnalysisFromJson(Map<String, dynamic> json) {
  return _SubscriptionAnalysis.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionAnalysis {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get subscriptionId => throw _privateConstructorUsedError;
  String get subscriptionName => throw _privateConstructorUsedError;
  double get monthlyAmount => throw _privateConstructorUsedError;
  UsageLevel get usageLevel => throw _privateConstructorUsedError;
  RecommendationType get recommendation => throw _privateConstructorUsedError;
  double get potentialSavings => throw _privateConstructorUsedError;
  String get analysisNote => throw _privateConstructorUsedError;
  List<String> get reasons => throw _privateConstructorUsedError;
  List<String> get alternatives => throw _privateConstructorUsedError;
  int get usageScore => throw _privateConstructorUsedError; // 0-100
  DateTime? get lastUsedDate => throw _privateConstructorUsedError;
  DateTime? get analyzedAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionAnalysisCopyWith<SubscriptionAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionAnalysisCopyWith<$Res> {
  factory $SubscriptionAnalysisCopyWith(
    SubscriptionAnalysis value,
    $Res Function(SubscriptionAnalysis) then,
  ) = _$SubscriptionAnalysisCopyWithImpl<$Res, SubscriptionAnalysis>;
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String subscriptionName,
    double monthlyAmount,
    UsageLevel usageLevel,
    RecommendationType recommendation,
    double potentialSavings,
    String analysisNote,
    List<String> reasons,
    List<String> alternatives,
    int usageScore,
    DateTime? lastUsedDate,
    DateTime? analyzedAt,
  });
}

/// @nodoc
class _$SubscriptionAnalysisCopyWithImpl<
  $Res,
  $Val extends SubscriptionAnalysis
>
    implements $SubscriptionAnalysisCopyWith<$Res> {
  _$SubscriptionAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? subscriptionName = null,
    Object? monthlyAmount = null,
    Object? usageLevel = null,
    Object? recommendation = null,
    Object? potentialSavings = null,
    Object? analysisNote = null,
    Object? reasons = null,
    Object? alternatives = null,
    Object? usageScore = null,
    Object? lastUsedDate = freezed,
    Object? analyzedAt = freezed,
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
            monthlyAmount: null == monthlyAmount
                ? _value.monthlyAmount
                : monthlyAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            usageLevel: null == usageLevel
                ? _value.usageLevel
                : usageLevel // ignore: cast_nullable_to_non_nullable
                      as UsageLevel,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as RecommendationType,
            potentialSavings: null == potentialSavings
                ? _value.potentialSavings
                : potentialSavings // ignore: cast_nullable_to_non_nullable
                      as double,
            analysisNote: null == analysisNote
                ? _value.analysisNote
                : analysisNote // ignore: cast_nullable_to_non_nullable
                      as String,
            reasons: null == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            alternatives: null == alternatives
                ? _value.alternatives
                : alternatives // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            usageScore: null == usageScore
                ? _value.usageScore
                : usageScore // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUsedDate: freezed == lastUsedDate
                ? _value.lastUsedDate
                : lastUsedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            analyzedAt: freezed == analyzedAt
                ? _value.analyzedAt
                : analyzedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionAnalysisImplCopyWith<$Res>
    implements $SubscriptionAnalysisCopyWith<$Res> {
  factory _$$SubscriptionAnalysisImplCopyWith(
    _$SubscriptionAnalysisImpl value,
    $Res Function(_$SubscriptionAnalysisImpl) then,
  ) = __$$SubscriptionAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String subscriptionName,
    double monthlyAmount,
    UsageLevel usageLevel,
    RecommendationType recommendation,
    double potentialSavings,
    String analysisNote,
    List<String> reasons,
    List<String> alternatives,
    int usageScore,
    DateTime? lastUsedDate,
    DateTime? analyzedAt,
  });
}

/// @nodoc
class __$$SubscriptionAnalysisImplCopyWithImpl<$Res>
    extends _$SubscriptionAnalysisCopyWithImpl<$Res, _$SubscriptionAnalysisImpl>
    implements _$$SubscriptionAnalysisImplCopyWith<$Res> {
  __$$SubscriptionAnalysisImplCopyWithImpl(
    _$SubscriptionAnalysisImpl _value,
    $Res Function(_$SubscriptionAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? subscriptionName = null,
    Object? monthlyAmount = null,
    Object? usageLevel = null,
    Object? recommendation = null,
    Object? potentialSavings = null,
    Object? analysisNote = null,
    Object? reasons = null,
    Object? alternatives = null,
    Object? usageScore = null,
    Object? lastUsedDate = freezed,
    Object? analyzedAt = freezed,
  }) {
    return _then(
      _$SubscriptionAnalysisImpl(
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
        monthlyAmount: null == monthlyAmount
            ? _value.monthlyAmount
            : monthlyAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        usageLevel: null == usageLevel
            ? _value.usageLevel
            : usageLevel // ignore: cast_nullable_to_non_nullable
                  as UsageLevel,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as RecommendationType,
        potentialSavings: null == potentialSavings
            ? _value.potentialSavings
            : potentialSavings // ignore: cast_nullable_to_non_nullable
                  as double,
        analysisNote: null == analysisNote
            ? _value.analysisNote
            : analysisNote // ignore: cast_nullable_to_non_nullable
                  as String,
        reasons: null == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        alternatives: null == alternatives
            ? _value._alternatives
            : alternatives // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        usageScore: null == usageScore
            ? _value.usageScore
            : usageScore // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUsedDate: freezed == lastUsedDate
            ? _value.lastUsedDate
            : lastUsedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        analyzedAt: freezed == analyzedAt
            ? _value.analyzedAt
            : analyzedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionAnalysisImpl extends _SubscriptionAnalysis {
  const _$SubscriptionAnalysisImpl({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.monthlyAmount,
    required this.usageLevel,
    required this.recommendation,
    this.potentialSavings = 0.0,
    this.analysisNote = '',
    final List<String> reasons = const [],
    final List<String> alternatives = const [],
    this.usageScore = 0,
    this.lastUsedDate,
    this.analyzedAt,
  }) : _reasons = reasons,
       _alternatives = alternatives,
       super._();

  factory _$SubscriptionAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionAnalysisImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String subscriptionId;
  @override
  final String subscriptionName;
  @override
  final double monthlyAmount;
  @override
  final UsageLevel usageLevel;
  @override
  final RecommendationType recommendation;
  @override
  @JsonKey()
  final double potentialSavings;
  @override
  @JsonKey()
  final String analysisNote;
  final List<String> _reasons;
  @override
  @JsonKey()
  List<String> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  final List<String> _alternatives;
  @override
  @JsonKey()
  List<String> get alternatives {
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternatives);
  }

  @override
  @JsonKey()
  final int usageScore;
  // 0-100
  @override
  final DateTime? lastUsedDate;
  @override
  final DateTime? analyzedAt;

  @override
  String toString() {
    return 'SubscriptionAnalysis(id: $id, userId: $userId, subscriptionId: $subscriptionId, subscriptionName: $subscriptionName, monthlyAmount: $monthlyAmount, usageLevel: $usageLevel, recommendation: $recommendation, potentialSavings: $potentialSavings, analysisNote: $analysisNote, reasons: $reasons, alternatives: $alternatives, usageScore: $usageScore, lastUsedDate: $lastUsedDate, analyzedAt: $analyzedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionAnalysisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.subscriptionName, subscriptionName) ||
                other.subscriptionName == subscriptionName) &&
            (identical(other.monthlyAmount, monthlyAmount) ||
                other.monthlyAmount == monthlyAmount) &&
            (identical(other.usageLevel, usageLevel) ||
                other.usageLevel == usageLevel) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.potentialSavings, potentialSavings) ||
                other.potentialSavings == potentialSavings) &&
            (identical(other.analysisNote, analysisNote) ||
                other.analysisNote == analysisNote) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            const DeepCollectionEquality().equals(
              other._alternatives,
              _alternatives,
            ) &&
            (identical(other.usageScore, usageScore) ||
                other.usageScore == usageScore) &&
            (identical(other.lastUsedDate, lastUsedDate) ||
                other.lastUsedDate == lastUsedDate) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    subscriptionId,
    subscriptionName,
    monthlyAmount,
    usageLevel,
    recommendation,
    potentialSavings,
    analysisNote,
    const DeepCollectionEquality().hash(_reasons),
    const DeepCollectionEquality().hash(_alternatives),
    usageScore,
    lastUsedDate,
    analyzedAt,
  );

  /// Create a copy of SubscriptionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionAnalysisImplCopyWith<_$SubscriptionAnalysisImpl>
  get copyWith =>
      __$$SubscriptionAnalysisImplCopyWithImpl<_$SubscriptionAnalysisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionAnalysisImplToJson(this);
  }
}

abstract class _SubscriptionAnalysis extends SubscriptionAnalysis {
  const factory _SubscriptionAnalysis({
    required final String id,
    required final String userId,
    required final String subscriptionId,
    required final String subscriptionName,
    required final double monthlyAmount,
    required final UsageLevel usageLevel,
    required final RecommendationType recommendation,
    final double potentialSavings,
    final String analysisNote,
    final List<String> reasons,
    final List<String> alternatives,
    final int usageScore,
    final DateTime? lastUsedDate,
    final DateTime? analyzedAt,
  }) = _$SubscriptionAnalysisImpl;
  const _SubscriptionAnalysis._() : super._();

  factory _SubscriptionAnalysis.fromJson(Map<String, dynamic> json) =
      _$SubscriptionAnalysisImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get subscriptionId;
  @override
  String get subscriptionName;
  @override
  double get monthlyAmount;
  @override
  UsageLevel get usageLevel;
  @override
  RecommendationType get recommendation;
  @override
  double get potentialSavings;
  @override
  String get analysisNote;
  @override
  List<String> get reasons;
  @override
  List<String> get alternatives;
  @override
  int get usageScore; // 0-100
  @override
  DateTime? get lastUsedDate;
  @override
  DateTime? get analyzedAt;

  /// Create a copy of SubscriptionAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionAnalysisImplCopyWith<_$SubscriptionAnalysisImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SubscriptionSummary _$SubscriptionSummaryFromJson(Map<String, dynamic> json) {
  return _SubscriptionSummary.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionSummary {
  String get userId => throw _privateConstructorUsedError;
  int get totalSubscriptions => throw _privateConstructorUsedError;
  double get totalMonthlySpend => throw _privateConstructorUsedError;
  double get totalYearlySpend => throw _privateConstructorUsedError;
  double get potentialMonthlySavings => throw _privateConstructorUsedError;
  double get potentialYearlySavings => throw _privateConstructorUsedError;
  int get subscriptionsToReview => throw _privateConstructorUsedError;
  int get subscriptionsToCancel => throw _privateConstructorUsedError;
  Map<String, double> get spendByCategory => throw _privateConstructorUsedError;
  List<SubscriptionAnalysis> get analyses => throw _privateConstructorUsedError;
  DateTime? get lastAnalyzedAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionSummaryCopyWith<SubscriptionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionSummaryCopyWith<$Res> {
  factory $SubscriptionSummaryCopyWith(
    SubscriptionSummary value,
    $Res Function(SubscriptionSummary) then,
  ) = _$SubscriptionSummaryCopyWithImpl<$Res, SubscriptionSummary>;
  @useResult
  $Res call({
    String userId,
    int totalSubscriptions,
    double totalMonthlySpend,
    double totalYearlySpend,
    double potentialMonthlySavings,
    double potentialYearlySavings,
    int subscriptionsToReview,
    int subscriptionsToCancel,
    Map<String, double> spendByCategory,
    List<SubscriptionAnalysis> analyses,
    DateTime? lastAnalyzedAt,
  });
}

/// @nodoc
class _$SubscriptionSummaryCopyWithImpl<$Res, $Val extends SubscriptionSummary>
    implements $SubscriptionSummaryCopyWith<$Res> {
  _$SubscriptionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalSubscriptions = null,
    Object? totalMonthlySpend = null,
    Object? totalYearlySpend = null,
    Object? potentialMonthlySavings = null,
    Object? potentialYearlySavings = null,
    Object? subscriptionsToReview = null,
    Object? subscriptionsToCancel = null,
    Object? spendByCategory = null,
    Object? analyses = null,
    Object? lastAnalyzedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalSubscriptions: null == totalSubscriptions
                ? _value.totalSubscriptions
                : totalSubscriptions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalMonthlySpend: null == totalMonthlySpend
                ? _value.totalMonthlySpend
                : totalMonthlySpend // ignore: cast_nullable_to_non_nullable
                      as double,
            totalYearlySpend: null == totalYearlySpend
                ? _value.totalYearlySpend
                : totalYearlySpend // ignore: cast_nullable_to_non_nullable
                      as double,
            potentialMonthlySavings: null == potentialMonthlySavings
                ? _value.potentialMonthlySavings
                : potentialMonthlySavings // ignore: cast_nullable_to_non_nullable
                      as double,
            potentialYearlySavings: null == potentialYearlySavings
                ? _value.potentialYearlySavings
                : potentialYearlySavings // ignore: cast_nullable_to_non_nullable
                      as double,
            subscriptionsToReview: null == subscriptionsToReview
                ? _value.subscriptionsToReview
                : subscriptionsToReview // ignore: cast_nullable_to_non_nullable
                      as int,
            subscriptionsToCancel: null == subscriptionsToCancel
                ? _value.subscriptionsToCancel
                : subscriptionsToCancel // ignore: cast_nullable_to_non_nullable
                      as int,
            spendByCategory: null == spendByCategory
                ? _value.spendByCategory
                : spendByCategory // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            analyses: null == analyses
                ? _value.analyses
                : analyses // ignore: cast_nullable_to_non_nullable
                      as List<SubscriptionAnalysis>,
            lastAnalyzedAt: freezed == lastAnalyzedAt
                ? _value.lastAnalyzedAt
                : lastAnalyzedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionSummaryImplCopyWith<$Res>
    implements $SubscriptionSummaryCopyWith<$Res> {
  factory _$$SubscriptionSummaryImplCopyWith(
    _$SubscriptionSummaryImpl value,
    $Res Function(_$SubscriptionSummaryImpl) then,
  ) = __$$SubscriptionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int totalSubscriptions,
    double totalMonthlySpend,
    double totalYearlySpend,
    double potentialMonthlySavings,
    double potentialYearlySavings,
    int subscriptionsToReview,
    int subscriptionsToCancel,
    Map<String, double> spendByCategory,
    List<SubscriptionAnalysis> analyses,
    DateTime? lastAnalyzedAt,
  });
}

/// @nodoc
class __$$SubscriptionSummaryImplCopyWithImpl<$Res>
    extends _$SubscriptionSummaryCopyWithImpl<$Res, _$SubscriptionSummaryImpl>
    implements _$$SubscriptionSummaryImplCopyWith<$Res> {
  __$$SubscriptionSummaryImplCopyWithImpl(
    _$SubscriptionSummaryImpl _value,
    $Res Function(_$SubscriptionSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalSubscriptions = null,
    Object? totalMonthlySpend = null,
    Object? totalYearlySpend = null,
    Object? potentialMonthlySavings = null,
    Object? potentialYearlySavings = null,
    Object? subscriptionsToReview = null,
    Object? subscriptionsToCancel = null,
    Object? spendByCategory = null,
    Object? analyses = null,
    Object? lastAnalyzedAt = freezed,
  }) {
    return _then(
      _$SubscriptionSummaryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalSubscriptions: null == totalSubscriptions
            ? _value.totalSubscriptions
            : totalSubscriptions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalMonthlySpend: null == totalMonthlySpend
            ? _value.totalMonthlySpend
            : totalMonthlySpend // ignore: cast_nullable_to_non_nullable
                  as double,
        totalYearlySpend: null == totalYearlySpend
            ? _value.totalYearlySpend
            : totalYearlySpend // ignore: cast_nullable_to_non_nullable
                  as double,
        potentialMonthlySavings: null == potentialMonthlySavings
            ? _value.potentialMonthlySavings
            : potentialMonthlySavings // ignore: cast_nullable_to_non_nullable
                  as double,
        potentialYearlySavings: null == potentialYearlySavings
            ? _value.potentialYearlySavings
            : potentialYearlySavings // ignore: cast_nullable_to_non_nullable
                  as double,
        subscriptionsToReview: null == subscriptionsToReview
            ? _value.subscriptionsToReview
            : subscriptionsToReview // ignore: cast_nullable_to_non_nullable
                  as int,
        subscriptionsToCancel: null == subscriptionsToCancel
            ? _value.subscriptionsToCancel
            : subscriptionsToCancel // ignore: cast_nullable_to_non_nullable
                  as int,
        spendByCategory: null == spendByCategory
            ? _value._spendByCategory
            : spendByCategory // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        analyses: null == analyses
            ? _value._analyses
            : analyses // ignore: cast_nullable_to_non_nullable
                  as List<SubscriptionAnalysis>,
        lastAnalyzedAt: freezed == lastAnalyzedAt
            ? _value.lastAnalyzedAt
            : lastAnalyzedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionSummaryImpl implements _SubscriptionSummary {
  const _$SubscriptionSummaryImpl({
    required this.userId,
    required this.totalSubscriptions,
    required this.totalMonthlySpend,
    required this.totalYearlySpend,
    required this.potentialMonthlySavings,
    required this.potentialYearlySavings,
    required this.subscriptionsToReview,
    required this.subscriptionsToCancel,
    final Map<String, double> spendByCategory = const {},
    final List<SubscriptionAnalysis> analyses = const [],
    this.lastAnalyzedAt,
  }) : _spendByCategory = spendByCategory,
       _analyses = analyses;

  factory _$SubscriptionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionSummaryImplFromJson(json);

  @override
  final String userId;
  @override
  final int totalSubscriptions;
  @override
  final double totalMonthlySpend;
  @override
  final double totalYearlySpend;
  @override
  final double potentialMonthlySavings;
  @override
  final double potentialYearlySavings;
  @override
  final int subscriptionsToReview;
  @override
  final int subscriptionsToCancel;
  final Map<String, double> _spendByCategory;
  @override
  @JsonKey()
  Map<String, double> get spendByCategory {
    if (_spendByCategory is EqualUnmodifiableMapView) return _spendByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_spendByCategory);
  }

  final List<SubscriptionAnalysis> _analyses;
  @override
  @JsonKey()
  List<SubscriptionAnalysis> get analyses {
    if (_analyses is EqualUnmodifiableListView) return _analyses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_analyses);
  }

  @override
  final DateTime? lastAnalyzedAt;

  @override
  String toString() {
    return 'SubscriptionSummary(userId: $userId, totalSubscriptions: $totalSubscriptions, totalMonthlySpend: $totalMonthlySpend, totalYearlySpend: $totalYearlySpend, potentialMonthlySavings: $potentialMonthlySavings, potentialYearlySavings: $potentialYearlySavings, subscriptionsToReview: $subscriptionsToReview, subscriptionsToCancel: $subscriptionsToCancel, spendByCategory: $spendByCategory, analyses: $analyses, lastAnalyzedAt: $lastAnalyzedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionSummaryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalSubscriptions, totalSubscriptions) ||
                other.totalSubscriptions == totalSubscriptions) &&
            (identical(other.totalMonthlySpend, totalMonthlySpend) ||
                other.totalMonthlySpend == totalMonthlySpend) &&
            (identical(other.totalYearlySpend, totalYearlySpend) ||
                other.totalYearlySpend == totalYearlySpend) &&
            (identical(
                  other.potentialMonthlySavings,
                  potentialMonthlySavings,
                ) ||
                other.potentialMonthlySavings == potentialMonthlySavings) &&
            (identical(other.potentialYearlySavings, potentialYearlySavings) ||
                other.potentialYearlySavings == potentialYearlySavings) &&
            (identical(other.subscriptionsToReview, subscriptionsToReview) ||
                other.subscriptionsToReview == subscriptionsToReview) &&
            (identical(other.subscriptionsToCancel, subscriptionsToCancel) ||
                other.subscriptionsToCancel == subscriptionsToCancel) &&
            const DeepCollectionEquality().equals(
              other._spendByCategory,
              _spendByCategory,
            ) &&
            const DeepCollectionEquality().equals(other._analyses, _analyses) &&
            (identical(other.lastAnalyzedAt, lastAnalyzedAt) ||
                other.lastAnalyzedAt == lastAnalyzedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    totalSubscriptions,
    totalMonthlySpend,
    totalYearlySpend,
    potentialMonthlySavings,
    potentialYearlySavings,
    subscriptionsToReview,
    subscriptionsToCancel,
    const DeepCollectionEquality().hash(_spendByCategory),
    const DeepCollectionEquality().hash(_analyses),
    lastAnalyzedAt,
  );

  /// Create a copy of SubscriptionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionSummaryImplCopyWith<_$SubscriptionSummaryImpl> get copyWith =>
      __$$SubscriptionSummaryImplCopyWithImpl<_$SubscriptionSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionSummaryImplToJson(this);
  }
}

abstract class _SubscriptionSummary implements SubscriptionSummary {
  const factory _SubscriptionSummary({
    required final String userId,
    required final int totalSubscriptions,
    required final double totalMonthlySpend,
    required final double totalYearlySpend,
    required final double potentialMonthlySavings,
    required final double potentialYearlySavings,
    required final int subscriptionsToReview,
    required final int subscriptionsToCancel,
    final Map<String, double> spendByCategory,
    final List<SubscriptionAnalysis> analyses,
    final DateTime? lastAnalyzedAt,
  }) = _$SubscriptionSummaryImpl;

  factory _SubscriptionSummary.fromJson(Map<String, dynamic> json) =
      _$SubscriptionSummaryImpl.fromJson;

  @override
  String get userId;
  @override
  int get totalSubscriptions;
  @override
  double get totalMonthlySpend;
  @override
  double get totalYearlySpend;
  @override
  double get potentialMonthlySavings;
  @override
  double get potentialYearlySavings;
  @override
  int get subscriptionsToReview;
  @override
  int get subscriptionsToCancel;
  @override
  Map<String, double> get spendByCategory;
  @override
  List<SubscriptionAnalysis> get analyses;
  @override
  DateTime? get lastAnalyzedAt;

  /// Create a copy of SubscriptionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionSummaryImplCopyWith<_$SubscriptionSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
