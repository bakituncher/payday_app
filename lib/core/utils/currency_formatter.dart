/// Utility functions for formatting currency
import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format amount with currency symbol
  static String format(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format amount without currency symbol
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(amount).trim();
  }

  /// Get currency symbol from code
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'AUD':
        return 'A\$';
      default:
        return '\$';
    }
  }

  /// Parse currency string to double
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}

