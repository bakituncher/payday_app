/// Firebase implementation of UserSettingsRepository
/// Data is stored in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payday/core/models/user_settings.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';

class FirebaseUserSettingsRepository implements UserSettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _getDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  @override
  Future<UserSettings?> getUserSettings(String userId) async {
    final doc = await _getDoc(userId).get();

    if (doc.exists && doc.data() != null) {
      return UserSettings.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    // Merge true to avoid overwriting other fields if they exist (though UserSettings usually owns the doc)
    await _getDoc(settings.userId).set(settings.toJson(), SetOptions(merge: true));
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    // Requires authenticated user
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user != null) {
      final settings = await getUserSettings(user.uid);
      return settings != null;
    }
    return false;
  }

  // Custom method to help with the interface limitation
  Future<bool> hasCompletedOnboardingForUser(String userId) async {
     final settings = await getUserSettings(userId);
     return settings != null;
  }
}
