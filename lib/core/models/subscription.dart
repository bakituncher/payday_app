/// Subscription model for tracking recurring payments
/// Industry-grade implementation with Firebase support
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Frequency enum for recurring payments
enum RecurrenceFrequency {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('biweekly')
  biweekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

/// Subscription category for better organization
enum SubscriptionCategory {
  @JsonValue('streaming')
  streaming, // Netflix, Disney+, Spotify
  @JsonValue('productivity')
  productivity, // Microsoft 365, Adobe CC
  @JsonValue('cloud_storage')
  cloudStorage, // iCloud, Google Drive, Dropbox
  @JsonValue('fitness')
  fitness, // Gym, Peloton, Fitness apps
  @JsonValue('gaming')
  gaming, // Xbox Game Pass, PS Plus
  @JsonValue('news_media')
  newsMedia, // NYT, WSJ, Medium
  @JsonValue('food_delivery')
  foodDelivery, // DoorDash, UberEats pass
  @JsonValue('shopping')
  shopping, // Amazon Prime, Costco
  @JsonValue('finance')
  finance, // Premium banking, Investment apps
  @JsonValue('education')
  education, // Coursera, Skillshare
  @JsonValue('utilities')
  utilities, // Internet, Phone, Insurance
  @JsonValue('other')
  other,
}

/// Status of a subscription
enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('trial')
  trial,
}

@freezed
class Subscription with _$Subscription {
  const Subscription._();

  const factory Subscription({
    required String id,
    required String userId,
    required String name,
    required double amount,
    required String currency,
    required RecurrenceFrequency frequency,
    required SubscriptionCategory category,
    required DateTime nextBillingDate,
    @Default('') String description,
    @Default('') String logoUrl,
    @Default('💳') String emoji,
    @Default(SubscriptionStatus.active) SubscriptionStatus status,
    @Default(true) bool reminderEnabled,
    @Default(2) int reminderDaysBefore,
    DateTime? startDate,
    DateTime? cancelledAt,
    DateTime? trialEndsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  /// Calculate monthly cost for comparison
  double get monthlyCost {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return amount * 30;
      case RecurrenceFrequency.weekly:
        return amount * 4.33;
      case RecurrenceFrequency.biweekly:
        return amount * 2.17;
      case RecurrenceFrequency.monthly:
        return amount;
      case RecurrenceFrequency.quarterly:
        return amount / 3;
      case RecurrenceFrequency.yearly:
        return amount / 12;
    }
  }

  /// Calculate yearly cost
  double get yearlyCost {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return amount * 365;
      case RecurrenceFrequency.weekly:
        return amount * 52;
      case RecurrenceFrequency.biweekly:
        return amount * 26;
      case RecurrenceFrequency.monthly:
        return amount * 12;
      case RecurrenceFrequency.quarterly:
        return amount * 4;
      case RecurrenceFrequency.yearly:
        return amount;
    }
  }

  /// Check if payment is due soon (within specified days)
  bool isDueSoon(int days) {
    final now = DateTime.now();
    final dueDate = nextBillingDate;
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= days;
  }

  /// Check if in trial period
  bool get isInTrial {
    if (status != SubscriptionStatus.trial || trialEndsAt == null) return false;
    return DateTime.now().isBefore(trialEndsAt!);
  }

  /// Days until next billing
  int get daysUntilBilling {
    final now = DateTime.now();
    return nextBillingDate.difference(now).inDays;
  }

  /// Get display frequency text
  String get frequencyText {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.biweekly:
        return 'Every 2 weeks';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.quarterly:
        return 'Quarterly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  /// Get category emoji
  String get categoryEmoji {
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

/// Popular subscription templates for quick add
class SubscriptionTemplates {
  static List<Map<String, dynamic>> get templates => [
    // Streaming
    {'name': 'Netflix', 'category': SubscriptionCategory.streaming, 'emoji': '🎬', 'amount': 15.49},
    {'name': 'Spotify', 'category': SubscriptionCategory.streaming, 'emoji': '🎵', 'amount': 10.99},
    {'name': 'Disney+', 'category': SubscriptionCategory.streaming, 'emoji': '🏰', 'amount': 7.99},
    {'name': 'HBO Max', 'category': SubscriptionCategory.streaming, 'emoji': '📺', 'amount': 15.99},
    {'name': 'Apple Music', 'category': SubscriptionCategory.streaming, 'emoji': '🎧', 'amount': 10.99},
    {'name': 'YouTube Premium', 'category': SubscriptionCategory.streaming, 'emoji': '▶️', 'amount': 13.99},
    {'name': 'Amazon Prime Video', 'category': SubscriptionCategory.streaming, 'emoji': '📹', 'amount': 8.99},
    {'name': 'Hulu', 'category': SubscriptionCategory.streaming, 'emoji': '📺', 'amount': 17.99},

    // Cloud Storage
    {'name': 'iCloud', 'category': SubscriptionCategory.cloudStorage, 'emoji': '☁️', 'amount': 2.99},
    {'name': 'Google One', 'category': SubscriptionCategory.cloudStorage, 'emoji': '🌐', 'amount': 2.99},
    {'name': 'Dropbox', 'category': SubscriptionCategory.cloudStorage, 'emoji': '📦', 'amount': 11.99},
    {'name': 'OneDrive', 'category': SubscriptionCategory.cloudStorage, 'emoji': '☁️', 'amount': 1.99},

    // Productivity
    {'name': 'Microsoft 365', 'category': SubscriptionCategory.productivity, 'emoji': '💼', 'amount': 9.99},
    {'name': 'Adobe Creative Cloud', 'category': SubscriptionCategory.productivity, 'emoji': '🎨', 'amount': 54.99},
    {'name': 'Notion', 'category': SubscriptionCategory.productivity, 'emoji': '📝', 'amount': 8.00},
    {'name': 'Canva Pro', 'category': SubscriptionCategory.productivity, 'emoji': '🖼️', 'amount': 12.99},

    // Fitness
    {'name': 'Gym Membership', 'category': SubscriptionCategory.fitness, 'emoji': '💪', 'amount': 29.99},
    {'name': 'Peloton', 'category': SubscriptionCategory.fitness, 'emoji': '🚴', 'amount': 44.00},
    {'name': 'Apple Fitness+', 'category': SubscriptionCategory.fitness, 'emoji': '⌚', 'amount': 9.99},
    {'name': 'Strava', 'category': SubscriptionCategory.fitness, 'emoji': '🏃', 'amount': 5.00},

    // Gaming
    {'name': 'Xbox Game Pass', 'category': SubscriptionCategory.gaming, 'emoji': '🎮', 'amount': 14.99},
    {'name': 'PlayStation Plus', 'category': SubscriptionCategory.gaming, 'emoji': '🎯', 'amount': 17.99},
    {'name': 'Nintendo Switch Online', 'category': SubscriptionCategory.gaming, 'emoji': '🕹️', 'amount': 3.99},

    // Shopping
    {'name': 'Amazon Prime', 'category': SubscriptionCategory.shopping, 'emoji': '📦', 'amount': 14.99},
    {'name': 'Costco', 'category': SubscriptionCategory.shopping, 'emoji': '🛒', 'amount': 5.00},
    {'name': 'Walmart+', 'category': SubscriptionCategory.shopping, 'emoji': '🏪', 'amount': 12.95},

    // News & Media
    {'name': 'The New York Times', 'category': SubscriptionCategory.newsMedia, 'emoji': '📰', 'amount': 4.25},
    {'name': 'Medium', 'category': SubscriptionCategory.newsMedia, 'emoji': '✍️', 'amount': 5.00},
    {'name': 'The Wall Street Journal', 'category': SubscriptionCategory.newsMedia, 'emoji': '📊', 'amount': 12.99},

    // Education
    {'name': 'Coursera Plus', 'category': SubscriptionCategory.education, 'emoji': '🎓', 'amount': 59.00},
    {'name': 'Skillshare', 'category': SubscriptionCategory.education, 'emoji': '📚', 'amount': 13.99},
    {'name': 'LinkedIn Learning', 'category': SubscriptionCategory.education, 'emoji': '💼', 'amount': 29.99},
    {'name': 'Duolingo Plus', 'category': SubscriptionCategory.education, 'emoji': '🦉', 'amount': 6.99},
  ];
}

