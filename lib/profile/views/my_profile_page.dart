import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hua/theme/app_colors.dart';
import 'package:hua/utils/profile_color.dart';
import '../providers/my_profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isEditingBio = false;

  @override
  void initState() {
    super.initState();
    // Fetch profile data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyProfileProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
      ),
      body: Consumer<MyProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading && profileProvider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? AppColors.errorDark : AppColors.errorLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error!,
                    style: TextStyle(
                      color:
                          isDark ? AppColors.errorDark : AppColors.errorLight,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.clearError();
                      profileProvider.fetchProfile();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = profileProvider.profile;
          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(profile, isDark, profileProvider),
                const SizedBox(height: 32),

                // Username Section
                _buildUsernameSection(profile, isDark),
                const SizedBox(height: 24),

                // Bio Section
                _buildBioSection(profile, isDark, profileProvider),

                if (profileProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePictureSection(
      profile, bool isDark, MyProfileProvider profileProvider) {
    return Column(
      children: [
        Stack(
          children: [
            ProfileUtils.buildFullScreenProfileAvatar(
              username: profile.username,
              profilePic: profile.profilePic,
              radius: 60,
              onTap: () => _pickImage(profileProvider),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickImage(profileProvider),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap camera icon to change photo',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameSection(profile, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Username',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.username,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(
      profile, bool isDark, MyProfileProvider profileProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bio',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!_isEditingBio)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingBio = true;
                      _bioController.text = profile.bio ?? '';
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditingBio)
            Column(
              children: [
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your bio...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingBio = false;
                          _bioController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _saveBio(profileProvider),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              profile.bio ?? 'No bio added yet',
              style: TextStyle(
                color: profile.bio != null
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                fontSize: 14,
                fontStyle:
                    profile.bio == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(MyProfileProvider profileProvider) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final success = await profileProvider.updateProfilePicture(imageFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Profile picture updated successfully!'
                  : 'Failed to update profile picture'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveBio(MyProfileProvider profileProvider) async {
    final bio = _bioController.text.trim();
    final success = await profileProvider.updateBio(bio);

    if (mounted) {
      setState(() {
        _isEditingBio = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Bio updated successfully!' : 'Failed to update bio'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
