import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import 'firebase_service.dart';

class ReviewService extends ChangeNotifier {
  final _fb = firebase;

  // Get reviews collection
  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _fb.firestore.collection('reviews');

  /// Add a review for a cafe
  Future<void> addReview({
    required String cafeId,
    required String cafeName,
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final user = _fb.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to add a review');
    }

    // Check if user has already reviewed this order
    final existingReview = await _reviewsCollection
        .where('orderId', isEqualTo: orderId)
        .where('userId', isEqualTo: user.uid)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('You have already reviewed this order');
    }

    // Get user name
    final userDoc = await _fb.firestore.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Anonymous User';

    // Add review
    await _reviewsCollection.add({
      'cafeId': cafeId,
      'cafeName': cafeName,
      'userId': user.uid,
      'userName': userName,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update cafe's average rating
    await _updateCafeRating(cafeId);

    notifyListeners();
  }

  /// Get reviews for a specific cafe
  Stream<List<Review>> getCafeReviews(String cafeId) {
    return _reviewsCollection
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => Review.fromFirestore(doc))
              .toList();
          // Sort by createdAt in memory to avoid needing a composite index
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  /// Check if user has reviewed a specific order
  Future<bool> hasUserReviewedOrder(String orderId) async {
    final user = _fb.currentUser;
    if (user == null) return false;

    final review = await _reviewsCollection
        .where('orderId', isEqualTo: orderId)
        .where('userId', isEqualTo: user.uid)
        .get();

    return review.docs.isNotEmpty;
  }

  /// Get review statistics for a cafe
  Future<Map<String, dynamic>> getCafeReviewStats(String cafeId) async {
    final reviews = await _reviewsCollection
        .where('cafeId', isEqualTo: cafeId)
        .get();

    if (reviews.docs.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }

    double totalRating = 0;
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var doc in reviews.docs) {
      final rating = (doc.data()['rating'] ?? 0.0).toDouble();
      totalRating += rating;
      distribution[rating.round()] = (distribution[rating.round()] ?? 0) + 1;
    }

    return {
      'averageRating': totalRating / reviews.docs.length,
      'totalReviews': reviews.docs.length,
      'ratingDistribution': distribution,
    };
  }

  /// Update cafe's average rating
  Future<void> _updateCafeRating(String cafeId) async {
    final stats = await getCafeReviewStats(cafeId);
    await _fb.firestore.collection('cafes').doc(cafeId).update({
      'avgRating': stats['averageRating'],
    });
  }

  /// Delete a review (only by the user who created it)
  Future<void> deleteReview(String reviewId) async {
    final user = _fb.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to delete a review');
    }

    final reviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final reviewData = reviewDoc.data();
    if (reviewData?['userId'] != user.uid) {
      throw Exception('You can only delete your own reviews');
    }

    final cafeId = reviewData?['cafeId'];
    await _reviewsCollection.doc(reviewId).delete();

    // Update cafe rating after deletion
    if (cafeId != null) {
      await _updateCafeRating(cafeId);
    }

    notifyListeners();
  }
}

// Global instance
final reviewService = ReviewService();
