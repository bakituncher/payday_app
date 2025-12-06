/// Category Filter Chips Widget
/// Horizontal scrolling filter for subscription categories
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/models/subscription.dart';
import 'package:payday_flutter/features/subscriptions/providers/subscription_providers.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    final categories = [
      null, // All
      SubscriptionCategory.streaming,
      SubscriptionCategory.productivity,
      SubscriptionCategory.cloudStorage,
      SubscriptionCategory.fitness,
      SubscriptionCategory.gaming,
      SubscriptionCategory.shopping,
      SubscriptionCategory.newsMedia,
      SubscriptionCategory.education,
      SubscriptionCategory.utilities,
      SubscriptionCategory.other,
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(
              right: AppSpacing.xs,
              left: index == 0 ? 0 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedCategoryFilterProvider.notifier).state = category;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.pinkGradient : null,
                  color: isSelected ? null : AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPink.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category != null) ...[
                      Text(
                        _getCategoryEmoji(category),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      category == null ? 'All' : _getCategoryName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkCharcoal,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryName(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return 'Streaming';
      case SubscriptionCategory.productivity:
        return 'Productivity';
      case SubscriptionCategory.cloudStorage:
        return 'Cloud';
      case SubscriptionCategory.fitness:
        return 'Fitness';
      case SubscriptionCategory.gaming:
        return 'Gaming';
      case SubscriptionCategory.newsMedia:
        return 'News';
      case SubscriptionCategory.foodDelivery:
        return 'Food';
      case SubscriptionCategory.shopping:
        return 'Shopping';
      case SubscriptionCategory.finance:
        return 'Finance';
      case SubscriptionCategory.education:
        return 'Education';
      case SubscriptionCategory.utilities:
        return 'Utilities';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }

  String _getCategoryEmoji(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return '🎬';
      case SubscriptionCategory.productivity:
        return '💼';
      case SubscriptionCategory.cloudStorage:
        return '☁️';
      case SubscriptionCategory.fitness:
        return '💪';
      case SubscriptionCategory.gaming:
        return '🎮';
      case SubscriptionCategory.newsMedia:
        return '📰';
      case SubscriptionCategory.foodDelivery:
        return '🍔';
      case SubscriptionCategory.shopping:
        return '🛒';
      case SubscriptionCategory.finance:
        return '💰';
      case SubscriptionCategory.education:
        return '📚';
      case SubscriptionCategory.utilities:
        return '🔌';
      case SubscriptionCategory.other:
        return '📦';
    }
  }
}

