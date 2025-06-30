import 'package:flutter/material.dart';
import 'package:hua/theme/app_colors.dart';
import 'package:hua/users_profile/model/user_profile_model.dart';
import 'package:hua/users_profile/api/user_profile_service.dart';
import 'package:hua/utils/profile_color.dart';

class UserSelectionDialog extends StatefulWidget {
  final bool isVideoCall;
  final Function(List<UserProfile> selectedUsers) onUsersSelected;

  const UserSelectionDialog({
    Key? key,
    required this.isVideoCall,
    required this.onUsersSelected,
  }) : super(key: key);

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  final UserProfileService _userProfileService = UserProfileService();
  List<UserProfile> _allUsers = [];
  List<UserProfile> _selectedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final users = await _userProfileService.getAllUsersForCallSelection();

      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(UserProfile user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _startCall() {
    if (_selectedUsers.isNotEmpty) {
      widget.onUsersSelected(_selectedUsers);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.call,
                  color:
                      isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isVideoCall
                        ? 'Start Video Call'
                        : 'Start Voice Call',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select users to call',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Selected users count
            if (_selectedUsers.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${_selectedUsers.length} user${_selectedUsers.length != 1 ? 's' : ''} selected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                ),
              ),
            if (_selectedUsers.isNotEmpty) const SizedBox(height: 16),

            // Users list
            Expanded(
              child: _buildUsersList(),
            ),

            // Action buttons
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedUsers.isNotEmpty ? _startCall : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isVideoCall
                          ? 'Start Video Call'
                          : 'Start Voice Call',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? AppColors.errorDark : AppColors.errorLight,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No users available',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        final isSelected = _selectedUsers.contains(user);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => _toggleUserSelection(user),
            leading: ProfileUtils.buildUserChatAvatar(
              username: user.username,
              profilePic: user.profilePic,
              radius: 24,
              enableFullScreenView: false,
            ),
            title: Text(
              user.username,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Text(
              'ID: ${user.id.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
