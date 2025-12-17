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
    final currency = getCurrencyByCode(code);
    return currency?.symbol ?? '\$';
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
    final currency = getCurrencyByCode(currencyCode);
    final symbol = currency?.symbol ?? '\$';
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
    final currency = getCurrencyByCode(currencyCode);
    final symbol = currency?.symbol ?? '\$';
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

