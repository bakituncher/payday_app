import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  /// Platforma göre Banner Reklam Birimi ID'sini getirir
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_ANDROID_BANNER_ID'] ?? 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_IOS_BANNER_ID'] ?? 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}