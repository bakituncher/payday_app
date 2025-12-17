import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/utils/currency_formatter.dart';
// userSettingsProvider'ın bulunduğu dosyayı import etmelisin
import 'package:payday/features/home/providers/home_providers.dart';

/// Kullanıcının ayarlarındaki para birimi kodu (Yoksa cihazdan otomatik al)
final currencyCodeProvider = Provider<String>((ref) {
  // .watch(userSettingsProvider) kullanımı doğrudur ancak
  // bu provider'ın AsyncValue döndürdüğünden emin olmalısın
  final settings = ref.watch(userSettingsProvider).asData?.value;
  return settings?.currency ?? CurrencyFormatter.getLocalCurrencyCode();
});

/// Aktif sembol (₺, $, €)
final currencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(currencyCodeProvider);
  return CurrencyFormatter.getSymbol(code);
});