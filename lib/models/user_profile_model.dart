import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic>? preferences;
  final int rewardPoints;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.preferences,
    this.rewardPoints = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters for coffee preferences
  List<String> get coffeeTypes {
    final types = preferences?['coffeeTypes'];
    if (types is List) {
      return types.map((e) => e.toString()).toList();
    }
    return [];
  }

  String? get coffeeStrength {
    return preferences?['coffeeStrength'] as String?;
  }

  List<String> get tasteProfiles {
    final profiles = preferences?['tasteProfiles'];
    if (profiles is List) {
      return profiles.map((e) => e.toString()).toList();
    }
    return [];
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserProfile.fromMap(doc.id, data);
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      preferences: (data['preferences'] as Map<String, dynamic>?),
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'preferences': preferences,
      'rewardPoints': rewardPoints,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    }..removeWhere((_, value) => value == null);
  }

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
    int? rewardPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
