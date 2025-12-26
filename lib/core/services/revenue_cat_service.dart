import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class RevenueCatService {
  // RevenueCat API Keys (.env dosyasından okunur)
  static String get _apiKeyAndroid =>
      dotenv.env['REVENUECAT_ANDROID_API_KEY'] ?? '';
  static String get _apiKeyIOS =>
      dotenv.env['REVENUECAT_IOS_API_KEY'] ?? '';

  // Ürün ID'leri (RevenueCat Dashboard'daki Product IDs)
  static String get monthlyProductId =>
      dotenv.env['REVENUECAT_MONTHLY_PRODUCT_ID'] ?? 'premium-monthly';
  static String get annualProductId =>
      dotenv.env['REVENUECAT_ANNUAL_PRODUCT_ID'] ?? 'premium-annual';

  // Entitlement ID
  static String get premiumEntitlementId =>
      dotenv.env['REVENUECAT_PREMIUM_ENTITLEMENT_ID'] ?? 'premium';

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

  /// ✅ YENİ: Kullanıcı giriş yaptığında RevenueCat'e bildir
  /// Bu sayede satın alımlar cihazlar arasında senkronize olur.
  Future<void> logIn(String appUserId) async {
    try {
      await Purchases.logIn(appUserId);
      print("✅ RevenueCat Login Success: $appUserId");
    } catch (e) {
      print("❌ RevenueCat Login Error: $e");
    }
  }

  /// ✅ YENİ: Kullanıcı çıkış yaptığında RevenueCat'i sıfırla
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      print("✅ RevenueCat Logout Success");
    } catch (e) {
      print("❌ RevenueCat Logout Error: $e");
    }
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
      return customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Subscription yönetim ekranını açar (iOS & Android)
  Future<void> showManagementUI() async {
    try {
      if (Platform.isIOS) {
        // iOS için App Store subscription management
        final url = Uri.parse('https://apps.apple.com/account/subscriptions');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not open subscription management');
        }
      } else if (Platform.isAndroid) {
        // Android için Play Store subscription management
        final customerInfo = await Purchases.getCustomerInfo();
        final managementUrl = customerInfo.managementURL;

        if (managementUrl != null) {
          final url = Uri.parse(managementUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not open subscription management');
          }
        } else {
          // Fallback: Genel Play Store subscriptions sayfası
          final url = Uri.parse('https://play.google.com/store/account/subscriptions');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not open subscription management');
          }
        }
      }
    } catch (e) {
      print('RC Management UI Error: $e');
      throw e;
    }
  }
}