# AI Chatbot Setup

## Overview
The CaffiAI chatbot has been successfully created using Google's Gemini AI. The chatbot provides a conversational interface for users to ask questions about coffee, brewing techniques, and cafe information.

## Features
- ✅ Real-time AI responses using Google Gemini
- ✅ Beautiful chat UI with message bubbles
- ✅ Message history (in-memory, not persisted to database)
- ✅ Loading indicators
- ✅ Clear chat functionality
- ✅ Error handling

## Files Created/Modified

### New Files:
1. **lib/services/ai_chat_service.dart** - Service handling Gemini API integration
2. **.env** - Environment variables file (add your API key here)
3. **.env.example** - Template for environment variables

### Modified Files:
1. **lib/pages/chat_page.dart** - Complete chat UI implementation
2. **lib/models/chat_message_model.dart** - Added `isAI` field
3. **lib/main.dart** - Added dotenv initialization
4. **pubspec.yaml** - Added dependencies:
   - `google_generative_ai: ^0.4.6`
   - `flutter_dotenv: ^5.2.1`
5. **.gitignore** - Added `.env` to prevent committing secrets

## Setup Instructions

### 1. Get Your Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key

### 2. Add API Key to .env
Open the `.env` file and replace the placeholder:
```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. Run the App
```bash
flutter run
```

## Usage

1. Navigate to the Chat page using the bottom navigation
2. Type your message in the input field
3. Press send or hit enter
4. Wait for CaffiAI to respond
5. Use the delete icon to clear the chat history

## Architecture

### AIChatService
- Singleton pattern for single instance
- Manages Gemini API connection
- Maintains chat session for context
- Methods:
  - `initialize()` - Set up API connection
  - `sendMessage()` - Send user message and get AI response
  - `resetChat()` - Clear conversation history
  - `getOneTimeResponse()` - Get response without context

### Chat Page
- StatefulWidget with real-time message list
- Local message storage (List<ChatMessage>)
- Auto-scroll to latest message
- Loading states and error handling

## Notes

- Messages are NOT saved to the database (as requested)
- Chat history is lost when the app restarts
- The AI has a system instruction to act as a coffee assistant
- API key is loaded from .env file (never commit this file)
- The `.env` file is in `.gitignore` to prevent accidental commits

## Future Enhancements (Optional)
- Save messages to Firestore
- User authentication integration
- Message reactions
- Voice input
- Image sharing
- Typing indicators
- Read receipts
