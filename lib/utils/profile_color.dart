import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Utility class for managing profile-related UI elements like avatars, colors, and images
class ProfileUtils {
  // Consistent avatar colors used across the app
  static const List<Color> _avatarColors = [
    Color(0xFF9C27B0), // Material Purple - good contrast in both themes
    Color(0xFFE91E63), // Material Pink - vibrant and visible
    Color(0xFF673AB7), // Deep Purple - balanced visibility
    Color(0xFF3F51B5), // Material Indigo - works well in both modes
    Color(0xFF2196F3), // Material Blue - excellent contrast
    Color(0xFF00BCD4), // Material Cyan - bright and clear
    Color(0xFF009688), // Material Teal - good saturation
    Color(0xFFFF9800), // Material Orange - high visibility
  ];

  /// Get a consistent color for a user based on their username
  static Color getUserColor(String? username) {
    if (username == null || username.isEmpty) return Colors.grey;
    if (username == 'System') return Colors.grey;

    int hash = 0;
    for (var i = 0; i < username.length; i++) {
      hash = username.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return _avatarColors[hash.abs() % _avatarColors.length];
  }

  /// Get initials from a username for avatar display
  static String getInitials(String? username) {
    if (username == null || username.isEmpty) return '';

    final nameParts = username.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return username.length > 1
        ? username.substring(0, 2).toUpperCase()
        : username[0].toUpperCase();
  }

  /// Process profile picture data and return appropriate ImageProvider
  /// Handles base64 data, URLs, and error cases
  static ImageProvider? getProfileImageProvider(String? profilePic) {
    if (profilePic == null || profilePic.isEmpty) {
      return null;
    }

    try {
      // Handle base64 image data
      String base64Data = profilePic;

      // Strip data URL prefix if present (e.g., "data:image/jpeg;base64,")
      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last.trim();
      }

      // Try to decode as base64
      final Uint8List bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (e) {
      // If it's not base64, try as network image URL
      if (profilePic.startsWith('http')) {
        return NetworkImage(profilePic);
      }
      // If all fails, return null to show default avatar
      debugPrint('Failed to process profile image: $e');
      return null;
    }
  }

  /// Build a complete user avatar widget with consistent styling
  static Widget buildUserAvatar({
    required String username,
    String? profilePic,
    required double radius,
    double? fontSize,
    VoidCallback? onTap,
    List<BoxShadow>? boxShadow,
  }) {
    final color = getUserColor(username);
    final initials = getInitials(username);
    final imageProvider = getProfileImageProvider(profilePic);

    Widget avatar = CircleAvatar(
      backgroundColor: imageProvider != null ? Colors.transparent : color,
      radius: radius,
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null
          ? (exception, stackTrace) {
              debugPrint('Avatar image loading error: $exception');
            }
          : null,
      child: imageProvider == null
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize ?? radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    // Wrap with container for shadow if provided
    if (boxShadow != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: boxShadow,
        ),
        child: avatar,
      );
    }

    // Wrap with GestureDetector if onTap provided
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build a user avatar with default shadow styling
  static Widget buildUserAvatarWithShadow({
    required String username,
    String? profilePic,
    required double radius,
    double? fontSize,
    VoidCallback? onTap,
  }) {
    final color = getUserColor(username);

    return buildUserAvatar(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: fontSize,
      onTap: onTap,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Create a material-style avatar for chat messages
  static Widget buildChatAvatar({
    required String username,
    String? profilePic,
    double radius = 16,
    VoidCallback? onTap,
  }) {
    return buildUserAvatar(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: radius * 0.5,
      onTap: onTap,
    );
  }

  static Widget buildUserChatAvatar({
    required String username,
    String? profilePic,
    double radius = 16,
    VoidCallback? onTap,
  }) {
    return buildUserAvatar(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: radius * 0.7,
      onTap: onTap,
    );
  }

  /// Create a profile page style avatar with shadow and larger size
  static Widget buildProfileAvatar({
    required String username,
    String? profilePic,
    double radius = 60,
    VoidCallback? onTap,
  }) {
    return buildUserAvatarWithShadow(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: radius * 0.55, // Increased from 0.4 to 0.55 for larger text
      onTap: onTap,
    );
  }
}
