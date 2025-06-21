import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/my_profile_service.dart';
import '../models/my_profile_model.dart';

class MyProfileProvider extends ChangeNotifier {
  final MyProfileService _profileService = MyProfileService();

  MyProfile? _profile;
  bool _isLoading = false;
  String? _error;

  // Getters
  MyProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch user profile
  Future<void> fetchProfile() async {
    _setLoading(true);
    _error = null;

    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        _profile = profile;
      } else {
        _error = 'Failed to load profile';
      }
    } catch (e) {
      _error = 'Error loading profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Update user bio
  Future<bool> updateBio(String bio) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _profileService.updateBio(bio);
      if (success) {
        // Update local profile
        if (_profile != null) {
          _profile = _profile!.copyWith(bio: bio);
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to update bio';
        return false;
      }
    } catch (e) {
      _error = 'Error updating bio: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile picture
  Future<bool> updateProfilePicture(File imageFile) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _profileService.updateProfilePicture(imageFile);
      if (success) {
        // Refresh profile to get updated picture
        await fetchProfile();
        return true;
      } else {
        _error = 'Failed to update profile picture';
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile picture: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
