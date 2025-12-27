import '../models/menu_item_model.dart';
import '../models/cafe_model.dart';

/// Represents a recommended coffee item with its cafe info
class CoffeeRecommendation {
  final MenuItem item;
  final Cafe? cafe;
  final int matchScore;

  const CoffeeRecommendation({
    required this.item,
    this.cafe,
    this.matchScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': item.id,
      'cafeId': item.cafeId,
      'itemName': item.name,
      'cafeName': cafe?.name,
      'cafeAddress': cafe?.address,
      'cafeCity': cafe?.city,
      'subcategory': item.subcategory,
      'strength': item.strength,
      'tasteProfile': item.tasteProfile,
      'bestTime': item.bestTime,
      'basePrice': item.basePrice,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'matchScore': matchScore,
    };
  }

  factory CoffeeRecommendation.fromJson(Map<String, dynamic> json) {
    return CoffeeRecommendation(
      item: MenuItem(
        id: json['itemId'] ?? '',
        cafeId: json['cafeId'] ?? '',
        category: 'coffee',
        subcategory: json['subcategory'] ?? '',
        name: json['itemName'] ?? '',
        description: json['description'],
        basePrice: (json['basePrice'] ?? 0).toDouble(),
        imageUrl: json['imageUrl'],
        strength: json['strength'],
        tasteProfile: json['tasteProfile'] != null
            ? List<String>.from(json['tasteProfile'])
            : [],
        bestTime: json['bestTime'] != null
            ? List<String>.from(json['bestTime'])
            : [],
      ),
      cafe: json['cafeName'] != null
          ? Cafe(
              id: json['cafeId'] ?? '',
              name: json['cafeName'] ?? '',
              address: json['cafeAddress'] ?? '',
              city: json['cafeCity'] ?? '',
              description: '',
              latitude: 0,
              longitude: 0,
              avgRating: 0,
              startingPrice: 0,
              isActive: true,
              ownerAdminId: '',
            )
          : null,
      matchScore: json['matchScore'] ?? 0,
    );
  }
}

/// Simple AI chat message model for in-memory storage only
/// Not related to database/Firestore
class AIChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isAI;
  final List<CoffeeRecommendation>? recommendations;

  const AIChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isAI,
    this.recommendations,
  });

  bool get hasRecommendations =>
      recommendations != null && recommendations!.isNotEmpty;

  AIChatMessage copyWith({
    String? id,
    String? message,
    DateTime? timestamp,
    bool? isAI,
    List<CoffeeRecommendation>? recommendations,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isAI: isAI ?? this.isAI,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}
