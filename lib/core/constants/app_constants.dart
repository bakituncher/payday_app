/// Core constants used throughout the app
class AppConstants {
  // App Info
  static const String appName = 'Payday';
  static const String appVersion = '1.0.0';

  // Supported Markets
  static const String marketUS = 'US';
  static const String marketAU = 'AU';

  // Default Currency
  static const String defaultCurrency = 'USD';

  // Popular Currencies (for quick selection)
  static const List<String> popularCurrencies = [
    'USD', // US Dollar
    'EUR', // Euro
    'GBP', // British Pound
    'JPY', // Japanese Yen
    'AUD', // Australian Dollar
    'CAD', // Canadian Dollar
    'CHF', // Swiss Franc
    'CNY', // Chinese Yuan
    'TRY', // Turkish Lira
    'INR', // Indian Rupee
  ];

  // Pay Cycles
  static const String payCycleWeekly = 'Weekly';
  static const String payCycleBiWeekly = 'Bi-Weekly';
  static const String payCycleFortnightly = 'Fortnightly';
  static const String payCycleMonthly = 'Monthly';

  // Pay Cycle Options for UI
  static const List<String> payCycleOptions = [
    payCycleWeekly,
    payCycleBiWeekly,
    payCycleMonthly,
  ];

  // Pay Cycle Days
  static const Map<String, int> payCycleDays = {
    payCycleWeekly: 7,
    payCycleBiWeekly: 14,
    payCycleFortnightly: 14,
    payCycleMonthly: 30, // Approximate, will calculate actual
  };

  // Savings Category ID (constant for system use)
  static const String savingsCategoryId = 'savings';

  // Transaction Categories
  static const List<Map<String, String>> transactionCategories = [
    {'name': 'Food & Dining', 'emoji': '🍔', 'id': 'food'},
    {'name': 'Transportation', 'emoji': '🚗', 'id': 'transport'},
    {'name': 'Shopping', 'emoji': '🛍️', 'id': 'shopping'},
    {'name': 'Entertainment', 'emoji': '🎬', 'id': 'entertainment'},
    {'name': 'Bills & Utilities', 'emoji': '📱', 'id': 'bills'},
    {'name': 'Health & Fitness', 'emoji': '💪', 'id': 'health'},
    {'name': 'Groceries', 'emoji': '🛒', 'id': 'groceries'},
    {'name': 'Coffee & Drinks', 'emoji': '☕', 'id': 'coffee'},
    {'name': 'Personal Care', 'emoji': '💄', 'id': 'personal'},
    {'name': 'Savings Transfer', 'emoji': '💰', 'id': 'savings'}, // System category for savings
    {'name': 'Other', 'emoji': '📌', 'id': 'other'},
  ];

  // Shared Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserId = 'user_id';
  static const String keyUserCurrency = 'user_currency';
  static const String keyUserPayCycle = 'user_pay_cycle';
  static const String keyNextPayday = 'next_payday';
  static const String keyIncomeAmount = 'income_amount';

  // Animation Settings
  static const Duration countdownUpdateInterval = Duration(seconds: 1);
  static const Duration liquidAnimationDuration = Duration(milliseconds: 800);

  // UI Limits
  static const int maxSavingsGoals = 10;
  static const int maxTransactionNameLength = 50;
  static const double maxTransactionAmount = 999999.99;
}

