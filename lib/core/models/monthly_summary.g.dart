// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlySummaryImpl _$$MonthlySummaryImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlySummaryImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  totalIncome: (json['totalIncome'] as num).toDouble(),
  totalExpenses: (json['totalExpenses'] as num).toDouble(),
  totalSubscriptions: (json['totalSubscriptions'] as num).toDouble(),
  leftoverAmount: (json['leftoverAmount'] as num).toDouble(),
  healthStatus: $enumDecode(_$FinancialHealthEnumMap, json['healthStatus']),
  trend: $enumDecode(_$SpendingTrendEnumMap, json['trend']),
  expensesByCategory:
      (json['expensesByCategory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  insights:
      (json['insights'] as List<dynamic>?)
          ?.map((e) => SpendingInsight.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  leftoverSuggestions:
      (json['leftoverSuggestions'] as List<dynamic>?)
          ?.map((e) => LeftoverSuggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  savingsGoalProgress: (json['savingsGoalProgress'] as num?)?.toDouble() ?? 0,
  emergencyFundProgress:
      (json['emergencyFundProgress'] as num?)?.toDouble() ?? 0,
  createdAt: const TimestampDateTimeConverter().fromJson(json['createdAt']),
  finalizedAt: const TimestampDateTimeConverter().fromJson(json['finalizedAt']),
);

Map<String, dynamic> _$$MonthlySummaryImplToJson(
  _$MonthlySummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'year': instance.year,
  'month': instance.month,
  'totalIncome': instance.totalIncome,
  'totalExpenses': instance.totalExpenses,
  'totalSubscriptions': instance.totalSubscriptions,
  'leftoverAmount': instance.leftoverAmount,
  'healthStatus': _$FinancialHealthEnumMap[instance.healthStatus]!,
  'trend': _$SpendingTrendEnumMap[instance.trend]!,
  'expensesByCategory': instance.expensesByCategory,
  'insights': instance.insights,
  'leftoverSuggestions': instance.leftoverSuggestions,
  'savingsGoalProgress': instance.savingsGoalProgress,
  'emergencyFundProgress': instance.emergencyFundProgress,
  'createdAt': const TimestampDateTimeConverter().toJson(instance.createdAt),
  'finalizedAt': const TimestampDateTimeConverter().toJson(
    instance.finalizedAt,
  ),
};

const _$FinancialHealthEnumMap = {
  FinancialHealth.excellent: 'excellent',
  FinancialHealth.good: 'good',
  FinancialHealth.fair: 'fair',
  FinancialHealth.poor: 'poor',
  FinancialHealth.critical: 'critical',
};

const _$SpendingTrendEnumMap = {
  SpendingTrend.increasing: 'increasing',
  SpendingTrend.decreasing: 'decreasing',
  SpendingTrend.stable: 'stable',
};

_$SpendingInsightImpl _$$SpendingInsightImplFromJson(
  Map<String, dynamic> json,
) => _$SpendingInsightImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  emoji: json['emoji'] as String,
  type: $enumDecode(_$InsightTypeEnumMap, json['type']),
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  category: json['category'] as String? ?? '',
  actionText: json['actionText'] as String? ?? '',
);

Map<String, dynamic> _$$SpendingInsightImplToJson(
  _$SpendingInsightImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'emoji': instance.emoji,
  'type': _$InsightTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'category': instance.category,
  'actionText': instance.actionText,
};

const _$InsightTypeEnumMap = {
  InsightType.positive: 'positive',
  InsightType.warning: 'warning',
  InsightType.tip: 'tip',
  InsightType.achievement: 'achievement',
};

_$LeftoverSuggestionImpl _$$LeftoverSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$LeftoverSuggestionImpl(
  id: json['id'] as String,
  action: $enumDecode(_$LeftoverActionEnumMap, json['action']),
  title: json['title'] as String,
  description: json['description'] as String,
  suggestedAmount: (json['suggestedAmount'] as num).toDouble(),
  priority: (json['priority'] as num).toInt(),
  emoji: json['emoji'] as String? ?? '💰',
  isSelected: json['isSelected'] as bool? ?? false,
);

Map<String, dynamic> _$$LeftoverSuggestionImplToJson(
  _$LeftoverSuggestionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': _$LeftoverActionEnumMap[instance.action]!,
  'title': instance.title,
  'description': instance.description,
  'suggestedAmount': instance.suggestedAmount,
  'priority': instance.priority,
  'emoji': instance.emoji,
  'isSelected': instance.isSelected,
};

const _$LeftoverActionEnumMap = {
  LeftoverAction.save: 'save',
  LeftoverAction.invest: 'invest',
  LeftoverAction.emergency: 'emergency',
  LeftoverAction.debt: 'debt',
  LeftoverAction.rollover: 'rollover',
  LeftoverAction.treat: 'treat',
};

_$LeftoverAllocationImpl _$$LeftoverAllocationImplFromJson(
  Map<String, dynamic> json,
) => _$LeftoverAllocationImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  summaryId: json['summaryId'] as String,
  action: $enumDecode(_$LeftoverActionEnumMap, json['action']),
  amount: (json['amount'] as num).toDouble(),
  allocatedAt: DateTime.parse(json['allocatedAt'] as String),
  note: json['note'] as String? ?? '',
);

Map<String, dynamic> _$$LeftoverAllocationImplToJson(
  _$LeftoverAllocationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'summaryId': instance.summaryId,
  'action': _$LeftoverActionEnumMap[instance.action]!,
  'amount': instance.amount,
  'allocatedAt': instance.allocatedAt.toIso8601String(),
  'note': instance.note,
};
