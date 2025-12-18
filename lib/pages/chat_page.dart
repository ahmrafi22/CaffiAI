import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: BrandColors.mocha),
          const SizedBox(height: 16),
          Text(
            'Chat Page',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: BrandColors.espressoBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your personal coffee assistant',
            style: TextStyle(color: BrandColors.mediumRoast),
          ),
        ],
      ),
    );
  }
}
