import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_message_model.dart';
import '../models/user_profile_model.dart';
import '../models/menu_item_model.dart';
import '../models/cafe_model.dart';
import '../models/chat_order_model.dart';
import '../models/order_model.dart';
import 'ai_chat_service.dart';
import 'weather_service.dart';
import 'location_state_service.dart';
import 'order_service.dart';
import 'firebase_service.dart';

/// Holds extracted coffee criteria from user's message
class ExplicitCoffeeCriteria {
  final List<String> subcategories;
  final List<String> strengths;
  final List<String> tasteProfiles;

  ExplicitCoffeeCriteria({
    this.subcategories = const [],
    this.strengths = const [],
    this.tasteProfiles = const [],
  });

  bool get hasAnyCriteria =>
      subcategories.isNotEmpty ||
      strengths.isNotEmpty ||
      tasteProfiles.isNotEmpty;

  @override
  String toString() =>
      'ExplicitCoffeeCriteria(subcategories: $subcategories, strengths: $strengths, tasteProfiles: $tasteProfiles)';
}

class AIChatStateService extends ChangeNotifier {
  static const String _messagesKey = 'ai_chat_messages';
  final AIChatService _aiService = AIChatService();
  final OrderService _orderService = OrderService();

  // Coffee criteria constants
  static const List<String> _validSubcategories = [
    'black coffee',
    'espresso',
    'latte',
    'cappuccino',
    'americano',
    'mocha',
  ];

  static const List<String> _validStrengths = ['light', 'medium', 'strong'];

  static const List<String> _validTasteProfiles = [
    'sweet',
    'bitter',
    'creamy',
    'chocolatey',
    'fruity',
    'nutty',
    'spicy',
    'sour',
  ];

  // Reference to location service (will be set from outside)
  LocationStateService? _locationService;

  // Temporary storage for recommendations between query and response
  List<CoffeeRecommendation>? _pendingRecommendations;

  // Chat order state
  ChatOrderData _chatOrderData = ChatOrderData.initial();

  // Store the last recommendations for order reference
  List<CoffeeRecommendation> _lastRecommendations = [];

  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  AIChatService get aiService => _aiService;
  ChatOrderData get chatOrderData => _chatOrderData;
  List<CoffeeRecommendation> get lastRecommendations => _lastRecommendations;

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
      'recommendations': message.recommendations
          ?.map((r) => r.toJson())
          .toList(),
    };
  }

  // Convert JSON to message
  AIChatMessage _messageFromJson(Map<String, dynamic> json) {
    List<CoffeeRecommendation>? recommendations;
    if (json['recommendations'] != null) {
      recommendations = (json['recommendations'] as List)
          .map((r) => CoffeeRecommendation.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    return AIChatMessage(
      id: json['id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAI: json['isAI'] as bool,
      recommendations: recommendations,
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

  /// Extract explicit coffee criteria from user's message
  ExplicitCoffeeCriteria _extractExplicitCriteria(String message) {
    final lower = message.toLowerCase();
    final foundSubcategories = <String>[];
    final foundStrengths = <String>[];
    final foundTasteProfiles = <String>[];

    // Check for subcategories
    for (final subcat in _validSubcategories) {
      if (lower.contains(subcat)) {
        foundSubcategories.add(subcat);
      }
    }
    // Also check for single-word variants
    if (lower.contains('espresso') &&
        !foundSubcategories.contains('espresso')) {
      foundSubcategories.add('espresso');
    }
    if (lower.contains('latte') && !foundSubcategories.contains('latte')) {
      foundSubcategories.add('latte');
    }
    if (lower.contains('cappuccino') &&
        !foundSubcategories.contains('cappuccino')) {
      foundSubcategories.add('cappuccino');
    }
    if (lower.contains('americano') &&
        !foundSubcategories.contains('americano')) {
      foundSubcategories.add('americano');
    }
    if (lower.contains('mocha') && !foundSubcategories.contains('mocha')) {
      foundSubcategories.add('mocha');
    }
    if ((lower.contains('black') && lower.contains('coffee')) &&
        !foundSubcategories.contains('black coffee')) {
      foundSubcategories.add('black coffee');
    }

    // Check for strengths
    for (final strength in _validStrengths) {
      if (lower.contains(strength)) {
        foundStrengths.add(strength);
      }
    }

    // Check for taste profiles
    for (final taste in _validTasteProfiles) {
      if (lower.contains(taste)) {
        foundTasteProfiles.add(taste);
      }
    }

    return ExplicitCoffeeCriteria(
      subcategories: foundSubcategories,
      strengths: foundStrengths,
      tasteProfiles: foundTasteProfiles,
    );
  }

  /// Check if the query is about coffee suggestions (non-weather related)
  bool _isCoffeeSuggestionQuery(String message) {
    final lower = message.toLowerCase();

    // First check if explicit criteria are present
    final explicitCriteria = _extractExplicitCriteria(message);
    if (explicitCriteria.hasAnyCriteria) {
      return true;
    }

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

  /// Query coffee items matching explicit criteria from user message
  Future<List<CoffeeRecommendation>> _queryCoffeeItemsByExplicitCriteria(
    ExplicitCoffeeCriteria criteria,
  ) async {
    try {
      // Get all coffee items from all cafes
      final snapshot = await FirebaseFirestore.instance
          .collection('menuItems')
          .where('category', isEqualTo: 'coffee')
          .where('isAvailable', isEqualTo: true)
          .limit(30)
          .get();

      if (snapshot.docs.isEmpty) return [];

      // Convert to menu items and score them based on explicit criteria
      final items = snapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc))
          .toList();
      final scoredItems = <CoffeeRecommendation>[];

      for (final item in items) {
        int score = 0;

        // Match subcategory
        if (criteria.subcategories.isNotEmpty) {
          final itemSubcategory = item.subcategory.toLowerCase();
          for (final subcat in criteria.subcategories) {
            if (itemSubcategory.contains(subcat.toLowerCase()) ||
                subcat.toLowerCase().contains(itemSubcategory)) {
              score += 5; // Higher weight for explicit subcategory match
              break;
            }
          }
        }

        // Match strength
        if (criteria.strengths.isNotEmpty && item.strength != null) {
          final itemStrength = item.strength!.toLowerCase();
          for (final strength in criteria.strengths) {
            if (itemStrength == strength.toLowerCase()) {
              score += 3;
              break;
            }
          }
        }

        // Match taste profiles
        if (criteria.tasteProfiles.isNotEmpty && item.tasteProfile.isNotEmpty) {
          for (final taste in criteria.tasteProfiles) {
            for (final itemTaste in item.tasteProfile) {
              if (itemTaste.toLowerCase() == taste.toLowerCase()) {
                score += 3;
              }
            }
          }
        }

        // Only include items with matching score
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

          scoredItems.add(
            CoffeeRecommendation(item: item, cafe: cafe, matchScore: score),
          );
        }
      }

      // Sort by score (descending)
      scoredItems.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      // Return top 5
      return scoredItems.take(5).toList();
    } catch (e) {
      debugPrint('Error querying coffee items by explicit criteria: $e');
      return [];
    }
  }

  /// Format explicit criteria for AI context
  String _formatExplicitCriteria(ExplicitCoffeeCriteria criteria) {
    final parts = <String>[];
    if (criteria.subcategories.isNotEmpty) {
      parts.add('Types: ${criteria.subcategories.join(", ")}');
    }
    if (criteria.strengths.isNotEmpty) {
      parts.add('Strength: ${criteria.strengths.join(", ")}');
    }
    if (criteria.tasteProfiles.isNotEmpty) {
      parts.add('Taste: ${criteria.tasteProfiles.join(", ")}');
    }
    return parts.isEmpty ? 'No specific criteria' : parts.join(' | ');
  }

  /// Format coffee recommendations for AI context (explicit criteria version)
  String _formatCoffeeRecommendationsExplicit(
    List<CoffeeRecommendation> recommendations,
    ExplicitCoffeeCriteria criteria,
  ) {
    if (recommendations.isEmpty) {
      return '''User's Requested Criteria: ${_formatExplicitCriteria(criteria)}

No matching coffee items found in the database. Suggest alternatives or ask for more details.''';
    }

    final buffer = StringBuffer();
    buffer.writeln(
      'User\'s Requested Criteria: ${_formatExplicitCriteria(criteria)}',
    );
    buffer.writeln();
    buffer.writeln(
      'AVAILABLE COFFEE ITEMS FROM DATABASE (ranked by criteria match):',
    );
    buffer.writeln();

    for (int i = 0; i < recommendations.length; i++) {
      final rec = recommendations[i];
      final item = rec.item;
      final cafe = rec.cafe;

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
          '   Taste: ${item.tasteProfile.map((t) => _capitalize(t)).join(", ")}',
        );
      }
      if (item.bestTime.isNotEmpty) {
        buffer.writeln(
          '   Best Time: ${item.bestTime.map((t) => _capitalize(t)).join(", ")}',
        );
      }
      buffer.writeln('   Price: ${item.basePrice.toStringAsFixed(0)} TK');
      if (item.description != null && item.description!.isNotEmpty) {
        buffer.writeln('   Description: ${item.description}');
      }
      buffer.writeln('   Match Score: ${rec.matchScore}');
      buffer.writeln();
    }

    buffer.writeln();
    buffer.writeln('INSTRUCTIONS:');
    buffer.writeln(
      '- Give a SHORT, friendly intro about why these coffees match the user\'s request',
    );
    buffer.writeln(
      '- DO NOT list coffee details - they will be shown as product cards',
    );
    buffer.writeln('- Mention 1-2 coffee names briefly to highlight top picks');
    buffer.writeln('- Keep response concise (2-3 sentences max)');
    buffer.writeln('- End with a question or helpful tip if appropriate');
    buffer.writeln(
      '- Remind user they can order by saying "order the 1st one" or "order [coffee name]"',
    );

    return buffer.toString();
  }

  /// Query coffee items matching user preferences
  Future<List<CoffeeRecommendation>> _queryCoffeeItems(
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
      final scoredItems = <CoffeeRecommendation>[];

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

          scoredItems.add(
            CoffeeRecommendation(item: item, cafe: cafe, matchScore: score),
          );
        }
      }

      // Sort by score (descending)
      scoredItems.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      // Return top 5
      return scoredItems.take(5).toList();
    } catch (e) {
      debugPrint('Error querying coffee items: $e');
      return [];
    }
  }

  /// Format coffee recommendations for AI context
  String _formatCoffeeRecommendations(
    List<CoffeeRecommendation> recommendations,
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
      final rec = recommendations[i];
      final item = rec.item;
      final cafe = rec.cafe;

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
      buffer.writeln('   Match Score: ${rec.matchScore}');
      buffer.writeln();
    }

    buffer.writeln();
    buffer.writeln('INSTRUCTIONS:');
    buffer.writeln(
      '- Give a SHORT, friendly intro about why these coffees match the user',
    );
    buffer.writeln(
      '- DO NOT list coffee details - they will be shown as product cards',
    );
    buffer.writeln('- Mention 1-2 coffee names briefly to highlight top picks');
    buffer.writeln('- Keep response concise (2-3 sentences max)');
    buffer.writeln('- End with a question or helpful tip if appropriate');
    buffer.writeln(
      '- Remind user they can order by saying "order the 1st one" or "order [coffee name]"',
    );

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

  // ==================== ORDER HANDLING METHODS ====================

  /// Check if the message is an order intent
  bool _isOrderIntent(String message) {
    final lower = message.toLowerCase();

    // Order keywords
    final orderKeywords = [
      'order',
      'buy',
      'purchase',
      'get me',
      'i want',
      "i'll take",
      'i will take',
      'give me',
      'can i get',
      'can i have',
      'place order',
    ];

    return orderKeywords.any((kw) => lower.contains(kw));
  }

  /// Parse the order intent to find which item user wants
  CoffeeRecommendation? _parseOrderItem(String message) {
    if (_lastRecommendations.isEmpty) return null;

    final lower = message.toLowerCase();

    // Check for ordinal references (1st, 2nd, first, second, etc.)
    final ordinalPatterns = {
      RegExp(r'\b(1st|first|1|one)\b'): 0,
      RegExp(r'\b(2nd|second|2|two)\b'): 1,
      RegExp(r'\b(3rd|third|3|three)\b'): 2,
      RegExp(r'\b(4th|fourth|4|four)\b'): 3,
      RegExp(r'\b(5th|fifth|5|five)\b'): 4,
    };

    for (final entry in ordinalPatterns.entries) {
      if (entry.key.hasMatch(lower)) {
        final index = entry.value;
        if (index < _lastRecommendations.length) {
          return _lastRecommendations[index];
        }
      }
    }

    // Check for item name match
    for (final rec in _lastRecommendations) {
      final itemName = rec.item.name.toLowerCase();
      if (lower.contains(itemName) ||
          itemName
              .split(' ')
              .any((word) => lower.contains(word) && word.length > 3)) {
        return rec;
      }
    }

    return null;
  }

  /// Start the order flow for a selected item
  void startOrderFlow(CoffeeRecommendation item) {
    final subtotal = item.item.basePrice;
    final rewardPoints = _orderService.calculateRewardPoints(subtotal);

    _chatOrderData = ChatOrderData(
      state: ChatOrderState.selectingMode,
      selectedItem: item,
      subtotal: subtotal,
      rewardPoints: rewardPoints,
    );

    // Add AI message about the order
    addMessage(
      AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            "Great choice! You've selected **${item.item.name}** from ${item.cafe?.name ?? 'the café'}. How would you like to receive your order? ☕",
        timestamp: DateTime.now(),
        isAI: true,
      ),
    );

    notifyListeners();
  }

  /// Select order mode (dine-in or delivery)
  void selectOrderMode(OrderMode mode) {
    if (_chatOrderData.selectedItem == null) return;

    final subtotal = _chatOrderData.subtotal;
    final deliveryFee = mode == OrderMode.delivery
        ? OrderService.deliveryFee
        : 0.0;
    final total = subtotal + deliveryFee;
    final rewardPoints = _orderService.calculateRewardPoints(subtotal);

    _chatOrderData = _chatOrderData.copyWith(
      state: ChatOrderState.confirmingOrder,
      orderMode: mode,
      deliveryFee: deliveryFee,
      total: total,
      rewardPoints: rewardPoints,
    );

    final modeText = mode == OrderMode.delivery ? 'Delivery' : 'Dine-in';
    addMessage(
      AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            "Perfect! You've chosen **$modeText**. Please review your order summary and confirm when ready! 🎉",
        timestamp: DateTime.now(),
        isAI: true,
      ),
    );

    notifyListeners();
  }

  /// Update delivery address
  void updateDeliveryAddress(String address) {
    _chatOrderData = _chatOrderData.copyWith(deliveryAddress: address);
    notifyListeners();
  }

  /// Cancel the current order flow
  void cancelChatOrder() {
    _chatOrderData = ChatOrderData.initial();

    addMessage(
      AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            "No worries! Order cancelled. Is there anything else I can help you with? ☕",
        timestamp: DateTime.now(),
        isAI: true,
      ),
    );

    notifyListeners();
  }

  /// Confirm and place the order
  Future<void> confirmChatOrder() async {
    final orderData = _chatOrderData;
    final item = orderData.selectedItem;

    if (item == null || orderData.orderMode == null) {
      addMessage(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: "Sorry, something went wrong. Please try ordering again.",
          timestamp: DateTime.now(),
          isAI: true,
        ),
      );
      _chatOrderData = ChatOrderData.initial();
      notifyListeners();
      return;
    }

    // Set processing state
    _chatOrderData = orderData.copyWith(state: ChatOrderState.processing);
    notifyListeners();

    try {
      // Get cafe info for the order
      final cafeId = item.item.cafeId;
      String cafeName = item.cafe?.name ?? 'Unknown Café';
      String ownerAdminId = '';

      // Fetch ownerAdminId from cafe document
      try {
        final cafeDoc = await firebase.cafesCollection.doc(cafeId).get();
        if (cafeDoc.exists) {
          final cafeData = cafeDoc.data() as Map<String, dynamic>;
          ownerAdminId = cafeData['ownerAdminId'] ?? '';
          cafeName = cafeData['name'] ?? cafeName;
        }
      } catch (e) {
        debugPrint('Error fetching cafe info: $e');
      }

      // Create the order
      await _orderService.createAIOrder(
        menuItem: item.item,
        cafeId: cafeId,
        cafeName: cafeName,
        ownerAdminId: ownerAdminId,
        orderMode: orderData.orderMode!,
        deliveryAddress: orderData.orderMode == OrderMode.delivery
            ? orderData.deliveryAddress
            : null,
      );

      // Success!
      _chatOrderData = orderData.copyWith(state: ChatOrderState.completed);

      final modeEmoji = orderData.orderMode == OrderMode.delivery
          ? '🚗'
          : '🍽️';
      addMessage(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message:
              '''🎉 **Order Placed Successfully!**

Your **${item.item.name}** has been ordered from **$cafeName**!

$modeEmoji **Order Mode:** ${orderData.orderMode == OrderMode.delivery ? 'Delivery' : 'Dine-in'}
💰 **Total:** ${orderData.total.toStringAsFixed(0)} TK
⭐ **Points Earned:** ${orderData.rewardPoints} points

Your order is being prepared. You can track it in the Orders section. Enjoy your coffee! ☕✨''',
          timestamp: DateTime.now(),
          isAI: true,
        ),
      );

      // Reset order state after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      _chatOrderData = ChatOrderData.initial();
    } catch (e) {
      debugPrint('Error placing order: $e');
      _chatOrderData = orderData.copyWith(
        state: ChatOrderState.error,
        errorMessage: e.toString(),
      );

      addMessage(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message:
              "😔 Sorry, there was an error placing your order: ${e.toString().replaceAll('Exception: ', '')}. Please try again or place your order through the cart.",
          timestamp: DateTime.now(),
          isAI: true,
        ),
      );

      // Reset order state
      await Future.delayed(const Duration(seconds: 1));
      _chatOrderData = ChatOrderData.initial();
    }

    notifyListeners();
  }

  /// Handle order intent from user message
  Future<bool> _handleOrderIntent(String message) async {
    if (!_isOrderIntent(message)) return false;

    // Parse which item user wants to order
    final item = _parseOrderItem(message);

    if (item != null) {
      // Start order flow with the item
      startOrderFlow(item);
      return true;
    } else if (_lastRecommendations.isNotEmpty) {
      // User wants to order but didn't specify which item
      addMessage(
        AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: '''I see you want to place an order! 🛒

Which coffee would you like? You can say:
- "Order the 1st one" or "Order the first coffee"
- "Order [coffee name]"

Or tap the cart icon on any coffee card to add it to your cart! ☕''',
          timestamp: DateTime.now(),
          isAI: true,
        ),
      );
      return true;
    }

    return false;
  }

  // ==================== END ORDER HANDLING ====================

  // Send message and get AI response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || !_isInitialized) return;

    // If there's an active order flow, don't process as regular message
    if (_chatOrderData.isActive) {
      // User might be cancelling or confirming
      final lower = userMessage.toLowerCase();
      if (lower.contains('cancel') ||
          lower.contains('no') ||
          lower.contains('stop')) {
        cancelChatOrder();
        return;
      }
      // Otherwise ignore regular messages during order flow
      return;
    }

    // Add user message
    final userChatMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: userMessage.trim(),
      timestamp: DateTime.now(),
      isAI: false,
    );
    addMessage(userChatMessage);

    // Check for order intent first
    if (await _handleOrderIntent(userMessage)) {
      return;
    }

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
        // Handle coffee suggestions
        debugPrint('Coffee suggestion query detected (non-weather)');

        // First, check for explicit coffee criteria in the message
        final explicitCriteria = _extractExplicitCriteria(messageToSend);

        if (explicitCriteria.hasAnyCriteria) {
          // User specified explicit criteria - use those instead of preferences
          debugPrint('Explicit criteria found: $explicitCriteria');

          // Query coffee items matching explicit criteria
          final recommendations = await _queryCoffeeItemsByExplicitCriteria(
            explicitCriteria,
          );
          debugPrint(
            'Found ${recommendations.length} matching coffee items by explicit criteria',
          );

          // Store recommendations for use in AI response
          _pendingRecommendations = recommendations;

          // Format recommendations for AI
          final coffeeContext = _formatCoffeeRecommendationsExplicit(
            recommendations,
            explicitCriteria,
          );

          messageToSend = '''User's question: $messageToSend

$coffeeContext''';
        } else {
          // No explicit criteria - fall back to user preferences
          debugPrint('No explicit criteria, using user preferences');
          final profile = await _getUserProfile();

          if (profile != null) {
            debugPrint('User profile fetched');

            // Query coffee items matching user preferences
            final recommendations = await _queryCoffeeItems(profile);
            debugPrint('Found ${recommendations.length} matching coffee items');

            // Store recommendations for use in AI response
            _pendingRecommendations = recommendations;

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
      }

      // Get AI response
      final aiResponse = await _aiService.sendMessage(messageToSend);

      // Store recommendations for order reference
      if (_pendingRecommendations != null &&
          _pendingRecommendations!.isNotEmpty) {
        _lastRecommendations = List.from(_pendingRecommendations!);
      }

      // Add recommendations to the AI response if we have them
      final responseWithRecommendations = AIChatMessage(
        id: aiResponse.id,
        message: aiResponse.message,
        timestamp: aiResponse.timestamp,
        isAI: aiResponse.isAI,
        recommendations: _pendingRecommendations,
      );
      _pendingRecommendations = null;

      addMessage(responseWithRecommendations);
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
    _lastRecommendations.clear();
    _chatOrderData = ChatOrderData.initial();
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
