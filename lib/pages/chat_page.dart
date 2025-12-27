import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/brand_colors.dart';
import '../models/ai_chat_message_model.dart';
import '../services/ai_chat_state_service.dart';
import '../services/location_state_service.dart';
import '../widgets/chat_coffee_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLocationLinked = false;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _linkLocationService();
    });
  }

  void _linkLocationService() {
    if (!_isLocationLinked) {
      final locationService = context.read<LocationStateService>();
      final chatService = context.read<AIChatStateService>();
      chatService.setLocationService(locationService);
      _isLocationLinked = true;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage(AIChatStateService chatService) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    await chatService.sendMessage(message);
    _scrollToBottom();
  }

  void _clearChat(AIChatStateService chatService) {
    chatService.clearMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIChatStateService>(
      builder: (context, chatService, child) {
        if (chatService.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: BrandColors.mocha.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Initialize AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: BrandColors.espressoBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chatService.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: BrandColors.mediumRoast),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: chatService.retryInitialization,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.mocha,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Messages List
            Expanded(
              child: Stack(
                children: [
                  chatService.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.coffee_outlined,
                                size: 80,
                                color: BrandColors.mocha.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start a conversation',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: BrandColors.mediumRoast),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask me anything about coffee!',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: BrandColors.mediumRoast.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatService.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatService.messages[index];
                            return _MessageBubble(message: message);
                          },
                        ),
                  // Floating delete button
                  if (chatService.messages.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _clearChat(chatService),
                          icon: const Icon(Icons.delete_sweep_outlined),
                          color: BrandColors.warmRed,
                          tooltip: 'Clear chat',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Loading indicator
            if (chatService.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BrandColors.mocha,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Brewing response...',
                      style: TextStyle(
                        color: BrandColors.mediumRoast,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Input Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled:
                            chatService.isInitialized && !chatService.isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ask about coffee...',
                          hintStyle: TextStyle(
                            color: BrandColors.mediumRoast.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: BrandColors.lightFoam,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: BrandColors.mocha,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(chatService),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: BrandColors.mocha,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed:
                            (chatService.isInitialized &&
                                !chatService.isLoading)
                            ? () => _sendMessage(chatService)
                            : null,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        color: Colors.white,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AIChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isAI
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // Main message bubble
          Row(
            mainAxisAlignment: isAI
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAI) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [BrandColors.mocha, BrandColors.caramel],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BrandColors.mocha.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.coffee,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isAI ? Colors.white : BrandColors.mocha,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAI ? 4 : 20),
                      topRight: Radius.circular(isAI ? 20 : 4),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isAI
                      ? MarkdownBody(
                          data: message.message,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            em: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                            code: TextStyle(
                              backgroundColor: BrandColors.lightFoam,
                              color: BrandColors.mocha,
                              fontSize: 14,
                            ),
                            listBullet: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 15,
                            ),
                            h1: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: const TextStyle(
                              color: BrandColors.espressoBrown,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Text(
                          message.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Coffee recommendation cards (if any)
          if (isAI && message.hasRecommendations) ...[
            const SizedBox(height: 16),
            ChatCoffeeCardList(recommendations: message.recommendations!),
          ],
        ],
      ),
    );
  }
}
