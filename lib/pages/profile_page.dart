import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_page.dart';
import '../main.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../theme/brand_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = UserProfileService();
  final _displayNameCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext bottomSheetContext) async {
    setState(() => _saving = true);
    try {
      await _profileService.updateProfile(
        displayName: _displayNameCtrl.text.trim(),
        photoUrl: _photoUrlCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(bottomSheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to update profile')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openEditSheet(UserProfile profile) {
    _displayNameCtrl.text = profile.displayName ?? '';
    _photoUrlCtrl.text = profile.photoUrl ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BrandColors.latteFoam,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.espressoBrown,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _displayNameCtrl,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _photoUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  hintText: 'https://imagekit.io/your-photo.jpg',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _saveProfile(sheetCtx),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in to unlock your profile.',
              style: TextStyle(color: BrandColors.mediumRoast),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AuthPage()));
              },
              child: const Text('Go to login'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<UserProfile?>(
      stream: _profileService.watchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data;
        if (profile == null) {
          return const Center(
            child: Text(
              'Setting up your profile...'
              '\nIf this persists, try refreshing or re-login.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BrandColors.mediumRoast),
            ),
          );
        }

        final avatar = profile.photoUrl?.isNotEmpty == true
            ? NetworkImage(profile.photoUrl!)
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: BrandColors.steamedMilk,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? const Icon(
                            Icons.person,
                            size: 44,
                            color: BrandColors.mocha,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName?.isNotEmpty == true
                              ? profile.displayName!
                              : 'Coffee Lover',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.espressoBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(
                            color: BrandColors.mediumRoast,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openEditSheet(profile),
                    icon: const Icon(
                      Icons.edit,
                      color: BrandColors.espressoBrown,
                    ),
                    tooltip: 'Edit profile',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BrandColors.latteFoam,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BrandColors.steamedMilk),
                    ),
                    child: const Text(
                      'Add your name and photo so friends recognize you',
                      style: TextStyle(
                        fontSize: 12,
                        color: BrandColors.mediumRoast,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.latteFoam,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BrandColors.steamedMilk),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.espressoBrown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Display name',
                      value: profile.displayName ?? 'Not set',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Photo URL',
                      value: profile.photoUrl?.isNotEmpty == true
                          ? profile.photoUrl!
                          : 'No photo added',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Reward points',
                      value: profile.rewardPoints.toString(),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Updated',
                      value: profile.updatedAt?.toLocal().toString() ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout successful')),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: BrandColors.mocha,
                  ),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: BrandColors.mediumRoast,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: BrandColors.espressoBrown),
          ),
        ),
      ],
    );
  }
}
