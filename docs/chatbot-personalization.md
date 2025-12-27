# AI Chatbot Personalization Feature

## Overview
The AI chatbot has been enhanced to provide personalized coffee recommendations based on user preferences stored in Firebase. It now intelligently queries the database for coffee items that match the user's taste profile.

## Features

### 1. **User Preference Matching**
The chatbot retrieves the user's coffee preferences from their profile:
- **Coffee Types**: Black Coffee, Espresso, Latte, Cappuccino, Americano, Mocha
- **Coffee Strength**: Light, Medium, Strong
- **Taste Profiles**: Sweet, Bitter, Creamy, Chocolatey, Fruity, Nutty, Spicy, Sour

### 2. **Intelligent Query Detection**
The system detects different types of queries:

#### Weather-Based Queries (Existing - Unchanged)
- Triggers when user asks about weather, temperature, or time-based suggestions with "today"/"now"
- Uses real-time weather data to make recommendations
- Example: "What coffee should I drink based on the weather?"

#### Coffee Suggestion Queries (New)
Triggers when user asks for coffee recommendations based on:
- **Mood**: tired, energetic, relaxed, stressed
- **Time of Day**: morning, afternoon, evening, night
- **Occasion**: study, work, meeting, date
- **Characteristics**: quick, strong, light, sweet, bitter, creamy

Examples:
- "I'm feeling tired, what coffee should I get?"
- "Suggest a coffee for afternoon study session"
- "What's a good strong coffee?"
- "I want something sweet and creamy"

### 3. **Database Query & Scoring System**
When a coffee suggestion is detected:

1. **Fetch User Profile** - Get preferences from Firebase
2. **Query Coffee Items** - Get all available coffee items from database
3. **Score Matching** - Each item is scored based on:
   - Coffee type match: +3 points
   - Strength match: +2 points
   - Each taste profile match: +2 points
4. **Rank Results** - Top 5 highest-scoring items are selected
5. **Enrich with Café Data** - Fetch café information for each item

### 4. **Rich AI Response**
The AI receives detailed context including:
- User's preference summary
- Top 5 matching coffee items with:
  - Coffee name
  - Café name and location
  - Coffee type (subcategory)
  - Strength level
  - Taste profiles
  - Best time to drink
  - Price
  - Description
  - Match score

The AI then presents these real items in a friendly, personalized way explaining why each coffee matches the user's query.

## Implementation Details

### Files Modified

1. **ai_chat_state_service.dart**
   - Added imports for UserProfileService, MenuService, CafeService
   - New method: `_isCoffeeSuggestionQuery()` - Detects coffee suggestion queries
   - New method: `_getUserProfile()` - Fetches user preferences from Firebase
   - New method: `_queryCoffeeItems()` - Queries and scores coffee items
   - New method: `_formatCoffeeRecommendations()` - Formats data for AI context
   - Enhanced `sendMessage()` - Added coffee suggestion handling logic

2. **ai_chat_service.dart**
   - Enhanced system instruction with detailed guidelines for:
     - Presenting database items with specific details
     - Explaining match reasoning
     - Using emojis and friendly tone
     - Handling cases with no database items

### Database Schema Alignment
The implementation aligns with the PostgreSQL schema for `menu_item` table:
- ✅ Category filtering (coffee only)
- ✅ Subcategory matching (coffee types)
- ✅ Strength matching (light/medium/strong)
- ✅ Taste profile array matching
- ✅ Best time recommendations
- ✅ AI summary support

### User Profile Integration
Matches the user profile model structure:
- ✅ coffeeTypes getter
- ✅ coffeeStrength getter
- ✅ tasteProfiles getter

## Example Interactions

### Example 1: Mood-Based
**User**: "I'm feeling tired and need energy"

**AI Response**:
"☕ Perfect! I've got some great energizing options for you based on your preferences:

1. **Double Shot Espresso** at Café Noir
   - Strong, bold flavor with nutty notes
   - Just what you need for an energy boost!
   - 120 TK

2. **Americano Supreme** at Bean Haven
   - Medium strength with a smooth finish
   - Great for sustained energy without jitters
   - 150 TK
   
Both match your preference for strong coffee. The espresso will give you a quick kick, while the Americano provides longer-lasting energy!"

### Example 2: Time-Based
**User**: "What's good for an afternoon break?"

**AI Response**:
"🌤️ For a relaxing afternoon, I recommend:

1. **Caramel Latte** at Sweet Beans
   - Sweet and creamy, just like you prefer
   - Perfect afternoon treat
   - Best time: Afternoon ✓
   - 180 TK

2. **Vanilla Cappuccino** at The Coffee House
   - Smooth and balanced
   - Not too heavy for the afternoon
   - 160 TK

These match your sweet and creamy taste preferences perfectly!"

### Example 3: No Preferences Set
**User**: "Suggest a coffee"

**AI Response**:
"I'd love to give you personalized recommendations! To help me suggest the perfect coffee for you, could you set up your coffee preferences in your profile? 

In the meantime, here are some popular options:
- Latte - smooth and creamy
- Cappuccino - balanced and classic
- Americano - strong and straightforward

Let me know what sounds good, or tell me about your taste preferences!"

## Benefits

1. **Personalized Experience** - Recommendations based on actual user preferences
2. **Real Data** - Shows actual menu items from real cafés in the system
3. **Context-Aware** - Understands mood, time, and occasion
4. **Variety of Topics** - Handles multiple types of coffee-related queries
5. **Intelligent Scoring** - Prioritizes items that best match preferences
6. **Seamless Integration** - Works alongside existing weather-based recommendations

## Future Enhancements

Potential improvements:
- Add location-based filtering (show nearby cafés first)
- Include user's past order history in recommendations
- Add dietary preferences (sugar-free, dairy-free alternatives)
- Implement collaborative filtering (what similar users liked)
- Add seasonal/limited-time offers to recommendations
- Include café operating hours in suggestions
