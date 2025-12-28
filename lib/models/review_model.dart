import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String cafeId;
  final String cafeName;
  final String userId;
  final String userName;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.cafeId,
    required this.cafeName,
    required this.userId,
    required this.userName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      cafeId: data['cafeId'] ?? '',
      cafeName: data['cafeName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      orderId: data['orderId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cafeId': cafeId,
      'cafeName': cafeName,
      'userId': userId,
      'userName': userName,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
