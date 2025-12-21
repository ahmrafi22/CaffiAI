import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/cafe_model.dart';

class CafeService {
  CafeService._();
  static final CafeService instance = CafeService._();

  final CollectionReference<Map<String, dynamic>> _col =
      firebase.cafesCollection;

  /// Fetch a QuerySnapshot (useful to get lastDocument for pagination)
  Future<QuerySnapshot<Map<String, dynamic>>> fetchCafesSnapshot({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    Query<Map<String, dynamic>> q = _col.where('isActive', isEqualTo: true);
    // Order by avgRating descending for consistent results
    q = q.orderBy('avgRating', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.get();
  }

  /// Convenient helper to fetch popular top N cafes
  Future<List<Cafe>> fetchPopular({int limit = 5}) async {
    // Avoid combining where + orderBy to prevent composite index requirement.
    final snap = await _col
        .orderBy('avgRating', descending: true)
        .limit(limit * 3)
        .get();
    final items = snap.docs
        .map((d) => Cafe.fromFirestore(d))
        .where((c) => c.isActive)
        .toList();
    return items.take(limit).toList();
  }

  /// Fetch all active cafes ordered by avgRating (use with caution for large collections)
  Future<List<Cafe>> fetchAllOrdered() async {
    // Query only by ordering and filter `isActive` client-side to avoid index errors.
    final snap = await _col.orderBy('avgRating', descending: true).get();
    return snap.docs
        .map((d) => Cafe.fromFirestore(d))
        .where((c) => c.isActive)
        .toList();
  }

  /// Stream of active cafes (no ordering to avoid composite index requirement)
  Stream<List<Cafe>> cafesStream() {
    return _col.where('isActive', isEqualTo: true).snapshots().map((snap) {
      return snap.docs.map((d) => Cafe.fromFirestore(d)).toList();
    });
  }
}

final cafeService = CafeService.instance;
