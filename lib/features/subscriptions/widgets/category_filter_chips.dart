/// Category Filter Chips Widget
/// Horizontal scrolling filter for subscription categories
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedCategoryFilterProvider.notifier).state = category;
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.pinkGradient : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                          : AppColors.subtleGray.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? AppColors.darkBorder.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.25),
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
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                    ] else ...[
                      Icon(
                        Icons.apps_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      category == null ? 'All' : _getCategoryName(category),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.getTextPrimary(context),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: isSelected ? 0.2 : 0,
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

