/// Authentication Service
/// Handles Google and Apple Sign In
import 'dart:io'; // Platform kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:payday/core/services/revenue_cat_service.dart'; // ✅ Import Eklendi

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RevenueCatService _revenueCatService = RevenueCatService(); // ✅ Instance

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if current user is anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in Anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      // ✅ Anonim kullanıcı ID'si ile RevenueCat'e giriş yap
      if (cred.user != null) {
        await _revenueCatService.logIn(cred.user!.uid);
      }
      return cred;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // Sign in with Google (or Link if anonymous)
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

      UserCredential userCredential;

      // Check if we are anonymous and link instead
      if (currentUser != null && currentUser!.isAnonymous) {
        try {
          userCredential = await currentUser!.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
             // If account exists, we can't link.
             // Logic: Sign in with the existing account?
             // Or throw error?
             // For now, let's try to sign in normally, effectively switching users.
             // Note: This will NOT migrate data if not handled before switching.
             // But usually "credential-already-in-use" means they have another account.
             // The prompt implies "anonymous login should turn into google login", which implies creating/linking.
             // If it exists, we just switch.
             userCredential = await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        // Sign in to Firebase with the Google credential
        userCredential = await _auth.signInWithCredential(credential);
      }

      // ✅ KRİTİK: Giriş başarılıysa RevenueCat'e Firebase UID'sini bildir
      if (userCredential.user != null) {
        await _revenueCatService.logIn(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple (or Link if anonymous)
  Future<UserCredential?> signInWithApple() async {
    try {
      UserCredential userCredential;

      if (Platform.isAndroid) {
        // --- ANDROID İÇİN ÇÖZÜM (Firebase Provider Kullan) ---
        final provider = AppleAuthProvider();
        provider.addScope('email');
        provider.addScope('name');

        if (currentUser != null && currentUser!.isAnonymous) {
           try {
             userCredential = await currentUser!.linkWithProvider(provider);
           } on FirebaseAuthException catch (e) {
             if (e.code == 'credential-already-in-use') {
               userCredential = await _auth.signInWithProvider(provider);
             } else {
               rethrow;
             }
           }
        } else {
           userCredential = await _auth.signInWithProvider(provider);
        }
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

        if (currentUser != null && currentUser!.isAnonymous) {
          try {
            userCredential = await currentUser!.linkWithCredential(oauthCredential);
             // Update display name if linked
             if (appleCredential.givenName != null) {
                final fullName = '${appleCredential.givenName} ${appleCredential.familyName}';
                await userCredential.user?.updateDisplayName(fullName);
             }
          } on FirebaseAuthException catch (e) {
             if (e.code == 'credential-already-in-use') {
               userCredential = await _auth.signInWithCredential(oauthCredential);
             } else {
               rethrow;
             }
          }
        } else {
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
      }

      // ✅ KRİTİK: Giriş başarılıysa RevenueCat'e Firebase UID'sini bildir
      if (userCredential.user != null) {
        await _revenueCatService.logIn(userCredential.user!.uid);
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

