import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_message_model.dart';
import 'ai_chat_service.dart';
import 'weather_service.dart';
import 'location_state_service.dart';

class AIChatStateService extends ChangeNotifier {
  static const String _messagesKey = 'ai_chat_messages';
  final AIChatService _aiService = AIChatService();

  // Reference to location service (will be set from outside)
  LocationStateService? _locationService;

  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  AIChatService get aiService => _aiService;

  /// Set location service reference
  void setLocationService(LocationStateService locationService) {
    _locationService = locationService;
  }

  AIChatStateService() {
    _loadMessages();
    _initializeAI();
  }

  // Load messages from local storage
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);

      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages = decoded.map((item) => _messageFromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // Save messages to local storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((msg) => _messageToJson(msg)).toList(),
      );
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  // Convert message to JSON
  Map<String, dynamic> _messageToJson(AIChatMessage message) {
    return {
      'id': message.id,
      'message': message.message,
      'timestamp': message.timestamp.toIso8601String(),
      'isAI': message.isAI,
    };
  }

  // Convert JSON to message
  AIChatMessage _messageFromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAI: json['isAI'] as bool,
    );
  }

  // Initialize AI service
  Future<void> _initializeAI() async {
    try {
      await _aiService.initialize();
      _isInitialized = true;
      _errorMessage = null;
      notifyListeners();

      // Add welcome message if no messages exist
      if (_messages.isEmpty) {
        addMessage(
          AIChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message:
                'Hello! I\'m CaffiAI, your personal coffee assistant. How can I help you today?',
            timestamp: DateTime.now(),
            isAI: true,
          ),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Retry initialization
  Future<void> retryInitialization() async {
    await _initializeAI();
  }

  // Add a message
  void addMessage(AIChatMessage message) {
    _messages.insert(0, message);
    _saveMessages();
    notifyListeners();
  }

  // Send message and get AI response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || !_isInitialized) return;

    // Add user message
    final userChatMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: userMessage.trim(),
      timestamp: DateTime.now(),
      isAI: false,
    );
    addMessage(userChatMessage);

    // Show loading
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is asking about weather-based coffee suggestions
      String messageToSend = userMessage.trim();
      final lowerMessage = messageToSend.toLowerCase();

      final isWeatherRelated =
          lowerMessage.contains('weather') ||
          lowerMessage.contains('temperature') ||
          lowerMessage.contains('cold') ||
          lowerMessage.contains('hot') ||
          lowerMessage.contains('warm') ||
          lowerMessage.contains('rainy') ||
          lowerMessage.contains('rain') ||
          lowerMessage.contains('sunny') ||
          (lowerMessage.contains('suggest') &&
              (lowerMessage.contains('today') ||
                  lowerMessage.contains('now'))) ||
          (lowerMessage.contains('recommend') &&
              (lowerMessage.contains('today') || lowerMessage.contains('now')));

      // If weather-related and we have location, fetch weather and add context
      if (isWeatherRelated) {
        debugPrint('Weather-related query detected');
        debugPrint('Location service: ${_locationService != null}');
        debugPrint('Has location: ${_locationService?.hasLocation}');
        debugPrint(
          'Lat: ${_locationService?.latitude}, Lng: ${_locationService?.longitude}',
        );

        if (_locationService != null && _locationService!.hasLocation) {
          final weather = await WeatherService.getWeather(
            _locationService!.latitude!,
            _locationService!.longitude!,
          );

          debugPrint('Weather fetched: ${weather != null}');
          if (weather != null) {
            final weatherContext = weather.getCoffeeRecommendationContext();
            debugPrint('Weather context: $weatherContext');
            messageToSend =
                '''
User's question: $messageToSend

IMPORTANT - Current weather information for the user's location:
$weatherContext

You MUST use this weather information to give personalized coffee recommendations. Reference the actual temperature and weather conditions in your response.''';
          }
        } else {
          // Location not available, tell user
          messageToSend =
              '''
User's question: $messageToSend

Note: I don't have access to the user's current location/weather. Ask them to enable location services or tell you their weather conditions so you can make appropriate suggestions.''';
        }
      }

      // Get AI response
      final aiResponse = await _aiService.sendMessage(messageToSend);
      addMessage(aiResponse);
    } catch (e) {
      // Add error message
      addMessage(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: 'Sorry, I encountered an error: ${e.toString()}',
          timestamp: DateTime.now(),
          isAI: true,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all messages
  Future<void> clearMessages() async {
    _messages.clear();
    _aiService.resetChat();
    await _saveMessages();
    notifyListeners();

    // Add welcome message again
    addMessage(
      AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            'Hello! I\'m CaffiAI 🍵, your personal coffee assistant. How can I help you today?',
        timestamp: DateTime.now(),
        isAI: true,
      ),
    );
  }

  @override
  void dispose() {
    _saveMessages();
    super.dispose();
  }
}
