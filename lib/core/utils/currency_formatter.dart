import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Cihazın konumundan/dilinden otomatik para birimi kodunu alır (örn: TRY, USD)
  static String getLocalCurrencyCode() {
    try {
      final String locale = ui.PlatformDispatcher.instance.locale.toString();
      final format = NumberFormat.simpleCurrency(locale: locale);
      return format.currencyName ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  /// Para birimi koduna göre sembolü getirir (örn: TRY -> ₺, USD -> $)
  static String getSymbol(String currencyCode) {
    try {
      final format = NumberFormat.simpleCurrency(name: currencyCode);
      return format.currencySymbol;
    } catch (_) {
      return currencyCode; // Hata durumunda kodu döndür (örn: USD)
    }
  }

  /// Miktarı formatlar: 1234.5 -> ₺1,234.50 veya 1.234,50 ₺
  /// Not: '₺' sembolünün başta mı sonda mı olacağını intl paketi dile göre otomatik ayarlar.
  static String format(double amount, String currencyCode) {
    // Para birimi koduna göre en uygun formatı oluşturur
    final formatter = NumberFormat.currency(
      symbol: getSymbol(currencyCode),
      decimalDigits: _getDecimalDigits(currencyCode),
    );
    return formatter.format(amount);
  }

  /// Bazı para birimleri (JPY gibi) kuruş/ondalık kullanmaz
  static int _getDecimalDigits(String currencyCode) {
    const noDecimalCurrencies = ['JPY', 'KRW', 'VND', 'CLP', 'ISK'];
    return noDecimalCurrencies.contains(currencyCode.toUpperCase()) ? 0 : 2;
  }
}