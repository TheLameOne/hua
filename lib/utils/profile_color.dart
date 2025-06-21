import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for managing profile-related UI elements like avatars, colors, and images
class ProfileUtils {
  // In-memory cache for processed images
  static final Map<String, ImageProvider> _imageCache = {};
  static final Map<String, bool> _validationCache = {};

  // Cache expiry time (30 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 30);
  static final Map<String, DateTime> _cacheTimestamps = {};

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
  /// Handles base64 data, URLs, and error cases with robust validation and caching
  static ImageProvider? getProfileImageProvider(String? profilePic) {
    if (profilePic == null || profilePic.isEmpty) {
      return null;
    }

    // Check cache first
    final cacheKey = profilePic.hashCode.toString();
    if (_imageCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _imageCache[cacheKey];
      } else {
        // Cache expired, remove from cache
        _clearExpiredCacheEntry(cacheKey);
      }
    }

    try {
      ImageProvider? imageProvider;

      // Handle network image URLs first (with caching)
      if (profilePic.startsWith('http')) {
        imageProvider = CachedNetworkImageProvider(
          profilePic,
          cacheKey: cacheKey,
          errorListener: (error) {
            debugPrint('Network image loading error: $error');
          },
        );
        _cacheImageProvider(cacheKey, imageProvider);
        return imageProvider;
      }

      // Handle base64 image data with validation
      String base64Data = profilePic;

      // Strip data URL prefix if present (e.g., "data:image/jpeg;base64,")
      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last.trim();
      }

      // Check validation cache first
      bool isValid = _validationCache[cacheKey] ?? false;
      if (!_validationCache.containsKey(cacheKey)) {
        isValid = _isValidBase64(base64Data);
        _validationCache[cacheKey] = isValid;
      }

      if (!isValid) {
        debugPrint('Invalid base64 format for profile image (cached result)');
        return null;
      }

      // Try to decode as base64
      final Uint8List bytes = base64Decode(base64Data);

      // Validate that decoded data is reasonable for an image
      if (bytes.length < 100) {
        debugPrint('Image data too small, likely corrupted');
        return null;
      }

      imageProvider = MemoryImage(bytes);
      _cacheImageProvider(cacheKey, imageProvider);
      return imageProvider;
    } catch (e) {
      // Log the error and return null to show default avatar
      debugPrint('Failed to process profile image: $e');
      return null;
    }
  }

  /// Cache an image provider with timestamp
  static void _cacheImageProvider(
      String cacheKey, ImageProvider imageProvider) {
    _imageCache[cacheKey] = imageProvider;
    _cacheTimestamps[cacheKey] = DateTime.now();

    // Limit cache size to prevent memory issues
    if (_imageCache.length > 100) {
      _cleanupOldCacheEntries();
    }
  }

  /// Clear expired cache entry
  static void _clearExpiredCacheEntry(String cacheKey) {
    _imageCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    _validationCache.remove(cacheKey);
  }

  /// Clean up old cache entries to prevent memory bloat
  static void _cleanupOldCacheEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        keysToRemove.add(key);
      }
    });

    // Remove oldest entries if still too many
    if (keysToRemove.length < _imageCache.length - 50) {
      final sortedEntries = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      for (int i = 0; i < _imageCache.length - 50; i++) {
        keysToRemove.add(sortedEntries[i].key);
      }
    }

    for (final key in keysToRemove) {
      _clearExpiredCacheEntry(key);
    }
  }

  /// Clear all caches (useful for logout or memory management)
  static void clearAllCaches() {
    _imageCache.clear();
    _cacheTimestamps.clear();
    _validationCache.clear();
  }

  /// Validates if a string is properly formatted base64
  static bool _isValidBase64(String base64String) {
    if (base64String.isEmpty) return false;

    // Remove whitespace and check basic format
    final cleaned = base64String.replaceAll(RegExp(r'\s'), '');

    // Base64 strings should be multiples of 4 characters (with padding)
    if (cleaned.length % 4 != 0) return false;

    // Check if string contains only valid base64 characters
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64Pattern.hasMatch(cleaned)) return false;

    // Additional length check - too short to be a meaningful image
    if (cleaned.length < 100) return false;

    return true;
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
      backgroundColor: color, // Always set background color as fallback
      radius: radius,
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null
          ? (exception, stackTrace) {
              debugPrint(
                  'Avatar image loading error for user $username: $exception');
              // The avatar will automatically fall back to showing initials
              // when the background image fails to load
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

  /// Preload and cache profile images for better performance
  static Future<void> preloadProfileImages(List<String> profilePics) async {
    final List<Future<void>> preloadTasks = [];

    for (final profilePic in profilePics) {
      if (profilePic.isNotEmpty) {
        preloadTasks.add(_preloadSingleImage(profilePic));
      }
    }

    // Wait for all preloading tasks to complete (with timeout)
    try {
      await Future.wait(preloadTasks).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Profile image preloading timed out');
          return [];
        },
      );
    } catch (e) {
      debugPrint('Error preloading profile images: $e');
    }
  }

  /// Preload a single image
  static Future<void> _preloadSingleImage(String profilePic) async {
    try {
      final imageProvider = getProfileImageProvider(profilePic);
      if (imageProvider != null) {
        // Force the image to load by resolving it
        final imageStream = imageProvider.resolve(ImageConfiguration.empty);
        final completer = Completer<void>();

        imageStream.addListener(
          ImageStreamListener(
            (info, synchronousCall) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            onError: (error, stackTrace) {
              if (!completer.isCompleted) {
                completer.completeError(error);
              }
            },
          ),
        );

        await completer.future.timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }

  /// Get cache statistics (useful for debugging)
  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int expiredEntries = 0;

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredEntries++;
      }
    });

    return {
      'totalCachedImages': _imageCache.length,
      'validationCacheSize': _validationCache.length,
      'expiredEntries': expiredEntries,
      'cacheHitRate': _imageCache.length > 0
          ? '${((_imageCache.length - expiredEntries) / _imageCache.length * 100).toStringAsFixed(1)}%'
          : '0%',
    };
  }
}
