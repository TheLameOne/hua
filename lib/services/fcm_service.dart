import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:hua/services/secure_storage_service.dart';

/// A service that handles Firebase Cloud Messaging (FCM) operations
class FCMService {
  // Singleton instance
  static final FCMService _instance = FCMService._internal();

  // Factory constructor to return the same instance every time
  factory FCMService() => _instance;

  // Private constructor for singleton pattern
  FCMService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final SecureStorageService _secureStorage = SecureStorageService();
  final Dio _dio = Dio();

  /// Keys used for storing FCM data
  static const String lastTokenSentKey = 'last_fcm_token_sent';

  /// API endpoint for updating user FCM token
  static const String _updateTokenEndpoint = 'https://api.geonotes.in/api/user';

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      debugPrint('Starting FCM service initialization...');

      // Initialize Firebase if not already initialized
      try {
        await Firebase.initializeApp();
        debugPrint('Firebase initialized successfully');
      } catch (e) {
        // Check if this is a configuration error
        if (e.toString().contains('Failed to load FirebaseOptions') ||
            e.toString().contains('values.xml')) {
          debugPrint(
              'Firebase configuration files missing. Skipping FCM initialization.');
          debugPrint('To enable FCM, please run: flutterfire configure');
          return;
        }
        // For other errors, Firebase might already be initialized
        debugPrint('Firebase initialization result: $e');
      }

      // Initialize Firebase Messaging after Firebase Core is ready
      _firebaseMessaging = FirebaseMessaging.instance;
      debugPrint('Firebase Messaging instance created');

      // Request notification permissions
      NotificationSettings settings =
          await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      // Check and update FCM token if needed
      await checkAndUpdateFCMToken();

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((String token) {
        debugPrint('FCM token refreshed: $token');
        _updateFCMTokenInBackend(token);
      });

      debugPrint('FCM service initialization completed successfully');
    } catch (e) {
      debugPrint('Error initializing FCM service: $e');
      debugPrint(
          'FCM features will be disabled. To enable, please configure Firebase.');
    }
  }

  /// Get the current FCM token from the device
  Future<String?> getFCMToken() async {
    try {
      if (_firebaseMessaging == null) {
        debugPrint('Firebase Messaging not initialized');
        return null;
      }

      String? token = await _firebaseMessaging!.getToken();
      debugPrint('Current FCM token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Get the last FCM token that was sent to the backend
  Future<String?> getLastTokenSent() async {
    try {
      return await _secureStorage.read(key: lastTokenSentKey);
    } catch (e) {
      debugPrint('Error getting last token sent: $e');
      return null;
    }
  }

  /// Save the last FCM token that was sent to the backend
  Future<bool> saveLastTokenSent(String token) async {
    try {
      return await _secureStorage.write(key: lastTokenSentKey, value: token);
    } catch (e) {
      debugPrint('Error saving last token sent: $e');
      return false;
    }
  }

  /// Check if FCM token has changed and update backend if needed
  Future<void> checkAndUpdateFCMToken() async {
    if (_firebaseMessaging == null) {
      debugPrint('Firebase Messaging not available, skipping FCM token check');
      return;
    }

    try {
      // Get current FCM token from device
      String? currentToken = await getFCMToken();
      if (currentToken == null) {
        debugPrint('No FCM token available');
        return;
      }

      // Get last token sent to backend
      String? lastTokenSent = await getLastTokenSent();

      // Compare tokens - if they don't match, update backend
      if (currentToken != lastTokenSent) {
        debugPrint(
            'FCM token changed. Current: ${currentToken.substring(0, 20)}..., Last sent: ${lastTokenSent?.substring(0, 20) ?? 'null'}...');
        await _updateFCMTokenInBackend(currentToken);
      } else {
        debugPrint('FCM token unchanged, no update needed');
      }
    } catch (e) {
      debugPrint('Error checking and updating FCM token: $e');
    }
  }

  /// Update FCM token in the backend
  Future<bool> _updateFCMTokenInBackend(String token) async {
    try {
      // Get authentication token from secure storage
      String? authToken = await _secureStorage.getToken();
      if (authToken == null) {
        debugPrint('No authentication token found, cannot update FCM token');
        return false;
      }

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'fcmToken': token,
      };

      // Configure Dio options
      final Options options = Options(
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('Updating FCM token in backend: $token');

      // Make API call
      final Response response = await _dio.request(
        _updateTokenEndpoint,
        data: requestData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('FCM token updated successfully');

        // Save the token as last sent
        await saveLastTokenSent(token);
        return true;
      } else {
        debugPrint(
            'Failed to update FCM token. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating FCM token in backend: $e');
      return false;
    }
  }

  /// Force update FCM token (useful for manual refresh)
  Future<bool> forceUpdateFCMToken() async {
    if (_firebaseMessaging == null) {
      debugPrint(
          'Firebase Messaging not available, cannot force update FCM token');
      return false;
    }

    try {
      String? currentToken = await getFCMToken();
      if (currentToken == null) {
        debugPrint('No FCM token available for force update');
        return false;
      }

      return await _updateFCMTokenInBackend(currentToken);
    } catch (e) {
      debugPrint('Error force updating FCM token: $e');
      return false;
    }
  }

  /// Clear stored FCM data (useful during logout)
  Future<bool> clearFCMData() async {
    try {
      await _secureStorage.delete(key: lastTokenSentKey);
      debugPrint('FCM data cleared');
      return true;
    } catch (e) {
      debugPrint('Error clearing FCM data: $e');
      return false;
    }
  }

  /// Delete FCM token from device (call during logout)
  Future<void> deleteFCMToken() async {
    try {
      if (_firebaseMessaging != null) {
        await _firebaseMessaging!.deleteToken();
      }
      await clearFCMData();
      debugPrint('FCM token deleted from device');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
