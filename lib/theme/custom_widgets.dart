// import 'package:flutter/material.dart';
// import 'package:hua/theme/app_dimension.dart';
// import 'app_colors.dart';
// import 'app_text_styles.dart';
// import 'chat_theme.dart';

// /// Custom styled widgets for the chat app
// class CustomWidgets {
//   // Private constructor to prevent instantiation
//   CustomWidgets._();

//   /// Custom styled button with loading state
//   static Widget primaryButton({
//     required String text,
//     required VoidCallback? onPressed,
//     bool isLoading = false,
//     IconData? icon,
//     double? width,
//   }) {
//     return SizedBox(
//       width: width,
//       height: AppDimensions.buttonHeight,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         child: isLoading
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : icon != null
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(icon, size: AppDimensions.iconSmall),
//                       const SizedBox(width: AppDimensions.paddingSmall),
//                       Text(text),
//                     ],
//                   )
//                 : Text(text),
//       ),
//     );
//   }

//   /// Custom chat message bubble
//   static Widget messageBubble({
//     required String message,
//     required bool isSent,
//     required bool isDark,
//     String? timestamp,
//     String? senderName,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(
//           vertical: AppDimensions.paddingExtraSmall,
//           horizontal: AppDimensions.paddingMedium,
//         ),
//         child: Row(
//           mainAxisAlignment:
//               isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (!isSent) ...[
//               CircleAvatar(
//                 radius: AppDimensions.chatAvatarSmallSize / 2,
//                 backgroundColor:
//                     isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
//                 child: Text(
//                   senderName?.substring(0, 1).toUpperCase() ?? 'U',
//                   style: AppTextStyles.labelMedium.copyWith(
//                     color: isDark
//                         ? AppColors.darkOnPrimary
//                         : AppColors.lightOnPrimary,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: AppDimensions.paddingSmall),
//             ],
//             Flexible(
//               child: Container(
//                 constraints: const BoxConstraints(
//                   maxWidth: AppDimensions.chatBubbleMaxWidth,
//                 ),
//                 padding: const EdgeInsets.all(AppDimensions.chatBubblePadding),
//                 decoration: isSent
//                     ? ChatTheme.sentMessageDecoration(isDark)
//                     : ChatTheme.receivedMessageDecoration(isDark),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (!isSent && senderName != null) ...[
//                       Text(
//                         senderName,
//                         style: ChatTheme.senderNameTextStyle(isDark),
//                       ),
//                       const SizedBox(height: 2),
//                     ],
//                     Text(
//                       message,
//                       style: isSent
//                           ? ChatTheme.sentMessageTextStyle(isDark)
//                           : ChatTheme.receivedMessageTextStyle(isDark),
//                     ),
//                     if (timestamp != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         timestamp,
//                         style: ChatTheme.timestampTextStyle(isDark),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             if (isSent) const SizedBox(width: AppDimensions.paddingLarge),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Custom app bar for chat screens
//   static PreferredSizeWidget chatAppBar({
//     required String title,
//     String? subtitle,
//     String? avatarUrl,
//     bool isOnline = false,
//     List<Widget>? actions,
//     VoidCallback? onBackPressed,
//   }) {
//     return AppBar(
//       leading: onBackPressed != null
//           ? IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: onBackPressed,
//             )
//           : null,
//       title: Row(
//         children: [
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               CircleAvatar(
//                 radius: AppDimensions.chatAvatarSmallSize / 2,
//                 backgroundImage:
//                     avatarUrl != null ? NetworkImage(avatarUrl) : null,
//                 child: avatarUrl == null
//                     ? Text(title.substring(0, 1).toUpperCase())
//                     : null,
//               ),
//               if (isOnline)
//                 Positioned(
//                   bottom: -2,
//                   right: -2,
//                   child: ChatTheme.onlineIndicator(size: 14),
//                 ),
//             ],
//           ),
//           const SizedBox(width: AppDimensions.paddingMedium),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.titleMedium,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (subtitle != null)
//                   Text(
//                     subtitle,
//                     style: AppTextStyles.bodySmall,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: actions,
//       elevation: 1,
//     );
//   }

//   /// Custom text field with modern styling
//   static Widget styledTextField({
//     required TextEditingController controller,
//     String? labelText,
//     String? hintText,
//     IconData? prefixIcon,
//     IconData? suffixIcon,
//     VoidCallback? onSuffixIconPressed,
//     bool obscureText = false,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     void Function(String)? onChanged,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       onChanged: onChanged,
//       maxLines: maxLines,
//       style: AppTextStyles.bodyMedium,
//       decoration: InputDecoration(
//         labelText: labelText,
//         hintText: hintText,
//         prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
//         suffixIcon: suffixIcon != null
//             ? IconButton(
//                 icon: Icon(suffixIcon),
//                 onPressed: onSuffixIconPressed,
//               )
//             : null,
//       ),
//     );
//   }

//   /// Custom loading indicator
//   static Widget loadingIndicator({
//     double size = 40.0,
//     Color? color,
//   }) {
//     return Center(
//       child: SizedBox(
//         width: size,
//         height: size,
//         child: CircularProgressIndicator(
//           strokeWidth: 3,
//           valueColor:
//               color != null ? AlwaysStoppedAnimation<Color>(color) : null,
//         ),
//       ),
//     );
//   }

//   /// Custom empty state widget
//   static Widget emptyState({
//     required String message,
//     IconData? icon,
//     String? actionText,
//     VoidCallback? onAction,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(AppDimensions.paddingLarge),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon != null) ...[
//               Icon(
//                 icon,
//                 size: AppDimensions.iconExtraLarge,
//                 color: Colors.grey,
//               ),
//               const SizedBox(height: AppDimensions.paddingMedium),
//             ],
//             Text(
//               message,
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: Colors.grey,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (actionText != null && onAction != null) ...[
//               const SizedBox(height: AppDimensions.paddingLarge),
//               primaryButton(
//                 text: actionText,
//                 onPressed: onAction,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
