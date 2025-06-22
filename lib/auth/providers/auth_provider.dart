import 'package:flutter/material.dart';
import 'package:hua/auth/api/auth_service.dart';
import 'package:hua/services/secure_storage_service.dart';
import 'package:hua/services/fcm_service.dart';

/// Authentication status states
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  authenticating,
  error
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();

  AuthStatus _status = AuthStatus.unknown;
  String? _token;
  String? _username;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get username => _username;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;

  // Initialize auth state from storage
  Future<void> initialize() async {
    try {
      // Use the convenience methods from SecureStorageService
      _token = await _secureStorage.getToken();
      _username = await _secureStorage.getUsername();

      if (_token != null && _username != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // Login
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.login(username, password);

      // Save token and username using convenience methods
      await _secureStorage.saveToken(token);
      await _secureStorage.saveUsername(username);

      _token = token;
      _username = username;
      _status = AuthStatus.authenticated;
      notifyListeners();

      // Update FCM token after successful login
      try {
        await FCMService().checkAndUpdateFCMToken();
      } catch (e) {
        debugPrint('Error updating FCM token after login: $e');
        // Don't fail login if FCM update fails
      }

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      // Create more user-friendly error message
      _errorMessage = _formatErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(username, password);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      // Create more user-friendly error message
      _errorMessage = _formatErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<bool> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // Call API logout endpoint with current token
      if (_token != null) {
        try {
          await _authService.logout(_token!);
        } catch (e) {
          debugPrint('API logout failed: $e');
          // Continue with local logout even if API call fails
        }
      }

      // Use the clearAuthData convenience method
      final success = await _secureStorage.clearAuthData();

      // Clear FCM data during logout
      try {
        await FCMService().clearFCMData();
      } catch (e) {
        debugPrint('Error clearing FCM data during logout: $e');
        // Don't fail logout if FCM clear fails
      }

      _token = null;
      _username = null;
      _status = AuthStatus.unauthenticated;

      notifyListeners();
      return success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _token != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Check if the current token is valid
  Future<bool> isTokenValid() async {
    if (_token == null) return false;

    try {
      // Here you could implement token validation
      // e.g., checking with the server if the token is still valid
      // For now we'll just check if it exists
      return true;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  // Format error messages to be more user-friendly
  String _formatErrorMessage(String error) {
    final message = error.replaceAll('Exception: ', '');

    // Handle common error messages
    if (message.contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (message.contains('No internet')) {
      return 'No internet connection. Please check your network settings.';
    }

    if (message.contains('Invalid credentials') ||
        message.contains('incorrect password') ||
        message.contains('User not found')) {
      return 'Invalid username or password.';
    }

    if (message.contains('already exists') || message.contains('taken')) {
      return 'Username already exists. Please choose a different one.';
    }

    // Return original message if no specific handling
    return message;
  }
}
