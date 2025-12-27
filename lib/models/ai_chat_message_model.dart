/// Simple AI chat message model for in-memory storage only
/// Not related to database/Firestore
class AIChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isAI;

  const AIChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isAI,
  });

  AIChatMessage copyWith({
    String? id,
    String? message,
    DateTime? timestamp,
    bool? isAI,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isAI: isAI ?? this.isAI,
    );
  }
}
