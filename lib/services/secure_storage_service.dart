import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service that handles secure storage operations
class SecureStorageService {
  // Singleton instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  // Factory constructor to return the same instance every time
  factory SecureStorageService() => _instance;

  // Private constructor for singleton pattern
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Keys used for storing data
  static const String usernameKey = 'username';
  static const String tokenKey = 'auth_token'; // Add token key constant

  /// Read a value from secure storage
  Future<String?> read({required String key}) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error reading from secure storage: $e');
      return null;
    }
  }

  /// Write a value to secure storage
  Future<bool> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      debugPrint('Error writing to secure storage: $e');
      return false;
    }
  }

  /// Delete a value from secure storage
  Future<bool> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      debugPrint('Error deleting from secure storage: $e');
      return false;
    }
  }

  /// Convenience method to save username
  Future<bool> saveUsername(String username) async {
    return write(key: usernameKey, value: username);
  }

  /// Convenience method to get username
  Future<String?> getUsername() async {
    return read(key: usernameKey);
  }

  /// Convenience method to save authentication token
  Future<bool> saveToken(String token) async {
    return write(key: tokenKey, value: token);
  }

  /// Convenience method to get authentication token
  Future<String?> getToken() async {
    return read(key: tokenKey);
  }

  /// Convenience method to clear authentication data
  Future<bool> clearAuthData() async {
    try {
      await delete(key: tokenKey);
      await delete(key: usernameKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      return false;
    }
  }

  /// Delete all stored values
  Future<bool> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      debugPrint('Error deleting all values from secure storage: $e');
      return false;
    }
  }
}
