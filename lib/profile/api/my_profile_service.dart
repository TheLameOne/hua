import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hua/services/secure_storage_service.dart';
import '../models/my_profile_model.dart';

class MyProfileService {
  static const String baseUrl = 'https://api.geonotes.in/api/user';
  final Dio _dio = Dio();
  final SecureStorageService _secureStorage = SecureStorageService();

  MyProfileService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage and add to headers
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print('Dio error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Get user profile data
  Future<MyProfile?> getProfile() async {
    try {
      final response = await _dio.get('');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        return MyProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// Update user bio
  Future<bool> updateBio(String bio) async {
    try {
      final response = await _dio.patch(
        '',
        data: {'bio': bio},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating bio: $e');
      return false;
    }
  }

  /// Update user profile picture
  Future<bool> updateProfilePicture(File imageFile) async {
    try {
      // Get token from secure storage
      final token = await _secureStorage.getToken();
      if (token == null) {
        print('Error: No authentication token found');
        return false;
      }

      // Create form data with multipart file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_picture.jpg',
        ),
      });

      final response = await _dio.patch(
        'https://api.geonotes.in/api/userProfilePic',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }
}
