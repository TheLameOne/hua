import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  int _messageNotificationId = 0;

  /// Initialize notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize settings for Android with a proper icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        debugPrint('Received iOS notification in foreground: $title');
      },
    );

    // Apply platform specific settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    try {
      final didInit = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification tapped: ${response.payload}');
          // You can handle notification taps here
        },
      );

      debugPrint('Notification plugin initialized: $didInit');

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Request permissions on iOS and newer Android versions
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      } else if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      _isInitialized = true;
      debugPrint('Notification service fully initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Request permissions on Android 13+ (API level 33+)
  Future<void> _requestAndroidPermissions() async {
    // On Android 13+ (API 33+), notification permission must be requested via the permission_handler package.
    // You need to add permission_handler to your pubspec.yaml and import it.
    // import 'package:permission_handler/permission_handler.dart';
    try {
      if (Platform.isAndroid) {
        // Only request on Android 13+
        if (await _isAndroid13orAbove()) {
          final status = await Permission.notification.request();
          debugPrint('Android notification permission status: $status');
        }
      }
    } catch (e) {
      debugPrint('Error requesting Android permissions: $e');
    }
  }

  // Helper to check if running on Android 13+
  Future<bool> _isAndroid13orAbove() async {
    try {
      final version = int.parse((await _getAndroidSdkInt()) ?? '0');
      return version >= 33;
    } catch (_) {
      return false;
    }
  }

  // Helper to get Android SDK version
  Future<String?> _getAndroidSdkInt() async {
    try {
      // Requires 'device_info_plus' package
      // import 'package:device_info_plus/device_info_plus.dart';
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt.toString();
    } catch (_) {
      return null;
    }
  }

  // Request permissions on iOS
  Future<void> _requestIOSPermissions() async {
    try {
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (plugin != null) {
        await plugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    try {
      // Messages notification channel
      const AndroidNotificationChannel messagesChannel =
          AndroidNotificationChannel(
        'messages_channel',
        'Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Create the channel
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(messagesChannel);

      debugPrint('Android notification channel created');
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  /// Show notification for a new message
  Future<void> showMessageNotification({
    required String username,
    required String message,
  }) async {
    debugPrint('Showing message notification for: $username - $message');

    if (!_isInitialized) {
      debugPrint('Notification service not initialized, initializing now');
      await init();
    }

    try {
      // Increment ID to ensure notifications stack
      _messageNotificationId++;

      // Configure Android specific notification details
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'messages_channel',
        'Messages',
        channelDescription: 'Notifications for new chat messages',
        importance: Importance.high,
        priority: Priority.high,

        // Enable sound for chat messages
        playSound: true,
        // sound: const RawResourceAndroidNotificationSound(
        // 'message_sound'), // Optional: add a custom sound in android/app/src/main/res/raw/

        // Better vibration pattern for messages - short double vibration
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 100, 100, 100]),

        // Make notifications appear as bubbles on supported Android versions
        channelShowBadge: true,

        // Use system default icon or app icon
        icon: '@mipmap/ic_launcher',

        // Use a light blue color as accent
        color: const Color(0xFF4C9EF8),

        // This is a message notification
        category: AndroidNotificationCategory.message,

        // Group messages by conversation
        groupKey: 'chat_app_messages',

        // Show message preview in notification
        styleInformation: const BigTextStyleInformation(''),

        // Don't take over the screen
        fullScreenIntent: false,

        // Allow notification to be dismissed by user
        autoCancel: true,

        // Allow heads-up notification
        ticker: 'New message',
      );

      // Configure iOS specific notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'chat',
      );

      // Create platform-specific notification details
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        _messageNotificationId,
        username,
        message,
        notificationDetails,
        payload: 'message:$username',
      );

      debugPrint(
          'Message notification shown: $username - $_messageNotificationId');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
