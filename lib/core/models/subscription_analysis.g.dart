// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionAnalysisImpl _$$SubscriptionAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionAnalysisImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  subscriptionId: json['subscriptionId'] as String,
  subscriptionName: json['subscriptionName'] as String,
  monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
  usageLevel: $enumDecode(_$UsageLevelEnumMap, json['usageLevel']),
  recommendation: $enumDecode(
    _$RecommendationTypeEnumMap,
    json['recommendation'],
  ),
  potentialSavings: (json['potentialSavings'] as num?)?.toDouble() ?? 0.0,
  analysisNote: json['analysisNote'] as String? ?? '',
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  alternatives:
      (json['alternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  usageScore: (json['usageScore'] as num?)?.toInt() ?? 0,
  lastUsedDate: const TimestampDateTimeConverter().fromJson(
    json['lastUsedDate'],
  ),
  analyzedAt: const TimestampDateTimeConverter().fromJson(json['analyzedAt']),
);

Map<String, dynamic> _$$SubscriptionAnalysisImplToJson(
  _$SubscriptionAnalysisImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'subscriptionId': instance.subscriptionId,
  'subscriptionName': instance.subscriptionName,
  'monthlyAmount': instance.monthlyAmount,
  'usageLevel': _$UsageLevelEnumMap[instance.usageLevel]!,
  'recommendation': _$RecommendationTypeEnumMap[instance.recommendation]!,
  'potentialSavings': instance.potentialSavings,
  'analysisNote': instance.analysisNote,
  'reasons': instance.reasons,
  'alternatives': instance.alternatives,
  'usageScore': instance.usageScore,
  'lastUsedDate': const TimestampDateTimeConverter().toJson(
    instance.lastUsedDate,
  ),
  'analyzedAt': const TimestampDateTimeConverter().toJson(instance.analyzedAt),
};

const _$UsageLevelEnumMap = {
  UsageLevel.high: 'high',
  UsageLevel.medium: 'medium',
  UsageLevel.low: 'low',
  UsageLevel.unused: 'unused',
};

const _$RecommendationTypeEnumMap = {
  RecommendationType.keep: 'keep',
  RecommendationType.review: 'review',
  RecommendationType.downgrade: 'downgrade',
  RecommendationType.cancel: 'cancel',
  RecommendationType.bundle: 'bundle',
};

_$SubscriptionSummaryImpl _$$SubscriptionSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionSummaryImpl(
  userId: json['userId'] as String,
  totalSubscriptions: (json['totalSubscriptions'] as num).toInt(),
  totalMonthlySpend: (json['totalMonthlySpend'] as num).toDouble(),
  totalYearlySpend: (json['totalYearlySpend'] as num).toDouble(),
  potentialMonthlySavings: (json['potentialMonthlySavings'] as num).toDouble(),
  potentialYearlySavings: (json['potentialYearlySavings'] as num).toDouble(),
  subscriptionsToReview: (json['subscriptionsToReview'] as num).toInt(),
  subscriptionsToCancel: (json['subscriptionsToCancel'] as num).toInt(),
  spendByCategory:
      (json['spendByCategory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  analyses:
      (json['analyses'] as List<dynamic>?)
          ?.map((e) => SubscriptionAnalysis.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastAnalyzedAt: const TimestampDateTimeConverter().fromJson(
    json['lastAnalyzedAt'],
  ),
);

Map<String, dynamic> _$$SubscriptionSummaryImplToJson(
  _$SubscriptionSummaryImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'totalSubscriptions': instance.totalSubscriptions,
  'totalMonthlySpend': instance.totalMonthlySpend,
  'totalYearlySpend': instance.totalYearlySpend,
  'potentialMonthlySavings': instance.potentialMonthlySavings,
  'potentialYearlySavings': instance.potentialYearlySavings,
  'subscriptionsToReview': instance.subscriptionsToReview,
  'subscriptionsToCancel': instance.subscriptionsToCancel,
  'spendByCategory': instance.spendByCategory,
  'analyses': instance.analyses,
  'lastAnalyzedAt': const TimestampDateTimeConverter().toJson(
    instance.lastAnalyzedAt,
  ),
};
