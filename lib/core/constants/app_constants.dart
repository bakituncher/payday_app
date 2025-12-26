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
  static const String payCycleSemiMonthly = 'Semi-Monthly';
  static const String payCycleMonthly = 'Monthly';

  // Pay Cycle Options for UI
  static const List<String> payCycleOptions = [
    payCycleWeekly,
    payCycleBiWeekly,
    payCycleSemiMonthly,
    payCycleMonthly,
  ];

  // Pay Cycle Days
  static const Map<String, int> payCycleDays = {
    payCycleWeekly: 7,
    payCycleBiWeekly: 14,
    payCycleFortnightly: 14,
    payCycleSemiMonthly: 15, // Approximate, twice per month
    payCycleMonthly: 30, // Approximate, will calculate actual
  };

  // Savings Category ID (constant for system use)
  static const String savingsCategoryId = 'savings';

  // Transaction Categories (Expenses)
  // ⚠️ CRITICAL: The 'savings' category must be filtered out in UI screens
  // to prevent "ghost transactions" where money disappears from budget
  // without being added to any savings goal. See AddTransactionScreen.dart
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
    {'name': 'Savings Transfer', 'emoji': '💰', 'id': 'savings'}, // 🔒 SYSTEM ONLY - Never show in user-facing category selectors
    {'name': 'Other', 'emoji': '📌', 'id': 'other'},
  ];

  // Income Categories (Pool Inflows)
  // Used for manual Add Funds and automatic Payday Deposits
  static const List<Map<String, String>> incomeCategories = [
    {'name': 'Payday Deposit', 'emoji': '💵', 'id': 'income_salary'}, // 🔒 SYSTEM - Auto-deposit on payday
    {'name': 'Bonus', 'emoji': '🎁', 'id': 'bonus'},
    {'name': 'Gift', 'emoji': '����', 'id': 'gift'},
    {'name': 'Freelance', 'emoji': '💻', 'id': 'freelance'},
    {'name': 'Side Hustle', 'emoji': '🚀', 'id': 'side_hustle'},
    {'name': 'Sold Item', 'emoji': '🏷️', 'id': 'sold_item'},
    {'name': 'Refund', 'emoji': '💸', 'id': 'refund'},
    {'name': 'Investment', 'emoji': '📈', 'id': 'investment'},
    {'name': 'Other Income', 'emoji': '💰', 'id': 'other_income'},
  ];

  // Payday Deposit Category ID (constant for system use)
  static const String paydayDepositCategoryId = 'income_salary';

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

