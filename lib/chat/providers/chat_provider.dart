import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hua/chat/api/chat_service.dart';
import 'package:hua/services/secure_storage_service.dart';
import 'package:hua/proto/generated/bidirectional.pbgrpc.dart';

import '../../services/notification_service.dart';

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

  /// Load stored username from secure storage
  Future<String?> getStoredUsername() async {
    return await _secureStorage.getUsername();
  }

  Future<void> connect(String username) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    notifyListeners();

    try {
      await _chatService.connect();

      // Listen for responses
      _responseSubscription = _chatService.responseStream?.listen(
        (response) {
          _addMessage(ChatMessage(
            username: response.userName,
            message: response.responseMessage,
            isOwnMessage: response.userName == _username,
            timestamp: DateTime.now(),
          ));
        },
        onError: (error) {
          print('Error: $error');
          _addMessage(ChatMessage(
            username: 'System',
            message: 'Connection error: $error',
            isOwnMessage: false,
            timestamp: DateTime.now(),
            isSystemMessage: true,
          ));
        },
        onDone: () {
          print('Stream closed');
          _isConnected = false;
          notifyListeners();
        },
      );

      // Send username
      _chatService.sendUsername(username);
      _username = username;
      _isConnected = true;

      // Save username to secure storage for future use
      await _secureStorage.saveUsername(username);

      _addMessage(ChatMessage(
        username: 'System',
        message: 'Connected as $username',
        isOwnMessage: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      ));
    } catch (e) {
      print('Failed to connect: $e');
      _addMessage(ChatMessage(
        username: 'System',
        message: 'Failed to connect: $e',
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
        timestamp: DateTime.now(),
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

  Future<void> reconnect() async {
    if (_isConnecting) return;

    _isConnecting = true;
    notifyListeners();

    try {
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

      // Set up response subscription again
      _responseSubscription = _chatService.responseStream?.listen(
        (response) {
          _addMessage(ChatMessage(
            username: response.userName,
            message: response.responseMessage,
            isOwnMessage: response.userName == _username,
            timestamp: DateTime.now(),
          ));
        },
        onError: (error) {
          print('Error: $error');
          _addMessage(ChatMessage(
            username: 'System',
            message: 'Connection error: $error',
            isOwnMessage: false,
            timestamp: DateTime.now(),
            isSystemMessage: true,
          ));
        },
        onDone: () {
          print('Stream closed');
          _isConnected = false;
          notifyListeners();
        },
      );

      // If we have a username, send it to the server
      if (_username != null && _username!.isNotEmpty) {
        _chatService.sendUsername(_username!);
        _isConnected = true;

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
      _addMessage(ChatMessage(
        username: 'System',
        message: 'Failed to reconnect: $e',
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

class ChatMessage {
  final String username;
  final String message;
  final bool isOwnMessage;
  final DateTime timestamp;
  final bool isSystemMessage;

  ChatMessage({
    required this.username,
    required this.message,
    required this.isOwnMessage,
    required this.timestamp,
    this.isSystemMessage = false,
  });
}
