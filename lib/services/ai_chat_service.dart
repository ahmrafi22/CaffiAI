import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_chat_message_model.dart';

class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  /// Initialize the AI service with the API key from .env
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'your_gemini_api_key_here') {
        throw Exception(
          'GEMINI_API_KEY not found in .env file. Please add your API key.',
        );
      }

      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are CaffiAI, a friendly and knowledgeable coffee assistant. '
          'You help users with coffee recommendations, brewing techniques, '
          'cafe information, and general coffee-related questions. '
          'Keep responses concise, helpful, and friendly. '
          'If asked about orders or the menu, guide users to check the menu section of the app.',
        ),
      );

      _chatSession = _model!.startChat();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AI service: $e');
    }
  }

  /// Check if the service is properly initialized
  bool get isInitialized => _isInitialized;

  /// Send a message to the AI and get a response
  Future<AIChatMessage> sendMessage(String userMessage) async {
    if (!_isInitialized) {
      throw Exception('AI service not initialized. Call initialize() first.');
    }

    if (_chatSession == null) {
      throw Exception('Chat session not available.');
    }

    try {
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      final aiResponse =
          response.text ?? 'Sorry, I could not generate a response.';

      // Create an AIChatMessage object for the AI response
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        timestamp: DateTime.now(),
        isAI: true,
      );
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Reset the chat session (clear conversation history)
  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  /// Get a one-off response without maintaining chat history
  Future<String> getOneTimeResponse(String prompt) async {
    if (!_isInitialized) {
      throw Exception('AI service not initialized. Call initialize() first.');
    }

    if (_model == null) {
      throw Exception('AI model not available.');
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _isInitialized = false;
  }
}
