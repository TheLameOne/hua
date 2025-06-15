// import 'package:flutter/material.dart';
// import 'package:hua/theme/app_dimension.dart';
// import 'app_colors.dart';
// import 'app_text_styles.dart';

// class ChatTheme {
//   // Private constructor to prevent instantiation
//   ChatTheme._();

//   // Message bubble decorations
//   static BoxDecoration sentMessageDecoration(bool isDark) {
//     return BoxDecoration(
//       color: isDark ? AppColors.sentMessageDark : AppColors.sentMessageLight,
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(AppDimensions.radiusLarge),
//         topRight: Radius.circular(AppDimensions.radiusLarge),
//         bottomLeft: Radius.circular(AppDimensions.radiusLarge),
//         bottomRight: Radius.circular(AppDimensions.radiusSmall),
//       ),
//     );
//   }

//   static BoxDecoration receivedMessageDecoration(bool isDark) {
//     return BoxDecoration(
//       color: isDark
//           ? AppColors.receivedMessageDark
//           : AppColors.receivedMessageLight,
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(AppDimensions.radiusLarge),
//         topRight: Radius.circular(AppDimensions.radiusLarge),
//         bottomLeft: Radius.circular(AppDimensions.radiusSmall),
//         bottomRight: Radius.circular(AppDimensions.radiusLarge),
//       ),
//     );
//   }

//   // Message text styles with theme-aware colors
//   static TextStyle sentMessageTextStyle(bool isDark) {
//     return AppTextStyles.chatMessage.copyWith(
//       color: isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary,
//     );
//   }

//   static TextStyle receivedMessageTextStyle(bool isDark) {
//     return AppTextStyles.chatMessage.copyWith(
//       color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
//     );
//   }

//   static TextStyle timestampTextStyle(bool isDark) {
//     return AppTextStyles.chatTimestamp.copyWith(
//       color: isDark
//           ? AppColors.darkOnSurfaceVariant.withOpacity(0.7)
//           : AppColors.lightOnSurfaceVariant.withOpacity(0.7),
//     );
//   }

//   static TextStyle senderNameTextStyle(bool isDark) {
//     return AppTextStyles.chatSenderName.copyWith(
//       color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
//     );
//   }

//   // Online status indicators
//   static Widget onlineIndicator({double size = 12.0}) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: const BoxDecoration(
//         color: AppColors.onlineIndicator,
//         shape: BoxShape.circle,
//       ),
//     );
//   }

//   static Widget offlineIndicator({double size = 12.0}) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: const BoxDecoration(
//         color: AppColors.offlineIndicator,
//         shape: BoxShape.circle,
//       ),
//     );
//   }

//   // Typing indicator animation
//   static Widget typingIndicator() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppDimensions.paddingMedium,
//         vertical: AppDimensions.paddingSmall,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.typingIndicator.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           for (int i = 0; i < 3; i++) ...[
//             if (i > 0) const SizedBox(width: 4),
//             Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                 color: AppColors.typingIndicator,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // Chat input decoration
//   static InputDecoration chatInputDecoration(bool isDark, {String? hintText}) {
//     return InputDecoration(
//       hintText: hintText ?? 'Type a message...',
//       filled: true,
//       fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         borderSide: BorderSide(
//           color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
//           width: 2,
//         ),
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: AppDimensions.paddingLarge,
//         vertical: AppDimensions.paddingMedium,
//       ),
//       hintStyle: AppTextStyles.bodyMedium.copyWith(
//         color: isDark
//             ? AppColors.darkOnSurfaceVariant.withOpacity(0.6)
//             : AppColors.lightOnSurfaceVariant.withOpacity(0.6),
//       ),
//     );
//   }
// }
