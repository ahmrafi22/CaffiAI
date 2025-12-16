import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../theme/brand_colors.dart';
import '../models/user_profile_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final UserProfileService _profileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Welcome to CaffiAI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: BrandColors.espressoBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover personalized brews, rewards, and coffee insights.',
            style: TextStyle(color: BrandColors.mediumRoast),
          ),
          const SizedBox(height: 24),
          StreamBuilder<UserProfile?>(
            stream: _profileService.watchProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = snapshot.data;
              if (profile == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.latteFoam,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BrandColors.steamedMilk),
                  ),
                  child: const Text(
                    'Sign in to see your personalized recommendations.',
                    style: TextStyle(color: BrandColors.mediumRoast),
                  ),
                );
              }

              final greetingName =
                  profile.displayName?.trim().isNotEmpty == true
                  ? profile.displayName!
                  : 'Coffee Lover';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.latteFoam,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BrandColors.steamedMilk),
                  boxShadow: [
                    BoxShadow(
                      color: BrandColors.steamedMilk.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $greetingName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.espressoBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reward points: ${profile.rewardPoints}',
                      style: const TextStyle(
                        color: BrandColors.mediumRoast,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
