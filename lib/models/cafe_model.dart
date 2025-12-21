import 'package:cloud_firestore/cloud_firestore.dart';

class Cafe {
  final String id;
  final String name;
  final String address;
  final String city;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final double avgRating;
  final int startingPrice;
  final bool isActive;
  final String ownerAdminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tags;

  Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.avgRating,
    required this.startingPrice,
    required this.isActive,
    required this.ownerAdminId,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  factory Cafe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Cafe(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      imageUrl: data['imageUrl'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      startingPrice: (data['startingPrice'] as num?)?.toInt() ?? 0,
      isActive: (data['isActive'] as bool?) ?? true,
      ownerAdminId: (data['ownerAdminId'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
    );
  }

  String get location => '$address • $city';
}
