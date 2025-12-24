/// Subscription Analysis model for cancellation recommendations
/// Industry-grade implementation following US/EU market standards
import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters/timestamp_converter.dart';

part 'subscription_analysis.freezed.dart';
part 'subscription_analysis.g.dart';

/// Usage level for subscription
enum UsageLevel {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
  @JsonValue('unused')
  unused,
}

/// Recommendation type
enum RecommendationType {
  @JsonValue('keep')
  keep,
  @JsonValue('review')
  review,
  @JsonValue('downgrade')
  downgrade,
  @JsonValue('cancel')
  cancel,
  @JsonValue('bundle')
  bundle,
}

@freezed
class SubscriptionAnalysis with _$SubscriptionAnalysis {
  const SubscriptionAnalysis._();

  const factory SubscriptionAnalysis({
    required String id,
    required String userId,
    required String subscriptionId,
    required String subscriptionName,
    required double monthlyAmount,
    required UsageLevel usageLevel,
    required RecommendationType recommendation,
    @Default(0.0) double potentialSavings,
    @Default('') String analysisNote,
    @Default([]) List<String> reasons,
    @Default([]) List<String> alternatives,
    @Default(0) int usageScore, // 0-100
    @TimestampDateTimeConverter() DateTime? lastUsedDate,
    @TimestampDateTimeConverter() DateTime? analyzedAt,
  }) = _SubscriptionAnalysis;

  factory SubscriptionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAnalysisFromJson(json);

  /// Get recommendation text
  String get recommendationText {
    switch (recommendation) {
      case RecommendationType.keep:
        return 'Keep - Good value for money';
      case RecommendationType.review:
        return 'Review - Consider if still needed';
      case RecommendationType.downgrade:
        return 'Downgrade - Switch to cheaper plan';
      case RecommendationType.cancel:
        return 'Cancel - Not being used';
      case RecommendationType.bundle:
        return 'Bundle - Combine with other services';
    }
  }

  /// Get recommendation emoji
  String get recommendationEmoji {
    switch (recommendation) {
      case RecommendationType.keep:
        return '✅';
      case RecommendationType.review:
        return '🔍';
      case RecommendationType.downgrade:
        return '⬇️';
      case RecommendationType.cancel:
        return '❌';
      case RecommendationType.bundle:
        return '📦';
    }
  }

  /// Get usage level text
  String get usageLevelText {
    switch (usageLevel) {
      case UsageLevel.high:
        return 'Heavy user';
      case UsageLevel.medium:
        return 'Moderate user';
      case UsageLevel.low:
        return 'Light user';
      case UsageLevel.unused:
        return 'Not used recently';
    }
  }
}

/// Summary of all subscription analysis
@freezed
class SubscriptionSummary with _$SubscriptionSummary {
  const factory SubscriptionSummary({
    required String userId,
    required int totalSubscriptions,
    required double totalMonthlySpend,
    required double totalYearlySpend,
    required double potentialMonthlySavings,
    required double potentialYearlySavings,
    required int subscriptionsToReview,
    required int subscriptionsToCancel,
    @Default({}) Map<String, double> spendByCategory,
    @Default([]) List<SubscriptionAnalysis> analyses,
    @TimestampDateTimeConverter() DateTime? lastAnalyzedAt,
  }) = _SubscriptionSummary;

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionSummaryFromJson(json);
}
