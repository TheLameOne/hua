import 'package:flutter/material.dart';
import 'package:hua/theme/app_colors.dart';
import 'package:hua/utils/profile_color.dart';

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final String callerId;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallDialog({
    Key? key,
    required this.callerName,
    required this.callerId,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Call type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                          .withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVideoCall ? Icons.videocam : Icons.call,
                    size: 16,
                    color:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isVideoCall ? 'Video Call' : 'Voice Call',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Caller avatar
            ProfileUtils.buildUserChatAvatar(
              username: callerName,
              profilePic: null, // We don't have the profile pic in this context
              radius: 50,
              enableFullScreenView: false,
            ),

            const SizedBox(height: 16),

            // Caller name
            Text(
              callerName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),

            const SizedBox(height: 8),

            // Incoming call text
            Text(
              isVideoCall ? 'Incoming video call' : 'Incoming voice call',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                // Decline button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.errorDark : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.errorDark
                                  : AppColors.errorLight)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: onDecline,
                        child: const Center(
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Accept button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Green for accept
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: onAccept,
                        child: Center(
                          child: Icon(
                            isVideoCall ? Icons.videocam : Icons.call,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Caller ID (for debugging purposes)
            Text(
              'ID: ${callerId.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.7)
                    : AppColors.textSecondaryLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
