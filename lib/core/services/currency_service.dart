import 'package:currency_picker/currency_picker.dart';
import 'package:payday/core/utils/currency_formatter.dart';

class CurrencyUtilityService {
  static final CurrencyUtilityService _instance = CurrencyUtilityService._internal();
  factory CurrencyUtilityService() => _instance;
  CurrencyUtilityService._internal();

  /// Get currency by code
  Currency? getCurrencyByCode(String code) {
    try {
      final allCurrencies = CurrencyService().getAll();
      return allCurrencies.firstWhere(
            (c) => c.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Currency not found'),
      );
    } catch (e) {
      return null;
    }
  }

  String getSymbol(String code) {
    return CurrencyFormatter.getSymbol(code);
  }

  String getName(String code) {
    final currency = getCurrencyByCode(code);
    return currency?.name ?? 'Unknown Currency';
  }

  String getFlag(String code) {
    final currency = getCurrencyByCode(code);
    return currency?.flag ?? '🌍';
  }

  /// ARTIK MERKEZİ FORMATTER KULLANIYOR
  String formatAmount(double amount, String currencyCode, {int? decimals}) {
    // decimals parametresi CurrencyFormatter'da otomatik yönetiliyor ama
    // override edilmesi gerekirse burada özel mantık eklenebilir.
    // Tutarlılık için varsayılanı kullanıyoruz.
    return CurrencyFormatter.format(amount, currencyCode);
  }

  /// ARTIK MERKEZİ FORMATTER KULLANIYOR
  String formatAmountWithSeparators(
      double amount,
      String currencyCode,
      {int? decimals}
      ) {
    return CurrencyFormatter.format(amount, currencyCode);
  }

  Currency? findByCode(String code) {
    return getCurrencyByCode(code);
  }
}