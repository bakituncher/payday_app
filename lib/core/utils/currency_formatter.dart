/// Utility functions for formatting currency
import 'package:intl/intl.dart';
import 'package:payday/core/services/currency_service.dart';

class CurrencyFormatter {
  /// Format amount with currency symbol
  static String format(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: _getDecimalDigits(currencyCode),
    );
    return formatter.format(amount);
  }

  /// Format amount with compact notation (e.g., 1.2K, 3.4M)
  static String formatCompact(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);

    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }

    return format(amount, currencyCode);
  }

  /// Format amount without currency symbol
  static String formatWithoutSymbol(double amount, {int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
    );
    return formatter.format(amount).trim();
  }

  /// Get currency symbol from code using currency_picker
  static String _getCurrencySymbol(String currencyCode) {
    final currencyService = CurrencyUtilityService();
    return currencyService.getSymbol(currencyCode);
  }

  /// Get decimal digits for currency (some currencies don't use decimals)
  static int _getDecimalDigits(String currencyCode) {
    // Currencies that don't use decimal places
    const noDecimalCurrencies = [
      'JPY', // Japanese Yen
      'KRW', // South Korean Won
      'VND', // Vietnamese Dong
      'CLP', // Chilean Peso
      'ISK', // Icelandic Króna
      'HUF', // Hungarian Forint
      'TWD', // New Taiwan Dollar
      'PYG', // Paraguayan Guaraní
    ];

    return noDecimalCurrencies.contains(currencyCode.toUpperCase()) ? 0 : 2;
  }

  /// Get currency symbol publicly
  static String getSymbol(String currencyCode) {
    return _getCurrencySymbol(currencyCode);
  }

  /// Get currency name
  static String getName(String currencyCode) {
    final currencyService = CurrencyUtilityService();
    return currencyService.getName(currencyCode);
  }

  /// Get currency flag
  static String getFlag(String currencyCode) {
    final currencyService = CurrencyUtilityService();
    return currencyService.getFlag(currencyCode);
  }

  /// Parse currency string to double
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Format with thousand separators
  static String formatWithSeparators(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    final decimals = _getDecimalDigits(currencyCode);

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
      locale: 'en_US', // Use US locale for consistent thousand separators
    );

    return formatter.format(amount);
  }
}

