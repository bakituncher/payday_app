import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // RevenueCat Panelinden alacağın API Keyler
  static const _apiKeyAndroid = 'goog_...'; // Android Key buraya
  static const _apiKeyIOS = 'appl_...'; // iOS Key buraya

  /// Singleton instance (Opsiyonel ama servisi tek tutmak iyidir)
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug); // Canlıya çıkarken WARN yapabilirsin

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    } else {
      return;
    }

    await Purchases.configure(configuration);
  }

  /// Mevcut paketleri (Monthly, Yearly) getirir
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } on PlatformException catch (e) {
      // Loglama servisine hata gönderilebilir (Crashlytics vb.)
      print('RC Offerings Error: ${e.message}');
      return null;
    }
  }

  /// Satın alma işlemi
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // Kullanıcı vazgeçti, hata fırlatmaya gerek yok
        return null;
      }
      throw e; // Diğer hataları UI'da göstermek için fırlat
    }
  }

  /// Restore işlemi
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } on PlatformException catch (e) {
      print('RC Restore Error: ${e.message}');
      throw e;
    }
  }

  /// Anlık Premium kontrolü (Entitlement ID: 'premium')
  Future<bool> getPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }
}