import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_screen_image_viewer.dart';

/// Utility class for managing profile-related UI elements like avatars, colors, and images
class ProfileUtils {
  // In-memory cache for processed images
  static final Map<String, ImageProvider> _imageCache = {};
  static final Map<String, bool> _validationCache = {};

  // Cache expiry time (30 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 30);
  static final Map<String, DateTime> _cacheTimestamps =
      {}; // Expanded avatar colors palette with vibrant colors for maximum visual impact
  static const List<Color> _avatarColors = [
    Color(0xFFFF3D00), // Vibrant Red Orange - electric and bold
    Color(0xFFE91E63), // Hot Pink - already vibrant and visible
    Color(0xFF00E676), // Neon Green - electric and fresh
    Color(0xFFFF1744), // Bright Red - intense and energetic
    Color(0xFF2979FF), // Electric Blue - vibrant and modern
    Color(0xFF00E5FF), // Cyan Accent - bright and electric
    Color(0xFF1DE9B6), // Teal Accent - vibrant aqua
    Color(
        0xFFFF6D00), // Orange Accent - warm and vibrant    Color(0xFF8E24AA), // Purple 600 - rich and vibrant
    Color(0xFFAB47BC), // Purple 400 - bright and visible purple
    Color(0xFF76FF03), // Light Green Accent - neon lime
    Color(0xFFFFEA00), // Yellow Accent - bright sunshine
    Color(0xFFFF4081), // Pink Accent - electric pink
    Color(0xFFFF5722), // Deep Orange 500 - vibrant warm
    Color(0xFF9C27B0), // Purple 500 - rich magenta
    Color(0xFF00ACC1), // Cyan 600 - deep vibrant cyan
    Color(0xFF3F51B5), // Indigo 500 - electric indigo
    Color(0xFF4CAF50), // Green 500 - vibrant natural
    Color(
        0xFFF44336), // Red 500 - classic vibrant red    Color(0xFFFF9800), // Orange 500 - bright orange
    Color(0xFF607D8B), // Blue Grey 500 - modern steel
    Color(0xFFD84315), // Deep Orange 800 - vibrant earthy orange
    Color(0xFFFFEB3B), // Yellow 500 - golden bright
    Color(0xFFE91E63), // Pink 500 - vibrant magenta pink
  ];

  /// Get a consistent color for a user based on their username
  static Color getUserColor(String? username) {
    if (username == null || username.isEmpty) return Colors.grey;
    if (username == 'System') return Colors.grey;

    // Advanced hash function with excellent distribution properties
    int hash = 0x811c9dc5; // FNV-1a initial hash value

    // FNV-1a hash algorithm with additional mixing
    for (var i = 0; i < username.length; i++) {
      int char = username.codeUnitAt(i);
      hash ^= char;
      hash *= 0x01000193; // FNV-1a prime
      hash = hash & 0xFFFFFFFF; // Keep as 32-bit
    }

    // Additional avalanche mixing for better distribution
    hash ^= hash >> 16;
    hash *= 0x21f0aaad;
    hash ^= hash >> 15;
    hash *= 0x735a2d97;
    hash ^= hash >> 15;

    // Final mixing with username length for even better distribution
    hash ^= username.length;
    hash *= 0x9e3779b9; // Golden ratio based constant
    hash ^= hash >> 16;

    return _avatarColors[hash.abs() % _avatarColors.length];
    // return _avatarColors[7];
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
    bool enableFullScreenView = false,
  }) {
    final color = getUserColor(username);
    final initials = getInitials(username);
    final imageProvider = getProfileImageProvider(profilePic);

    // Build the base avatar
    Widget avatar = CircleAvatar(
      backgroundColor: imageProvider != null ? Colors.transparent : color,
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

    // Build the complete widget structure in one go
    return Builder(
      builder: (BuildContext context) {
        Widget finalAvatar = avatar;

        // Add Hero wrapper if full screen is enabled and image exists
        if (enableFullScreenView && imageProvider != null) {
          finalAvatar = Hero(
            tag: 'profile_image_$username',
            child: finalAvatar,
          );
        }

        // Add shadow container if provided
        if (boxShadow != null) {
          finalAvatar = Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: boxShadow,
            ),
            child: finalAvatar,
          );
        }

        // Add gesture detector if needed
        if (onTap != null || (enableFullScreenView && imageProvider != null)) {
          finalAvatar = GestureDetector(
            onTap: () {
              if (enableFullScreenView && imageProvider != null) {
                // Open full screen image viewer when image exists
                _openFullScreenImageViewer(
                  imageProvider: imageProvider,
                  username: username,
                  context: context,
                );
              } else if (onTap != null) {
                // Fallback to custom onTap when no image or full screen disabled
                onTap();
              }
            },
            child: finalAvatar,
          );
        }

        return finalAvatar;
      },
    );
  }

  /// Open full screen image viewer
  static void _openFullScreenImageViewer({
    required ImageProvider imageProvider,
    required String username,
    BuildContext? context,
  }) {
    // Use the provided context or try to find one from the widget tree
    BuildContext? targetContext = context;

    if (targetContext == null) {
      // Try to get context from the current focus
      targetContext =
          WidgetsBinding.instance.focusManager.primaryFocus?.context;
    }

    if (targetContext != null) {
      Navigator.of(targetContext).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black,
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation,
              child: FullScreenImageViewer(
                imageProvider: imageProvider,
                username: username,
                heroTag: 'profile_image_$username',
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
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
          blurRadius: 0,
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
    bool enableFullScreenView = false,
  }) {
    return buildUserAvatar(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: radius * 0.7,
      onTap: onTap,
      enableFullScreenView: enableFullScreenView,
    );
  }

  /// Create a profile page style avatar with larger size
  static Widget buildProfileAvatar({
    required String username,
    String? profilePic,
    double radius = 60,
    VoidCallback? onTap,
    bool enableFullScreenView = false,
  }) {
    return buildUserAvatar(
      username: username,
      profilePic: profilePic,
      radius: radius,
      fontSize: radius * 0.55, // Increased from 0.4 to 0.55 for larger text
      onTap: onTap,
      enableFullScreenView: enableFullScreenView,
    );
  }

  /// Create a profile page avatar with full-screen viewing capability
  static Widget buildFullScreenProfileAvatar({
    required String username,
    String? profilePic,
    double radius = 60,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final imageProvider = getProfileImageProvider(profilePic);

        return GestureDetector(
          onTap: () {
            if (imageProvider != null) {
              // Open full screen image viewer when image exists
              _openFullScreenImageViewer(
                imageProvider: imageProvider,
                username: username,
                context: context,
              );
            } else if (onTap != null) {
              // Fallback to custom onTap when no image (e.g., image picker)
              onTap();
            }
          },
          child: Hero(
            tag: 'profile_image_$username',
            child: buildUserAvatar(
              username: username,
              profilePic: profilePic,
              radius: radius,
              fontSize: radius * 0.55,
            ),
          ),
        );
      },
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
