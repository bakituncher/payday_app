/// Utility functions for formatting currency
import 'dart:ui' as ui;
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

  /// Get currency symbol from code
  /// Supports all world currencies automatically via Intl package
  static String _getCurrencySymbol(String currencyCode) {
    try {
      // Intl kütüphanesi otomatik olarak tüm dünya para birimlerini destekler
      final format = NumberFormat.simpleCurrency(name: currencyCode);
      return format.currencySymbol;
    } catch (e) {
      // Eğer para birimi bulunamazsa varsayılan olarak kod kendisini döner
      return currencyCode;
    }
  }

  /// Get currency symbol publicly
  static String getSymbol(String currencyCode) {
    return _getCurrencySymbol(currencyCode);
  }

  /// Get local currency code from device locale
  static String getLocalCurrencyCode() {
    // Cihazın mevcut yerel ayarını alır (örn: tr_TR, en_US)
    final String locale = ui.PlatformDispatcher.instance.locale.toString();
    final format = NumberFormat.simpleCurrency(locale: locale);
    return format.currencyName ?? 'USD'; // Varsayılan olarak USD döner
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

