// import 'package:flutter/material.dart';

// /// Centralized text style definitions following Material Design 3 typography
// class AppTextStyles {
//   // Private constructor to prevent instantiation
//   AppTextStyles._();

//   // Font families
//   static const String primaryFontFamily = 'Inter';
//   static const String secondaryFontFamily = 'Roboto';
//   static const String monospaceFontFamily = 'RobotoMono';

//   // Display styles
//   static const TextStyle displayLarge = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 57,
//     fontWeight: FontWeight.w400,
//     letterSpacing: -0.25,
//     height: 1.12,
//   );

//   static const TextStyle displayMedium = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 45,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.16,
//   );

//   static const TextStyle displaySmall = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 36,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.22,
//   );

//   // Headline styles
//   static const TextStyle headlineLarge = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 32,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.25,
//   );

//   static const TextStyle headlineMedium = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 28,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.29,
//   );

//   static const TextStyle headlineSmall = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 24,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.33,
//   );

//   // Title styles
//   static const TextStyle titleLarge = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 22,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0,
//     height: 1.27,
//   );

//   static const TextStyle titleMedium = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.15,
//     height: 1.50,
//   );

//   static const TextStyle titleSmall = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.1,
//     height: 1.43,
//   );

//   // Label styles
//   static const TextStyle labelLarge = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.1,
//     height: 1.43,
//   );

//   static const TextStyle labelMedium = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.5,
//     height: 1.33,
//   );

//   static const TextStyle labelSmall = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 11,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.5,
//     height: 1.45,
//   );

//   // Body styles
//   static const TextStyle bodyLarge = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.5,
//     height: 1.50,
//   );

//   static const TextStyle bodyMedium = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.25,
//     height: 1.43,
//   );

//   static const TextStyle bodySmall = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.4,
//     height: 1.33,
//   );

//   // Chat-specific text styles
//   static const TextStyle chatMessage = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.25,
//     height: 1.4,
//   );

//   static const TextStyle chatTimestamp = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.4,
//     height: 1.33,
//   );

//   static const TextStyle chatSenderName = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.16,
//     height: 1.38,
//   );

//   static const TextStyle chatStatus = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 11,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.5,
//     height: 1.45,
//   );

//   // Custom heading styles for easier use
//   static const TextStyle heading1 = displayMedium;
//   static const TextStyle heading2 = headlineLarge;
//   static const TextStyle heading3 = headlineMedium;
//   static const TextStyle heading4 = headlineSmall;
//   static const TextStyle heading5 = titleLarge;
//   static const TextStyle heading6 = titleMedium;

//   // Button and interaction styles
//   static const TextStyle button = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.1,
//     height: 1.43,
//   );

//   static const TextStyle caption = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.4,
//     height: 1.33,
//   );

//   static const TextStyle overline = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 10,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 1.5,
//     height: 1.6,
//   );

//   // Monospace styles for code
//   static const TextStyle codeText = TextStyle(
//     fontFamily: monospaceFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0,
//     height: 1.43,
//   );
//   static const TextStyle avatarText = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.bold,
//     letterSpacing: 0.5,
//     color: Colors.white,
//   );

//   static const TextStyle appBarTitle = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.15,
//     height: 1.5,
//     color: Color(0xFF333333),
//   );

//   static const TextStyle statusText = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.4,
//     color: Color(0xFF757575),
//   );

//   static const TextStyle menuItem = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.15,
//     height: 1.5,
//   );

//   static const TextStyle heading = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 20,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.15,
//     color: Color(0xFF333333),
//   );

//   static const TextStyle subtitle = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.25,
//     color: Color(0xFF757575),
//   );

//   static const TextStyle systemMessage = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.25,
//     color: Color(0xFF616161),
//     height: 1.4,
//   );

//   static const TextStyle messageUsername = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.1,
//     height: 1.3,
//   );

//   static const TextStyle messageBody = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 15,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.5,
//     height: 1.4,
//   );

//   static const TextStyle messageTimestamp = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 11,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.4,
//     color: Color(0xFF9E9E9E),
//     height: 1.0,
//   );

//   static const TextStyle inputHint = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.5,
//     color: Color(0xFF9E9E9E),
//   );

//   static const TextStyle inputText = TextStyle(
//     fontFamily: primaryFontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     letterSpacing: 0.5,
//     color: Color(0xFF333333),
//   );
// }
