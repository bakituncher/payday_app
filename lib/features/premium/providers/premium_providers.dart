import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:payday/core/services/revenue_cat_service.dart';

// ✅ MEVCUT KODLARINIZ
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

final isPremiumProvider = StateProvider<bool>((ref) => false);

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

// ✅ YENİ EKLENECEK KISIM: Durum Kontrol Fonksiyonu
// Bu fonksiyon çağrıldığında RevenueCat'e sorar ve provider'ı günceller.
Future<void> refreshPremiumStatus(WidgetRef ref) async {
  final service = ref.read(revenueCatServiceProvider);
  final isPremium = await service.getPremiumStatus();

  // State'i güncelle
  ref.read(isPremiumProvider.notifier).state = isPremium;
}