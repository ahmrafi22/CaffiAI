import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import 'firebase_service.dart';

class UserProfileService {
  // Use centralized Firebase service
  final _fb = firebase;

  Future<void> createUserDocIfMissing() async {
    final user = _fb.currentUser;
    if (user == null) return;

    final docRef = _fb.usersCollection.doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'preferences': <String, dynamic>{},
        'rewardPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await docRef.set({
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile() {
    final user = _fb.currentUser;
    if (user == null) {
      return const Stream<UserProfile?>.empty();
    }

    return _fb.usersCollection.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromDoc(doc);
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final user = _fb.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'You must be logged in to update your profile.',
      );
    }

    final docRef = _fb.usersCollection.doc(user.uid);
    Map<String, dynamic> data = {
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Merge preferences with existing ones if updating preferences
    if (preferences != null) {
      final currentDoc = await docRef.get();
      final currentData = currentDoc.data();
      final existingPreferences =
          (currentData?['preferences'] as Map<String, dynamic>?) ?? {};
      existingPreferences.addAll(preferences);
      data['preferences'] = existingPreferences;
    }

    if (data.keys.length == 1) return; // only updatedAt would be set

    await docRef.set(data, SetOptions(merge: true));
  }
}
