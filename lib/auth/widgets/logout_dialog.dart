import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/profile_color.dart';
import '../providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';

class LogoutDialog {
  static Future<void> show(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show a confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'LOGOUT',
              style: TextStyle(
                color: isDark ? AppColors.errorDark : AppColors.errorLight,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _performLogout(context);
    }
  }

  static Future<void> _performLogout(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Add timeout to disconnect operation
      await Future.any([
        chatProvider.disconnect(),
        Future.delayed(const Duration(seconds: 3))
      ]);

      // Add timeout to clearing username
      await Future.any([
        chatProvider.clearStoredUsername(),
        Future.delayed(const Duration(seconds: 2))
      ]);

      // Add timeout to logout
      await Future.any(
          [authProvider.logout(), Future.delayed(const Duration(seconds: 2))]);

      // Clear profile image caches for security
      ProfileUtils.clearAllCaches();

      // Navigate to splash screen
      if (context.mounted) {
        // Force navigation even if some operations failed
        Navigator.of(context).pop(); // Dismiss loading dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/splashpage',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');

      // Ensure we always navigate away even if there's an error
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog

        // Show error briefly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout, but proceeding anyway'),
          ),
        );

        // Navigate away after showing error
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/splashpage',
              (route) => false,
            );
          }
        });
      }
    }
  }
}
