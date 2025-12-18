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

  // Get current user's document reference
  DocumentReference<Map<String, dynamic>>? get currentUserDoc {
    final uid = currentUid;
    if (uid == null) return null;
    return usersCollection.doc(uid);
  }
}

// Global shortcut for easy access
final firebase = FirebaseService.instance;
