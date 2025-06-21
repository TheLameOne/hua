import 'package:flutter/material.dart';
import '../api/user_profile_service.dart';
import '../model/user_profile_model.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileService _userProfileService = UserProfileService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Map to store all users' profile pictures
  Map<String, String?> _usersProfilePics = {};

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String?> get usersProfilePics => _usersProfilePics;

  /// Fetch user profile by username
  Future<void> fetchUserProfile(String username) async {
    _setLoading(true);
    _error = null;

    try {
      final profile = await _userProfileService.getUserProfile(username);
      if (profile != null) {
        _userProfile = profile;
        _error = null;
      } else {
        _error = 'Failed to fetch user profile';
        _userProfile = null;
      }
    } catch (e) {
      _error = 'Error: $e';
      _userProfile = null;
      debugPrint('Error in fetchUserProfile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch all users profile pictures
  Future<void> fetchAllUsersProfilePics() async {
    try {
      final profilePics = await _userProfileService.getAllUsersProfilePic();
      _usersProfilePics = profilePics;
      notifyListeners();
      debugPrint('Fetched ${profilePics.length} users profile pics');
    } catch (e) {
      debugPrint('Error fetching all users profile pics: $e');
    }
  }

  /// Get profile picture for a specific username
  String? getProfilePicForUsername(String username) {
    return _usersProfilePics[username];
  }

  /// Clear profile data
  void clearProfile() {
    _userProfile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get initials from username for avatar
  String getInitials(String? username) {
    if (username == null || username.isEmpty) return '';
    final nameParts = username.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return username.length > 1
        ? username.substring(0, 2).toUpperCase()
        : username[0].toUpperCase();
  }

  /// Generate color for user avatar
  Color getUserColor(String? username) {
    if (username == null || username.isEmpty) return Colors.grey;

    final List<Color> avatarColors = [
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF4F518C), // Ultra Violet
      const Color(0xFF907AD6), // Tropical Indigo
      const Color(0xFF7FDEFF), // Pale Azure
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF3B82F6), // Blue
    ];

    if (username == 'System') return Colors.grey;
    int hash = 0;
    for (var i = 0; i < username.length; i++) {
      hash = username.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return avatarColors[hash.abs() % avatarColors.length];
  }
}
