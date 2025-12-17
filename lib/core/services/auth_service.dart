/// Authentication Service
/// Handles Google and Apple Sign In
import 'dart:io'; // Platform kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      if (Platform.isAndroid) {
        // --- ANDROID İÇİN ÇÖZÜM (Firebase Provider Kullan) ---
        // Bu yöntem, "Missing initial state" hatasını %100 çözer.
        // Çünkü akışı Firebase başlatır ve bitirir.
        final provider = AppleAuthProvider();
        provider.addScope('email');
        provider.addScope('name');

        // Bu satır Android'de otomatik olarak tarayıcıyı açar,
        // Service ID'ni kullanır ve hatasız giriş yapar.
        return await _auth.signInWithProvider(provider);
      } else {
        // --- iOS İÇİN NATIVE YÖNTEM (Mevcut Çalışan Yöntem) ---
        // Request credential for the currently signed in Apple account
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          // iOS'te web options'a gerek yok
        );

        // Create an OAuth credential
        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        // Sign in to Firebase with the Apple credential
        final userCredential = await _auth.signInWithCredential(oauthCredential);

        // Update display name if it's the first sign in and we have the name
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          final fullName = appleCredential.givenName != null && appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : null;

          if (fullName != null) {
            await userCredential.user?.updateDisplayName(fullName);
          }
        }

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
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

