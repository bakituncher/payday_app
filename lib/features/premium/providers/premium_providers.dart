/// Premium/RevenueCat Feature Providers
/// Manages app monetization and PRO status
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:payday/core/services/revenue_cat_service.dart';

// ✅ SADECE REVENUECAT PROVIDERLARI

/// RevenueCat Servis Provider'ı
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Kullanıcının Premium olup olmadığını tutan State
/// App genelinde "isPremium" kontrolü bununla yapılır.
final isPremiumProvider = StateProvider<bool>((ref) => false);

/// Satın alınabilir paketleri (Monthly/Yearly) getiren Provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});