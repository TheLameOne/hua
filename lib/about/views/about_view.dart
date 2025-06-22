import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../users_profile/api/user_profile_service.dart';
import '../../../users_profile/views/user_profile_view.dart';
import '../../../chat/providers/chat_provider.dart';
import '../../../utils/profile_color.dart';
import '../../../theme/app_colors.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  final UserProfileService _userProfileService = UserProfileService();
  Map<String, String?> _usersProfilePics = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usersProfilePics =
          await _userProfileService.getAllUsersProfilePic();
      setState(() {
        _usersProfilePics = usersProfilePics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToUserProfile(String username) {
    // Check if this is the current user
    final chatProvider = context.read<ChatProvider>();
    final currentUsername = chatProvider.username;

    if (username == currentUsername) {
      // Navigate to my profile page for current user
      Navigator.pushNamed(context, '/profilepage');
    } else {
      // Navigate to other user's profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileView(username: username),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        // title: Text(
        //   'Community',
        //   style: TextStyle(
        //     fontWeight: FontWeight.w600,
        //     color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        //   ),
        // ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading all members...',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAllUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_usersProfilePics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No members found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new members',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllUsers,
      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Members',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_usersProfilePics.length} ${_usersProfilePics.length == 1 ? 'member' : 'members'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final userEntry = _usersProfilePics.entries.elementAt(index);
                  final username = userEntry.key;
                  final profilePic = userEntry.value;

                  return _buildUserAvatarCard(username, profilePic, isDark);
                },
                childCount: _usersProfilePics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32), // Bottom padding
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatarCard(
      String username, String? profilePic, bool isDark) {
    return InkWell(
      onTap: () => _navigateToUserProfile(username),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            SizedBox(
              width: 64,
              height: 64,
              child: ProfileUtils.buildUserAvatar(
                profilePic: profilePic,
                username: username,
                radius: 32,
                onTap: () => _navigateToUserProfile(username),
                enableFullScreenView: false, // No full-screen in About page
              ),
            ),
            const SizedBox(height: 12),
            // Username
            Text(
              username,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 4),
            // Member indicator
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //   decoration: BoxDecoration(
            //     color:
            //         (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            //             .withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(
            //       color: (isDark
            //               ? AppColors.primaryDark
            //               : AppColors.primaryLight)
            //           .withOpacity(0.3),
            //       width: 1,
            //     ),
            //   ),
            //   child: Text(
            //     'Member',
            //     style: TextStyle(
            //       fontSize: 10,
            //       fontWeight: FontWeight.w500,
            //       color:
            //           isDark ? AppColors.primaryDark : AppColors.primaryLight,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
