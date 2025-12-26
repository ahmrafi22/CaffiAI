import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import 'firebase_service.dart';

class ChatService {
  final FirebaseService _firebase = FirebaseService.instance;

  // Reference to the global chat messages collection
  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firebase.firestore.collection('globalChat');

  // Stream of chat messages ordered by timestamp (newest first for display)
  Stream<List<ChatMessage>> getChatMessagesStream() {
    return _messagesCollection
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to last 100 messages
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList();
        });
  }

  // Send a new message to the global chat
  Future<void> sendMessage({
    required String message,
    required String userName,
  }) async {
    final userId = _firebase.currentUid;
    if (userId == null) {
      throw Exception('User must be logged in to send messages');
    }

    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final chatMessage = ChatMessage(
      id: '', // Will be set by Firestore
      userId: userId,
      userName: userName,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    await _messagesCollection.add(chatMessage.toMap());
  }

  // Delete a message (only if current user is the author)
  Future<void> deleteMessage(String messageId, String messageUserId) async {
    final currentUserId = _firebase.currentUid;
    if (currentUserId == null) {
      throw Exception('User must be logged in to delete messages');
    }

    if (currentUserId != messageUserId) {
      throw Exception('You can only delete your own messages');
    }

    await _messagesCollection.doc(messageId).delete();
  }

  // Get a single page of messages (for pagination if needed)
  Future<List<ChatMessage>> getMessages({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _messagesCollection
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList();
  }
}
