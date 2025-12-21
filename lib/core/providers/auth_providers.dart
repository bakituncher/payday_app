/// Authentication Providers
/// Provides authentication service and user state
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Is Signed In Provider
final isSignedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.asData?.value != null;
});

// User Display Name Provider
final userDisplayNameProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.asData?.value?.displayName;
});

// User Email Provider
final userEmailProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.asData?.value?.email;
});

// User Photo URL Provider
final userPhotoUrlProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.asData?.value?.photoURL;
});

// Anonymous state helper
final isAnonymousUserProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  return user != null && user.isAnonymous;
});

// Fully authenticated (non-anonymous) helper
final isFullyAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  return user != null && !user.isAnonymous;
});
