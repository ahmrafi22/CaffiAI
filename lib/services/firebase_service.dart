import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Firebase service - call instances once, use everywhere
class FirebaseService {
  // Private constructor for singleton
  FirebaseService._();

  // Singleton instance
  static final FirebaseService instance = FirebaseService._();

  // Firebase instances (initialized once)
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Convenient getters
  User? get currentUser => auth.currentUser;
  String? get currentUid => auth.currentUser?.uid;
  bool get isLoggedIn => auth.currentUser != null;

  // Users collection reference
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  // Cafes collection reference
  CollectionReference<Map<String, dynamic>> get cafesCollection =>
      firestore.collection('cafes');

  // Get current user's document reference
  DocumentReference<Map<String, dynamic>>? get currentUserDoc {
    final uid = currentUid;
    if (uid == null) return null;
    return usersCollection.doc(uid);
  }

  // Stream of all active cafes ordered by avgRating
  // Note: This query requires a composite index (isActive + avgRating)
  // The rules also filter for isActive, so you could remove the where clause
  // if you want to avoid needing the index
  Stream<QuerySnapshot<Map<String, dynamic>>> get cafesStream {
    return cafesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .snapshots();
  }

  // Get cafes as a future
  Future<QuerySnapshot<Map<String, dynamic>>> getCafes() {
    return cafesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .get();
  }
}

// Global shortcut for easy access
final firebase = FirebaseService.instance;
