import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: BrandColors.mocha),
          const SizedBox(height: 16),
          Text(
            'Community Page',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: BrandColors.espressoBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with coffee lovers',
            style: TextStyle(color: BrandColors.mediumRoast),
          ),
        ],
      ),
    );
  }
}
