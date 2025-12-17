/// Currency Providers - Centralized currency management
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';

/// Provider for current user's currency code
final currentCurrencyCodeProvider = FutureProvider<String>((ref) async {
  final settings = await ref.watch(userSettingsProvider.future);
  return settings?.currency ?? CurrencyFormatter.getLocalCurrencyCode();
});

/// Provider for current user's currency symbol
final currentCurrencySymbolProvider = FutureProvider<String>((ref) async {
  final currencyCode = await ref.watch(currentCurrencyCodeProvider.future);
  return CurrencyFormatter.getSymbol(currencyCode);
});

/// Synchronous provider for currency code (for when settings are already loaded)
final syncCurrencyCodeProvider = Provider<String>((ref) {
  final settings = ref.watch(userSettingsProvider).asData?.value;
  return settings?.currency ?? 'USD';
});

/// Synchronous provider for currency symbol (for when settings are already loaded)
final syncCurrencySymbolProvider = Provider<String>((ref) {
  final currencyCode = ref.watch(syncCurrencyCodeProvider);
  return CurrencyFormatter.getSymbol(currencyCode);
});

/// Format amount with current user's currency
String formatWithUserCurrency(WidgetRef ref, double amount) {
  final currencyCode = ref.read(syncCurrencyCodeProvider);
  return CurrencyFormatter.format(amount, currencyCode);
}

/// Get user's currency symbol synchronously
String getUserCurrencySymbol(WidgetRef ref) {
  return ref.read(syncCurrencySymbolProvider);
}

