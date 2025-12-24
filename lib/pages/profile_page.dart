import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/user_profile_model.dart';
import '../services/firebase_service.dart';
import '../services/user_profile_service.dart';
import '../theme/brand_colors.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = UserProfileService();
  final _displayNameCtrl = TextEditingController();
  final _coffeeTypeCtrl = TextEditingController();
  final _coffeeStrengthCtrl = TextEditingController();
  final _temperatureCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  bool _saving = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _coffeeTypeCtrl.dispose();
    _coffeeStrengthCtrl.dispose();
    _temperatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _saveProfile(BuildContext bottomSheetContext) async {
    setState(() => _saving = true);
    try {
      final Map<String, dynamic> preferences = {};
      if (_coffeeTypeCtrl.text.trim().isNotEmpty) {
        preferences['coffeeType'] = _coffeeTypeCtrl.text.trim();
      }
      if (_coffeeStrengthCtrl.text.trim().isNotEmpty) {
        preferences['coffeeStrength'] = _coffeeStrengthCtrl.text.trim();
      }
      if (_temperatureCtrl.text.trim().isNotEmpty) {
        preferences['temperature'] = _temperatureCtrl.text.trim();
      }

      await _profileService.updateProfile(
        displayName: _displayNameCtrl.text.trim().isEmpty
            ? null
            : _displayNameCtrl.text.trim(),
        preferences: preferences.isEmpty ? null : preferences,
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
      if (mounted) {
        setState(() {
          _saving = false;
          _pickedImage = null;
        });
      }
    }
  }

  void _openEditSheet(UserProfile profile) {
    _displayNameCtrl.text = profile.displayName ?? '';
    _coffeeTypeCtrl.text = profile.preferences?['coffeeType']?.toString() ?? '';
    _coffeeStrengthCtrl.text =
        profile.preferences?['coffeeStrength']?.toString() ?? '';
    _temperatureCtrl.text =
        profile.preferences?['temperature']?.toString() ?? '';
    _pickedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BrandColors.latteFoam,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
        final bottomPadding = MediaQuery.of(sheetCtx).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + bottomPadding + 20,
          ),
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: BrandColors.steamedMilk,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (profile.photoUrl?.isNotEmpty == true
                                        ? NetworkImage(profile.photoUrl!)
                                        : null)
                                    as ImageProvider?,
                          child:
                              _pickedImage == null &&
                                  (profile.photoUrl?.isEmpty != false)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: BrandColors.mocha,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: BrandColors.caramel,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _displayNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _coffeeTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Coffee Type',
                    hintText: 'e.g., Espresso, Cappuccino, Latte',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _coffeeStrengthCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Coffee Strength',
                    hintText: 'e.g., Light, Medium, Strong',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _temperatureCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                    hintText: 'e.g., Hot, Iced, Warm',
                  ),
                ),
                const SizedBox(height: 24),
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
                        : const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = firebase.currentUser;
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Box at the top
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BrandColors.latteFoam,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Edit button at top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () => _openEditSheet(profile),
                        icon: const Icon(
                          Icons.edit,
                          color: BrandColors.espressoBrown,
                          size: 22,
                        ),
                        tooltip: 'Edit profile',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    // Profile content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo on left
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: BrandColors.steamedMilk,
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: BrandColors.mocha,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Name and email on right
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, right: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name - Primary text hierarchy
                                Text(
                                  profile.displayName?.isNotEmpty == true
                                      ? profile.displayName!
                                      : 'Coffee Lover',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: BrandColors.deepEspresso,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Email - Secondary text hierarchy
                                Text(
                                  user.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: BrandColors.mediumRoast,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Reward Points Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.cinnamon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: BrandColors.cinnamon.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reward Points',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.espressoBrown,
                      ),
                    ),
                    Text(
                      profile.rewardPoints.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.cinnamon,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Preferences Section
              if (profile.preferences != null &&
                  profile.preferences!.isNotEmpty) ...[
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (profile.preferences?['coffeeType'] != null)
                      _PreferenceCapsule(
                        label: profile.preferences!['coffeeType'].toString(),
                        backgroundColor: BrandColors.mintGreen.withValues(
                          alpha: 0.2,
                        ),
                        textColor: BrandColors.espressoBrown,
                      ),
                    if (profile.preferences?['coffeeStrength'] != null)
                      _PreferenceCapsule(
                        label: profile.preferences!['coffeeStrength']
                            .toString(),
                        backgroundColor: BrandColors.caramel.withValues(
                          alpha: 0.15,
                        ),
                        textColor: BrandColors.espressoBrown,
                      ),
                    if (profile.preferences?['temperature'] != null)
                      _PreferenceCapsule(
                        label: profile.preferences!['temperature'].toString(),
                        backgroundColor: BrandColors.mocha.withValues(
                          alpha: 0.15,
                        ),
                        textColor: BrandColors.espressoBrown,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 24),
              // Recent Orders Section
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.deepEspresso,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _OrderCard(
                    coffeeType: 'Espresso',
                    storeName: 'Brew Masters',
                    price: 450,
                    rating: 4.8,
                    icon: Icons.local_cafe,
                  ),
                  const SizedBox(height: 12),
                  _OrderCard(
                    coffeeType: 'Cappuccino',
                    storeName: 'Artisan Roasters',
                    price: 525,
                    rating: 4.6,
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 12),
                  _OrderCard(
                    coffeeType: 'Latte',
                    storeName: 'Bean & Brew',
                    price: 575,
                    rating: 4.9,
                    icon: Icons.local_drink,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Sign out button
              Center(
                child: TextButton(
                  onPressed: () async {
                    await firebase.auth.signOut();
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

// Preference Capsule Widget
class _PreferenceCapsule extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _PreferenceCapsule({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// Recent Order Card Widget
class _OrderCard extends StatelessWidget {
  final String coffeeType;
  final String storeName;
  final double price;
  final double rating;
  final IconData icon;

  const _OrderCard({
    required this.coffeeType,
    required this.storeName,
    required this.price,
    required this.rating,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.latteFoam,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.steamedMilk, width: 1),
      ),
      child: Row(
        children: [
          // Coffee icon in circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: BrandColors.caramel.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: BrandColors.caramel, size: 30),
          ),
          const SizedBox(width: 16),
          // Coffee details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coffeeType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: BrandColors.mediumRoast,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: BrandColors.caramel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${rating.toStringAsFixed(1)})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: BrandColors.mediumRoast,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price
          Text(
            '\TK${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BrandColors.espressoBrown,
            ),
          ),
        ],
      ),
    );
  }
}
