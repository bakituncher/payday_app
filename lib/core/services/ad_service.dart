import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Singleton
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Interstitial Cache
  final Map<int, InterstitialAd?> _interstitials = <int, InterstitialAd?>{};
  final Map<int, int> _loadAttempts = <int, int>{};
  final int maxFailedLoadAttempts = 3;

  // --- Banner IDs ---
  String get homeBannerId => _getAdId('ADMOB_BANNER_HOME_ID');
  String get insightsBannerId => _getAdId('ADMOB_BANNER_INSIGHTS_ID');
  String get subscriptionsBannerId => _getAdId('ADMOB_BANNER_SUBSCRIPTIONS_ID');
  String get savingsBannerId => _getAdId('ADMOB_BANNER_SAVINGS_ID');

  /// Geri uyumluluk: eski banner ID alanını koruyoruz.
  /// Yeni ekranlarda lütfen `insightsBannerId/subscriptionsBannerId/savingsBannerId` kullann.
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_ANDROID_BANNER_ID'] ?? 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_IOS_BANNER_ID'] ?? 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // --- Interstitial Logic ---

  /// lgili ID grubu in reklam nden ykler.
  void loadInterstitial(int type) {
    final String adUnitId = _getInterstitialIdByType(type);

    // Zaten yklyse tekrar ykleme
    if (_interstitials[type] != null) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint(' Interstitial Ad $type loaded.');
          _interstitials[type] = ad;
          _loadAttempts[type] = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              debugPrint(' Interstitial Ad $type dismissed.');
              ad.dispose();
              _interstitials[type] = null;
              // Kapandktan sonra bir sonraki gsterim in hemen yenisini ykle
              loadInterstitial(type);
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              debugPrint(' Interstitial Ad $type failed to show: $error');
              ad.dispose();
              _interstitials[type] = null;
              loadInterstitial(type);
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(' Interstitial Ad $type failed to load: $error');
          _interstitials[type] = null;
          _loadAttempts[type] = (_loadAttempts[type] ?? 0) + 1;

          if ((_loadAttempts[type] ?? 0) <= maxFailedLoadAttempts) {
            loadInterstitial(type);
          }
        },
      ),
    );
  }

  /// Reklam gsterir.
  void showInterstitial(int type) {
    final ad = _interstitials[type];
    if (ad != null) {
      ad.show();
    } else {
      debugPrint(' Ad $type not ready yet. Loading for next time.');
      loadInterstitial(type);
    }
  }

  // --- Helpers ---

  String _getInterstitialIdByType(int type) {
    switch (type) {
      case 1:
        return _getAdId('ADMOB_INTERSTITIAL_1_ID', isInterstitial: true);
      case 2:
        return _getAdId('ADMOB_INTERSTITIAL_2_ID', isInterstitial: true);
      case 3:
        return _getAdId('ADMOB_INTERSTITIAL_3_ID', isInterstitial: true);
      case 4:
        return _getAdId('ADMOB_INTERSTITIAL_4_ID', isInterstitial: true);
      default:
        throw ArgumentError('Invalid interstitial type: $type');
    }
  }

  String _getAdId(String envKey, {bool isInterstitial = false}) {
    if (kDebugMode) {
      // Test ID'leri
      if (Platform.isAndroid) {
        return isInterstitial
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return isInterstitial
            ? 'ca-app-pub-3940256099942544/4411468910'
            : 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    // Production ID'leri Env'den ek
    return dotenv.env[envKey] ?? '';
  }
}