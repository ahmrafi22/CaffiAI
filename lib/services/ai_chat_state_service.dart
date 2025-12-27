import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_message_model.dart';
import '../models/user_profile_model.dart';
import '../models/menu_item_model.dart';
import '../models/cafe_model.dart';
import 'ai_chat_service.dart';
import 'weather_service.dart';
import 'location_state_service.dart';
import 'firebase_service.dart';

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

  /// Check if the query is about coffee suggestions (non-weather related)
  bool _isCoffeeSuggestionQuery(String message) {
    final lower = message.toLowerCase();

    // Keywords for coffee suggestions
    final suggestionKeywords = [
      'suggest',
      'recommend',
      'coffee',
      'drink',
      'beverage',
      'what should i',
      'what can i',
      'help me choose',
      'pick',
    ];

    // Context keywords (mood, time, occasion, etc.)
    final contextKeywords = [
      'mood',
      'feeling',
      'tired',
      'energetic',
      'relaxed',
      'stressed',
      'morning',
      'afternoon',
      'evening',
      'night',
      'breakfast',
      'lunch',
      'study',
      'work',
      'meeting',
      'date',
      'quick',
      'strong',
      'light',
      'sweet',
      'bitter',
      'creamy',
      'smooth',
      'energize',
      'focus',
    ];

    final hasSuggestionKeyword = suggestionKeywords.any(
      (kw) => lower.contains(kw),
    );
    final hasContextKeyword = contextKeywords.any((kw) => lower.contains(kw));

    return hasSuggestionKeyword || hasContextKeyword;
  }

  /// Fetch user profile preferences
  Future<UserProfile?> _getUserProfile() async {
    final user = firebase.currentUser;
    if (user == null) return null;

    try {
      final doc = await firebase.usersCollection.doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromDoc(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
    return null;
  }

  /// Query coffee items matching user preferences
  Future<List<Map<String, dynamic>>> _queryCoffeeItems(
    UserProfile profile,
  ) async {
    try {
      // Get all coffee items from all cafes
      final snapshot = await FirebaseFirestore.instance
          .collection('menuItems')
          .where('category', isEqualTo: 'coffee')
          .where('isAvailable', isEqualTo: true)
          .limit(20)
          .get();

      if (snapshot.docs.isEmpty) return [];

      // Convert to menu items and score them based on preferences
      final items = snapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc))
          .toList();
      final scoredItems = <Map<String, dynamic>>[];

      for (final item in items) {
        int score = 0;

        // Match subcategory (coffee type)
        if (profile.coffeeTypes.isNotEmpty) {
          final itemSubcategory = item.subcategory.toLowerCase();
          for (final prefType in profile.coffeeTypes) {
            if (itemSubcategory.contains(prefType.toLowerCase()) ||
                prefType.toLowerCase().contains(itemSubcategory)) {
              score += 3;
              break;
            }
          }
        }

        // Match strength
        if (profile.coffeeStrength != null && item.strength != null) {
          if (item.strength!.toLowerCase() ==
              profile.coffeeStrength!.toLowerCase()) {
            score += 2;
          }
        }

        // Match taste profiles
        if (profile.tasteProfiles.isNotEmpty && item.tasteProfile.isNotEmpty) {
          for (final prefTaste in profile.tasteProfiles) {
            for (final itemTaste in item.tasteProfile) {
              if (itemTaste.toLowerCase() == prefTaste.toLowerCase()) {
                score += 2;
              }
            }
          }
        }

        // If no preferences set, include all items with base score
        if (profile.coffeeTypes.isEmpty &&
            profile.coffeeStrength == null &&
            profile.tasteProfiles.isEmpty) {
          score = 1;
        }

        if (score > 0) {
          // Get cafe info
          Cafe? cafe;
          try {
            final cafeDoc = await firebase.cafesCollection
                .doc(item.cafeId)
                .get();
            if (cafeDoc.exists) {
              cafe = Cafe.fromFirestore(cafeDoc);
            }
          } catch (e) {
            debugPrint('Error fetching cafe: $e');
          }

          scoredItems.add({'item': item, 'cafe': cafe, 'score': score});
        }
      }

      // Sort by score (descending)
      scoredItems.sort(
        (a, b) => (b['score'] as int).compareTo(a['score'] as int),
      );

      // Return top 5
      return scoredItems.take(5).toList();
    } catch (e) {
      debugPrint('Error querying coffee items: $e');
      return [];
    }
  }

  /// Format coffee recommendations for AI context
  String _formatCoffeeRecommendations(
    List<Map<String, dynamic>> recommendations,
    UserProfile profile,
  ) {
    if (recommendations.isEmpty) {
      return '''User Preferences: ${_formatUserPreferences(profile)}

No matching coffee items found in the database. Provide general coffee recommendations based on the user's preferences.''';
    }

    final buffer = StringBuffer();
    buffer.writeln('User Preferences: ${_formatUserPreferences(profile)}');
    buffer.writeln();
    buffer.writeln(
      'AVAILABLE COFFEE ITEMS FROM DATABASE (ranked by preference match):',
    );
    buffer.writeln();

    for (int i = 0; i < recommendations.length; i++) {
      final data = recommendations[i];
      final MenuItem item = data['item'];
      final Cafe? cafe = data['cafe'];
      final int score = data['score'];

      buffer.writeln('${i + 1}. **${item.name}**');
      if (cafe != null) {
        buffer.writeln('   Café: ${cafe.name}');
        buffer.writeln('   Location: ${cafe.address}, ${cafe.city}');
      }
      buffer.writeln('   Type: ${_capitalize(item.subcategory)}');
      if (item.strength != null) {
        buffer.writeln('   Strength: ${_capitalize(item.strength!)}');
      }
      if (item.tasteProfile.isNotEmpty) {
        buffer.writeln(
          '   Taste: ${item.tasteProfile.map(_capitalize).join(", ")}',
        );
      }
      if (item.bestTime.isNotEmpty) {
        buffer.writeln(
          '   Best Time: ${item.bestTime.map(_capitalize).join(", ")}',
        );
      }
      buffer.writeln('   Price: ${item.basePrice.toStringAsFixed(0)} TK');
      if (item.description != null && item.description!.isNotEmpty) {
        buffer.writeln('   Description: ${item.description}');
      }
      buffer.writeln('   Match Score: $score');
      buffer.writeln();
    }

    buffer.writeln();
    buffer.writeln('INSTRUCTIONS:');
    buffer.writeln(
      '- Present these REAL coffee options from our database to the user',
    );
    buffer.writeln('- Mention the specific coffee names, cafés, and details');
    buffer.writeln(
      '- Explain WHY each option matches their query/mood/preferences',
    );
    buffer.writeln('- Be enthusiastic and helpful in your recommendations');
    buffer.writeln('- Use the match scores to prioritize recommendations');

    return buffer.toString();
  }

  String _formatUserPreferences(UserProfile profile) {
    final prefs = <String>[];
    if (profile.coffeeTypes.isNotEmpty) {
      prefs.add('Types: ${profile.coffeeTypes.join(", ")}');
    }
    if (profile.coffeeStrength != null) {
      prefs.add('Strength: ${profile.coffeeStrength}');
    }
    if (profile.tasteProfiles.isNotEmpty) {
      prefs.add('Taste: ${profile.tasteProfiles.join(", ")}');
    }
    return prefs.isEmpty ? 'No preferences set' : prefs.join(' | ');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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

      // Check if it's a coffee suggestion query (non-weather)
      final isCoffeeSuggestion =
          !isWeatherRelated && _isCoffeeSuggestionQuery(lowerMessage);

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
      } else if (isCoffeeSuggestion) {
        // Handle coffee suggestions based on user preferences and database
        debugPrint('Coffee suggestion query detected (non-weather)');

        final profile = await _getUserProfile();

        if (profile != null) {
          debugPrint('User profile fetched');

          // Query coffee items matching user preferences
          final recommendations = await _queryCoffeeItems(profile);
          debugPrint('Found ${recommendations.length} matching coffee items');

          // Format recommendations for AI
          final coffeeContext = _formatCoffeeRecommendations(
            recommendations,
            profile,
          );

          messageToSend = '''User's question: $messageToSend

$coffeeContext''';
        } else {
          debugPrint('No user profile found or user not logged in');
          messageToSend = '''User's question: $messageToSend

Note: User profile not available. Provide general coffee recommendations and suggest they create a profile for personalized suggestions.''';
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
