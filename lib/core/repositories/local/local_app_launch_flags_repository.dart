import 'package:shared_preferences/shared_preferences.dart';

/// Stores simple app-launch flags locally (device-only).
///
/// This is intentionally separate from user settings (which can be synced to Firebase)
/// so we can mark marketing/intro screens as seen before a user signs in.
class LocalAppLaunchFlagsRepository {
  static const String _kFeatureIntroSeenKey = 'feature_intro_seen';

  Future<bool> hasSeenFeatureIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kFeatureIntroSeenKey) ?? false;
  }

  Future<void> setFeatureIntroSeen({required bool seen}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFeatureIntroSeenKey, seen);
  }
}

