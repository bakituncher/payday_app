/// Currency Service
/// Provides currency-related utilities using currency_picker package
import 'package:currency_picker/currency_picker.dart';

class CurrencyUtilityService {
  static final CurrencyUtilityService _instance = CurrencyUtilityService._internal();
  factory CurrencyUtilityService() => _instance;
  CurrencyUtilityService._internal();

  /// Get currency by code
  Currency? getCurrencyByCode(String code) {
    try {
      // Use the getCurrencyByIsoCode method from currency_picker
      final allCurrencies = CurrencyService().getAll();
      return allCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Currency not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol
  String getSymbol(String code) {
    // Önce özel sembol mapping'ini kontrol et
    final customSymbol = _getCustomSymbol(code);
    if (customSymbol != null) {
      return customSymbol;
    }

    final currency = getCurrencyByCode(code);
    return currency?.symbol ?? '\$';
  }

  /// Para birimleri için özel semboller
  /// currency_picker paketi bazı para birimleri için eski/yanlış semboller döndürüyor
  /// Bu fonksiyon doğru sembolleri sağlar
  String? _getCustomSymbol(String code) {
    final customSymbols = {
      'TRY': '₺', // Turkish Lira - currency_picker "TL" döndürüyor
      'GBP': '£', // British Pound
      'EUR': '€', // Euro
      'USD': '\$', // US Dollar
      'JPY': '¥', // Japanese Yen
      'CNY': '¥', // Chinese Yuan
      'RUB': '₽', // Russian Ruble
      'INR': '₹', // Indian Rupee
      'KRW': '₩', // South Korean Won
      'BRL': 'R\$', // Brazilian Real
      'ZAR': 'R', // South African Rand
      'PLN': 'zł', // Polish Zloty
      'THB': '฿', // Thai Baht
      'IDR': 'Rp', // Indonesian Rupiah
      'MYR': 'RM', // Malaysian Ringgit
      'PHP': '₱', // Philippine Peso
      'VND': '₫', // Vietnamese Dong
      'SEK': 'kr', // Swedish Krona
      'NOK': 'kr', // Norwegian Krone
      'DKK': 'kr', // Danish Krone
      'CHF': 'CHF', // Swiss Franc
      'AUD': 'A\$', // Australian Dollar
      'CAD': 'C\$', // Canadian Dollar
      'NZD': 'NZ\$', // New Zealand Dollar
      'SGD': 'S\$', // Singapore Dollar
      'HKD': 'HK\$', // Hong Kong Dollar
    };

    return customSymbols[code.toUpperCase()];
  }

  /// Get currency name
  String getName(String code) {
    final currency = getCurrencyByCode(code);
    return currency?.name ?? 'Unknown Currency';
  }

  /// Get currency flag
  String getFlag(String code) {
    final currency = getCurrencyByCode(code);
    return currency?.flag ?? '🌍';
  }

  /// Format amount with currency
  String formatAmount(double amount, String currencyCode, {int? decimals}) {
    final symbol = getSymbol(currencyCode);
    final decimalPlaces = decimals ?? _getDefaultDecimals(currencyCode);
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);

    // For some currencies, symbol comes after the amount
    if (_symbolComesAfter(currencyCode)) {
      return '$formattedAmount $symbol';
    }

    return '$symbol$formattedAmount';
  }

  /// Format amount with currency and thousand separators
  String formatAmountWithSeparators(
    double amount,
    String currencyCode,
    {int? decimals}
  ) {
    final symbol = getSymbol(currencyCode);
    final decimalPlaces = decimals ?? _getDefaultDecimals(currencyCode);

    // Split into integer and decimal parts
    final parts = amount.toStringAsFixed(decimalPlaces).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger = ',$formattedInteger';
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    final formattedAmount = decimalPlaces > 0
        ? '$formattedInteger.$decimalPart'
        : formattedInteger;

    // For some currencies, symbol comes after the amount
    if (_symbolComesAfter(currencyCode)) {
      return '$formattedAmount $symbol';
    }

    return '$symbol$formattedAmount';
  }

  /// Get default decimal places for currency
  int _getDefaultDecimals(String code) {
    // Currencies that don't use decimal places
    const noDecimalCurrencies = [
      'JPY', 'KRW', 'VND', 'CLP', 'ISK', 'HUF', 'TWD', 'PYG'
    ];

    return noDecimalCurrencies.contains(code.toUpperCase()) ? 0 : 2;
  }

  /// Check if currency symbol comes after the amount
  bool _symbolComesAfter(String code) {
    // Currencies where symbol typically comes after the amount
    const symbolAfterCurrencies = [
      'TRY', 'PLN', 'CZK', 'SEK', 'NOK', 'DKK',
      'HUF', 'RON', 'BGN', 'HRK', 'RUB', 'UAH',
    ];

    return symbolAfterCurrencies.contains(code.toUpperCase());
  }

  /// Find currency by code
  Currency? findByCode(String code) {
    return getCurrencyByCode(code);
  }
}

