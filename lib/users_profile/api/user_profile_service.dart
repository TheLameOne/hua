import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/user_profile_model.dart';
import '../../services/secure_storage_service.dart';

class UserProfileService {
  static const String baseUrl = 'https://api.geonotes.in/api';
  final SecureStorageService _secureStorage = SecureStorageService();
  late final Dio _dio;

  UserProfileService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        if (error.response?.statusCode == 401) {
          debugPrint('Unauthorized: Token may be invalid');
        }
        handler.next(error);
      },
    ));
  }

  /// Get user profile by username
  Future<UserProfile?> getUserProfile(String username) async {
    try {
      final path = '/user/$username';
      debugPrint('Fetching user profile from: $baseUrl$path');

      final response = await _dio.get(path);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response has 'data' field
        if (responseData.containsKey('data')) {
          return UserProfile.fromJson(responseData['data']);
        } else {
          // If no 'data' field, try to parse the response directly
          return UserProfile.fromJson(responseData);
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('DioException fetching user profile: ${e.message}');
      if (e.response?.statusCode == 401) {
        debugPrint('Unauthorized: Token may be invalid');
      } else if (e.response?.statusCode == 404) {
        debugPrint('User not found');
      } else {
        debugPrint('Failed to fetch user profile: ${e.response?.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get all users profile pictures
  Future<Map<String, String?>> getAllUsersProfilePic() async {
    try {
      final path = '/usersProfilePic';
      debugPrint('Fetching all users profile pics from: $baseUrl$path');

      final response = await _dio.get(path);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data')) {
          final List<dynamic> usersList = responseData['data'];
          final Map<String, String?> usersProfilePics = {};

          for (final user in usersList) {
            final username = user['username'] as String?;
            final profilePic = user['profilePic'] as String?;

            if (username != null) {
              // If profilePic is empty string, treat it as null
              usersProfilePics[username] =
                  (profilePic?.isEmpty ?? true) ? null : profilePic;
            }
          }

          return usersProfilePics;
        }
      }

      return {};
    } on DioException catch (e) {
      debugPrint('DioException fetching users profile pics: ${e.message}');
      return {};
    } catch (e) {
      debugPrint('Error fetching users profile pics: $e');
      return {};
    }
  }
}
