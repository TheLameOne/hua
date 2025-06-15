import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hua/chat/api/chat_service.dart';
import 'package:hua/services/secure_storage_service.dart';
import 'package:hua/proto/generated/bidirectional.pbgrpc.dart';

import '../../services/notification_service.dart';
import '../models/chat_message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _username;
  StreamSubscription<Response>? _responseSubscription;
  final _notificationService = NotificationService();
  bool _isAppInForeground = true;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get username => _username;

  ChatProvider() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      await _notificationService.init();
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  /// Helper method to convert protobuf timestamp to DateTime
  DateTime _convertTimestamp(dynamic timestamp) {
    if (timestamp != null && timestamp.hasSeconds()) {
      try {
        final seconds = timestamp.seconds.toInt();
        final nanos = timestamp.hasNanos() ? timestamp.nanos : 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanos ~/ 1000000),
          isUtc: true,
        ).toLocal();
      } catch (e) {
        print('Error converting timestamp: $e');
      }
    }
    return DateTime.now();
  }

  /// Load stored username from secure storage
  Future<String?> getStoredUsername() async {
    return await _secureStorage.getUsername();
  }

  Future<void> connect(String username) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    notifyListeners();

    try {
      // Check if we have a valid token before connecting
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      await _chatService.connect();

      // Listen for responses with timestamp handling
      _responseSubscription = _chatService.responseStream?.listen(
        (response) {
          // Convert protobuf timestamp to DateTime
          DateTime messageTime = _convertTimestamp(response.createdAt);

          _addMessage(ChatMessage(
            username: response.userName,
            message: response.responseMessage,
            isOwnMessage: response.userName == _username,
            timestamp: messageTime,
          ));
        },
        onError: (error) {
          print('Error: $error');

          // Check if it's an authentication error
          if (error.toString().contains('authentication') ||
              error.toString().contains('unauthorized') ||
              error.toString().contains('401')) {
            _addMessage(ChatMessage(
              username: 'System',
              message: 'Authentication failed. Please login again.',
              isOwnMessage: false,
              timestamp: DateTime.now(),
              isSystemMessage: true,
            ));
          } else {
            _addMessage(ChatMessage(
              username: 'System',
              message: 'Connection error: $error',
              isOwnMessage: false,
              timestamp: DateTime.now(),
              isSystemMessage: true,
            ));
          }
        },
        onDone: () {
          print('Stream closed');
          _isConnected = false;
          notifyListeners();
        },
      ); // Send username
      _chatService.sendUsername(username);
      _username = username;
      _isConnected = true;

      // Save username to secure storage for future use
      await _secureStorage.saveUsername(username);

      // Process existing messages for date separators
      _processExistingMessagesForDateSeparators();

      _addMessage(ChatMessage(
        username: 'System',
        message: 'Connected as $username',
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
    } catch (e) {
      print('Failed to connect: $e');

      // Handle specific authentication errors
      String errorMessage = 'Failed to connect: $e';
      if (e.toString().contains('No authentication token found')) {
        errorMessage = 'Please login to access chat.';
      }

      _addMessage(ChatMessage(
        username: 'System',
        message: errorMessage,
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Connect using stored username if available
  Future<void> connectWithStoredUsername() async {
    final storedUsername = await getStoredUsername();
    if (storedUsername != null && storedUsername.isNotEmpty) {
      await connect(storedUsername);
    }
  }

  void sendMessage(String message) {
    if (!_isConnected || message.trim().isEmpty) return;

    try {
      _chatService.sendMessage(message);
      _addMessage(ChatMessage(
        username: _username!,
        message: message,
        isOwnMessage: true,
        timestamp: DateTime.now(), // Use current time for own messages
      ));
    } catch (e) {
      print('Failed to send message: $e');
      _addMessage(ChatMessage(
        username: 'System',
        message: 'Failed to send message: $e',
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
    }
  }

  void _addMessage(ChatMessage message) {
    // Check if we need to add a date separator before this message
    _insertDateSeparatorIfNeeded(message);

    _messages.add(message);

    // Only show notification if app is in background and message is from someone else
    if (!_isAppInForeground &&
        !message.isOwnMessage &&
        !message.isSystemMessage) {
      _notificationService.showMessageNotification(
        username: message.username,
        message: message.message,
      );
      debugPrint(
          'Notification triggered: app in foreground: $_isAppInForeground');
    } else {
      debugPrint(
          'Notification skipped: app in foreground: $_isAppInForeground');
    }

    notifyListeners();
  }

  /// Insert a date separator system message if the new message is from a different day
  /// than the last non-system message
  void _insertDateSeparatorIfNeeded(ChatMessage newMessage) {
    if (_messages.isEmpty) return;

    // Find the last non-system message
    ChatMessage? lastNonSystemMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isSystemMessage) {
        lastNonSystemMessage = _messages[i];
        break;
      }
    }

    if (lastNonSystemMessage == null) return;

    // Check if the new message is from a different day
    final lastMessageDate = DateTime(
      lastNonSystemMessage.timestamp.year,
      lastNonSystemMessage.timestamp.month,
      lastNonSystemMessage.timestamp.day,
    );

    final newMessageDate = DateTime(
      newMessage.timestamp.year,
      newMessage.timestamp.month,
      newMessage.timestamp.day,
    );

    if (lastMessageDate != newMessageDate) {
      // Add a date separator system message
      final dateMessage = ChatMessage(
        username: 'System',
        message: _formatDateSeparator(newMessage.timestamp),
        isOwnMessage: false,
        timestamp: newMessage.timestamp,
        isSystemMessage: true,
      );

      _messages.add(dateMessage);
    }
  }

  /// Format date for separator message
  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "January 15, 2024" for older dates
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      final month = months[date.month - 1];
      return '$month ${date.day}, ${date.year}';
    }
  }

  /// Process existing messages and insert date separators
  /// This is useful when loading chat history
  void _processExistingMessagesForDateSeparators() {
    if (_messages.isEmpty) return;

    final List<ChatMessage> processedMessages = [];
    DateTime? lastMessageDate;

    for (final message in _messages) {
      // Skip system messages when checking for date changes
      if (message.isSystemMessage) {
        processedMessages.add(message);
        continue;
      }

      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      // Add date separator if this is a new day
      if (lastMessageDate != null && lastMessageDate != messageDate) {
        final dateMessage = ChatMessage(
          username: 'System',
          message: _formatDateSeparator(message.timestamp),
          isOwnMessage: false,
          timestamp: message.timestamp,
          isSystemMessage: true,
        );
        processedMessages.add(dateMessage);
      }

      processedMessages.add(message);
      lastMessageDate = messageDate;
    }

    // Replace messages with processed ones
    _messages.clear();
    _messages.addAll(processedMessages);
  }

  Future<void> reconnect() async {
    if (_isConnecting) return;

    _isConnecting = true;
    notifyListeners();

    try {
      // Check if token is still valid before reconnecting
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('No valid authentication token. Please login again.');
      }

      _addMessage(ChatMessage(
        username: 'System',
        message: 'Reconnecting...',
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));

      // Cancel existing subscription if any
      await _responseSubscription?.cancel();
      _responseSubscription = null;

      // Use the service's reconnect method
      await _chatService.reconnect();

      // Set up response subscription again with timestamp handling
      _responseSubscription = _chatService.responseStream?.listen(
        (response) {
          // Convert protobuf timestamp to DateTime
          DateTime messageTime = _convertTimestamp(response.createdAt);

          _addMessage(ChatMessage(
            username: response.userName,
            message: response.responseMessage,
            isOwnMessage: response.userName == _username,
            timestamp: messageTime,
          ));
        },
        onError: (error) {
          print('Error: $error');

          // Handle authentication errors during reconnect
          if (error.toString().contains('authentication') ||
              error.toString().contains('unauthorized')) {
            _addMessage(ChatMessage(
              username: 'System',
              message: 'Session expired. Please login again.',
              isOwnMessage: false,
              timestamp: DateTime.now(),
              isSystemMessage: true,
            ));
          } else {
            _addMessage(ChatMessage(
              username: 'System',
              message: 'Connection error: $error',
              isOwnMessage: false,
              timestamp: DateTime.now(),
              isSystemMessage: true,
            ));
          }
        },
        onDone: () {
          print('Stream closed');
          _isConnected = false;
          notifyListeners();
        },
      ); // If we have a username, send it to the server
      if (_username != null && _username!.isNotEmpty) {
        _chatService.sendUsername(_username!);
        _isConnected = true;

        // Process existing messages for date separators
        _processExistingMessagesForDateSeparators();

        _addMessage(ChatMessage(
          username: 'System',
          message: 'Reconnected as $_username',
          isOwnMessage: false,
          timestamp: DateTime.now(),
          isSystemMessage: true,
        ));
      }
    } catch (e) {
      print('Failed to reconnect: $e');

      String errorMessage = 'Failed to reconnect: $e';
      if (e.toString().contains('No valid authentication token')) {
        errorMessage = 'Session expired. Please login again.';
      }

      _addMessage(ChatMessage(
        username: 'System',
        message: errorMessage,
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
      _isConnected = false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;

    try {
      await _responseSubscription?.cancel();
      await _chatService.disconnect();
      _isConnected = false;
      _username = null;

      _addMessage(ChatMessage(
        username: 'System',
        message: 'Disconnected from server',
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
    } catch (e) {
      print('Error disconnecting: $e');
    } finally {
      notifyListeners();
    }
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _isAppInForeground = false;
        break;
      default:
        break;
    }
    debugPrint(
        'App lifecycle state changed: $state, isInForeground: $_isAppInForeground');
  }

  /// Clear stored username
  Future<void> clearStoredUsername() async {
    await _secureStorage.delete(key: SecureStorageService.usernameKey);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
