import 'package:intl/intl.dart';
import 'package:payday/core/services/locale_currency_service.dart';

class CurrencyFormatter {
  /// Cihazın konumundan/dilinden otomatik para birimi kodunu alır (örn: TRY, USD)
  /// Tüm dünya ülkeleri için locale-based currency detection
  static String getLocalCurrencyCode() {
    try {
      // Use comprehensive locale-to-currency mapping service
      final localeCurrencyService = LocaleCurrencyService();
      return localeCurrencyService.detectCurrency();
    } catch (e) {
      return 'USD'; // Fallback
    }
  }

  /// Para birimi koduna göre sembolü getirir (örn: TRY -> ₺, USD -> $)
  static String getSymbol(String currencyCode) {
    // Önce özel sembol mapping'ini kontrol et
    final customSymbol = _getCustomSymbol(currencyCode);
    if (customSymbol != null) {
      return customSymbol;
    }

    try {
      final format = NumberFormat.simpleCurrency(name: currencyCode);
      return format.currencySymbol;
    } catch (_) {
      return currencyCode; // Hata durumunda kodu döndür (örn: USD)
    }
  }

  /// Para birimleri için özel semboller
  /// intl paketi bazı para birimleri için locale'e bağlı olarak farklı semboller döndürebilir
  /// Bu fonksiyon her zaman doğru sembolleri sağlar
  static String? _getCustomSymbol(String code) {
    final customSymbols = {
      'TRY': '₺', // Turkish Lira - intl bazen "TL" döndürebilir
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