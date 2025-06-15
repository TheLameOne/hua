// import 'package:flutter/material.dart';

// /// Centralized color definitions following Material Design 3 principles
// class AppColors {
//   // Private constructor to prevent instantiation
//   AppColors._();

//   // Light Theme Colors
//   static const Color lightPrimary = Color(0xFF6750A4);
//   static const Color lightOnPrimary = Color(0xFFFFFFFF);
//   static const Color lightPrimaryContainer = Color(0xFFEADDFF);
//   static const Color lightOnPrimaryContainer = Color(0xFF21005D);

//   static const Color lightSecondary = Color(0xFF625B71);
//   static const Color lightOnSecondary = Color(0xFFFFFFFF);
//   static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
//   static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

//   static const Color lightTertiary = Color(0xFF7D5260);
//   static const Color lightOnTertiary = Color(0xFFFFFFFF);
//   static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
//   static const Color lightOnTertiaryContainer = Color(0xFF31111D);

//   static const Color lightError = Color(0xFFBA1A1A);
//   static const Color lightOnError = Color(0xFFFFFFFF);
//   static const Color lightErrorContainer = Color(0xFFFFDAD6);
//   static const Color lightOnErrorContainer = Color(0xFF410002);

//   static const Color lightBackground = Color(0xFFFFFBFE);
//   static const Color lightOnBackground = Color(0xFF1C1B1F);
//   static const Color lightSurface = Color(0xFFFFFBFE);
//   static const Color lightOnSurface = Color(0xFF1C1B1F);
//   static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
//   static const Color lightOnSurfaceVariant = Color(0xFF49454F);

//   static const Color lightOutline = Color(0xFF79747E);
//   static const Color lightOutlineVariant = Color(0xFFCAC4D0);
//   static const Color lightShadow = Color(0xFF000000);
//   static const Color lightSurfaceTint = lightPrimary;
//   static const Color lightInverseSurface = Color(0xFF313033);
//   static const Color lightInverseOnSurface = Color(0xFFF4EFF4);
//   static const Color lightInversePrimary = Color(0xFFD0BCFF);

//   // Dark Theme Colors
//   static const Color darkPrimary = Color(0xFFD0BCFF);
//   static const Color darkOnPrimary = Color(0xFF381E72);
//   static const Color darkPrimaryContainer = Color(0xFF4F378B);
//   static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);

//   static const Color darkSecondary = Color(0xFFCCC2DC);
//   static const Color darkOnSecondary = Color(0xFF332D41);
//   static const Color darkSecondaryContainer = Color(0xFF4A4458);
//   static const Color darkOnSecondaryContainer = Color(0xFFE8DEF8);

//   static const Color darkTertiary = Color(0xFFEFB8C8);
//   static const Color darkOnTertiary = Color(0xFF492532);
//   static const Color darkTertiaryContainer = Color(0xFF633B48);
//   static const Color darkOnTertiaryContainer = Color(0xFFFFD8E4);

//   static const Color darkError = Color(0xFFFFB4AB);
//   static const Color darkOnError = Color(0xFF690005);
//   static const Color darkErrorContainer = Color(0xFF93000A);
//   static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

//   static const Color darkBackground = Color(0xFF1C1B1F);
//   static const Color darkOnBackground = Color(0xFFE6E1E5);
//   static const Color darkSurface = Color(0xFF1C1B1F);
//   static const Color darkOnSurface = Color(0xFFE6E1E5);
//   static const Color darkSurfaceVariant = Color(0xFF49454F);
//   static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

//   static const Color darkOutline = Color(0xFF938F99);
//   static const Color darkOutlineVariant = Color(0xFF49454F);
//   static const Color darkShadow = Color(0xFF000000);
//   static const Color darkSurfaceTint = darkPrimary;
//   static const Color darkInverseSurface = Color(0xFFE6E1E5);
//   static const Color darkInverseOnSurface = Color(0xFF313033);
//   static const Color darkInversePrimary = Color(0xFF6750A4);

//   // Chat-specific colors
//   static const Color sentMessageLight = Color(0xFF6750A4);
//   static const Color sentMessageDark = Color(0xFFD0BCFF);
//   static const Color receivedMessageLight = Color(0xFFE7E0EC);
//   static const Color receivedMessageDark = Color(0xFF49454F);

//   static const Color onlineIndicator = Color(0xFF4CAF50);
//   static const Color offlineIndicator = Color(0xFF9E9E9E);
//   static const Color typingIndicator = Color(0xFFFF9800);

//   // static const Color sentMessageLight = Color(0xFF6750A4);
//   // static const Color sentMessageDark = Color(0xFFD0BCFF);
//   // static const Color receivedMessageLight = Color(0xFFE7E0EC);
//   // static const Color receivedMessageDark = Color(0xFF49454F);

//   // static const Color onlineIndicator = Color(0xFF4CAF50);
//   // static const Color offlineIndicator = Color(0xFF9E9E9E);
//   // static const Color typingIndicator = Color(0xFFFF9800);

//   // Additional chat-specific colors needed by chat_page.dart
//   static const Color ownMessageBackground = lightPrimary;
//   static const Color otherMessageBackground = lightSurfaceVariant;
//   static const Color systemMessageBackground = Color(0xFFF3F3F3);
//   static const Color systemText = Color(0xFF616161);
//   static const Color disabledText = Color(0xFF9E9E9E);
//   static const Color inputBackground = Color(0xFFF5F5F5);
//   static const Color messageStatusRead = Color(0xFF4CAF50);

//   // Use primary color for easier reference
//   static const Color primary = lightPrimary;
//   static const Color onPrimary = lightOnPrimary;

//   // List of avatar colors
//   static const List<Color> avatarColors = [
//     Color(0xFF6750A4), // Purple
//     Color(0xFF7CB342), // Light Green
//     Color(0xFF039BE5), // Light Blue
//     Color(0xFFE91E63), // Pink
//     Color(0xFFFF9800), // Orange
//     Color(0xFF00ACC1), // Cyan
//     Color(0xFF3949AB), // Indigo
//     Color(0xFF8E24AA), // Purple
//     Color(0xFF43A047), // Green
//     Color(0xFFD81B60), // Pink
//   ];

//   // Color schemes for Material 3
//   static const ColorScheme lightColorScheme = ColorScheme(
//     brightness: Brightness.light,
//     primary: lightPrimary,
//     onPrimary: lightOnPrimary,
//     primaryContainer: lightPrimaryContainer,
//     onPrimaryContainer: lightOnPrimaryContainer,
//     secondary: lightSecondary,
//     onSecondary: lightOnSecondary,
//     secondaryContainer: lightSecondaryContainer,
//     onSecondaryContainer: lightOnSecondaryContainer,
//     tertiary: lightTertiary,
//     onTertiary: lightOnTertiary,
//     tertiaryContainer: lightTertiaryContainer,
//     onTertiaryContainer: lightOnTertiaryContainer,
//     error: lightError,
//     onError: lightOnError,
//     errorContainer: lightErrorContainer,
//     onErrorContainer: lightOnErrorContainer,
//     background: lightBackground,
//     onBackground: lightOnBackground,
//     surface: lightSurface,
//     onSurface: lightOnSurface,
//     surfaceVariant: lightSurfaceVariant,
//     onSurfaceVariant: lightOnSurfaceVariant,
//     outline: lightOutline,
//     outlineVariant: lightOutlineVariant,
//     shadow: lightShadow,
//     scrim: lightShadow,
//     inverseSurface: lightInverseSurface,
//     onInverseSurface: lightInverseOnSurface,
//     inversePrimary: lightInversePrimary,
//     surfaceTint: lightSurfaceTint,
//   );

//   static const ColorScheme darkColorScheme = ColorScheme(
//     brightness: Brightness.dark,
//     primary: darkPrimary,
//     onPrimary: darkOnPrimary,
//     primaryContainer: darkPrimaryContainer,
//     onPrimaryContainer: darkOnPrimaryContainer,
//     secondary: darkSecondary,
//     onSecondary: darkOnSecondary,
//     secondaryContainer: darkSecondaryContainer,
//     onSecondaryContainer: darkOnSecondaryContainer,
//     tertiary: darkTertiary,
//     onTertiary: darkOnTertiary,
//     tertiaryContainer: darkTertiaryContainer,
//     onTertiaryContainer: darkOnTertiaryContainer,
//     error: darkError,
//     onError: darkOnError,
//     errorContainer: darkErrorContainer,
//     onErrorContainer: darkOnErrorContainer,
//     background: darkBackground,
//     onBackground: darkOnBackground,
//     surface: darkSurface,
//     onSurface: darkOnSurface,
//     surfaceVariant: darkSurfaceVariant,
//     onSurfaceVariant: darkOnSurfaceVariant,
//     outline: darkOutline,
//     outlineVariant: darkOutlineVariant,
//     shadow: darkShadow,
//     scrim: darkShadow,
//     inverseSurface: darkInverseSurface,
//     onInverseSurface: darkInverseOnSurface,
//     inversePrimary: darkInversePrimary,
//     surfaceTint: darkSurfaceTint,
//   );
// }
