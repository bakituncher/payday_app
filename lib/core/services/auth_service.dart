/// Authentication Service
/// Handles Google and Apple Sign In with Guest Mode (no Firebase auth)
import 'dart:io'; // Platform kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:payday/core/services/revenue_cat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RevenueCatService _revenueCatService = RevenueCatService();

  static const String _guestModeKey = 'is_guest_mode';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if in guest mode (no Firebase auth)
  Future<bool> get isGuestMode async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  // Check if user is authenticated (not guest)
  Future<bool> get isAuthenticated async {
    return currentUser != null && !(await isGuestMode);
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Enter Guest Mode (no Firebase auth)
  Future<void> enterGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      print('✅ Entered guest mode');
    } catch (e) {
      print('Error entering guest mode: $e');
      rethrow;
    }
  }

  // Exit Guest Mode
  Future<void> exitGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);
      print('✅ Exited guest mode');
    } catch (e) {
      print('Error exiting guest mode: $e');
      rethrow;
    }
  }

  // Save FCM token and user metadata to Firestore
  Future<void> _saveUserMetadata(String userId) async {
    try {
      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Get timezone offset
      final int offsetHours = DateTime.now().timeZoneOffset.inHours;

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': fcmToken,
        'utcOffset': offsetHours,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ User metadata saved: FCM Token and UTC Offset ($offsetHours)');
    } catch (e) {
      print('Error saving user metadata: $e');
      // Don't rethrow - this shouldn't block the sign-in process
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // ✅ KRİTİK: Giriş başarılıysa RevenueCat'e Firebase UID'sini bildir
      if (userCredential.user != null) {
        await _revenueCatService.logIn(userCredential.user!.uid);
        // Exit guest mode if we were in it
        await exitGuestMode();
        // ✅ SORUN ÇÖZÜMÜ: FCM token ve lastLogin bilgilerini hemen kaydet
        await _saveUserMetadata(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      UserCredential userCredential;

      if (Platform.isAndroid) {
        // --- ANDROID İÇİN ÇÖZÜM (Firebase Provider Kullan) ---
        final provider = AppleAuthProvider();
        provider.addScope('email');
        provider.addScope('name');

        userCredential = await _auth.signInWithProvider(provider);
      } else {
        // --- iOS İÇİN NATIVE YÖNTEM ---
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        userCredential = await _auth.signInWithCredential(oauthCredential);

        if (userCredential.additionalUserInfo?.isNewUser == true) {
          final fullName = appleCredential.givenName != null && appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : null;

          if (fullName != null) {
            await userCredential.user?.updateDisplayName(fullName);
          }
        }
      }

      // ✅ KRİTİK: Giriş başarılıysa RevenueCat'e Firebase UID'sini bildir
      if (userCredential.user != null) {
        await _revenueCatService.logIn(userCredential.user!.uid);
        // Exit guest mode if we were in it
        await exitGuestMode();
        // ✅ SORUN ÇÖZÜMÜ: FCM token ve lastLogin bilgilerini hemen kaydet
        await _saveUserMetadata(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // ✅ Çıkış yaparken RevenueCat ID'sini de sıfırla
      await _revenueCatService.logOut();

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      // ✅ Enter guest mode after sign out
      await enterGuestMode();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // ✅ Hesap silinmeden önce RC oturumunu kapat
      await _revenueCatService.logOut();

      // Delete the user account
      await user.delete();

      // Sign out from Google Sign In if needed
      await _googleSignIn.signOut();

      // ✅ Enter guest mode after account deletion
      await enterGuestMode();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Check if Apple Sign In is available
  Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      print('Error checking Apple Sign In availability: $e');
      return false;
    }
  }
}

