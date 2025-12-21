import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String cafeId;
  final String category; // 'coffee', 'drink', 'food', 'dessert'
  final String subcategory;
  final String name;
  final String? description;
  final double basePrice;
  final String? imageUrl;
  final bool isAvailable;

  // Coffee-specific fields
  final String? strength; // 'light', 'medium', 'strong'
  final List<String> tasteProfile;
  final List<String> bestTime;

  final String? aiSummary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.cafeId,
    required this.category,
    required this.subcategory,
    required this.name,
    this.description,
    required this.basePrice,
    this.imageUrl,
    this.isAvailable = true,
    this.strength,
    this.tasteProfile = const [],
    this.bestTime = const [],
    this.aiSummary,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      cafeId: data['cafeId'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      strength: data['strength'],
      tasteProfile: data['tasteProfile'] != null
          ? List<String>.from(data['tasteProfile'])
          : [],
      bestTime: data['bestTime'] != null
          ? List<String>.from(data['bestTime'])
          : [],
      aiSummary: data['aiSummary'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cafeId': cafeId,
      'category': category,
      'subcategory': subcategory,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'strength': strength,
      'tasteProfile': tasteProfile,
      'bestTime': bestTime,
      'aiSummary': aiSummary,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
