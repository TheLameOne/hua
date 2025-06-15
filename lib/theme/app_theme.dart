// import 'package:flutter/material.dart';
// import 'package:hua/theme/app_dimension.dart';
// import 'app_colors.dart';
// import 'app_text_styles.dart';

// /// Main theme configuration class that provides both light and dark themes
// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       colorScheme: AppColors.lightColorScheme,
//       scaffoldBackgroundColor: AppColors.lightBackground,
//       fontFamily: AppTextStyles.primaryFontFamily,

//       // AppBar Theme
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.lightSurface,
//         foregroundColor: AppColors.lightOnSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: AppTextStyles.heading2.copyWith(
//           color: AppColors.lightOnSurface,
//         ),
//         iconTheme: IconThemeData(
//           color: AppColors.lightOnSurface,
//           size: AppDimensions.iconMedium,
//         ),
//         surfaceTintColor: Colors.transparent,
//       ),

//       // Card Theme
//       cardTheme: CardTheme(
//         color: AppColors.lightSurface,
//         shadowColor: AppColors.lightShadow,
//         elevation: AppDimensions.elevationSmall,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//         ),
//         margin: EdgeInsets.all(AppDimensions.paddingSmall),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.lightPrimary,
//           foregroundColor: AppColors.lightOnPrimary,
//           disabledBackgroundColor: AppColors.lightOnSurface.withOpacity(0.12),
//           disabledForegroundColor: AppColors.lightOnSurface.withOpacity(0.38),
//           elevation: AppDimensions.elevationSmall,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLarge,
//             vertical: AppDimensions.paddingMedium,
//           ),
//           textStyle: AppTextStyles.button,
//           minimumSize:
//               Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.lightPrimary,
//           disabledForegroundColor: AppColors.lightOnSurface.withOpacity(0.38),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingMedium,
//             vertical: AppDimensions.paddingSmall,
//           ),
//           textStyle: AppTextStyles.button,
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.lightPrimary,
//           disabledForegroundColor: AppColors.lightOnSurface.withOpacity(0.38),
//           side: BorderSide(color: AppColors.lightPrimary, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLarge,
//             vertical: AppDimensions.paddingMedium,
//           ),
//           textStyle: AppTextStyles.button,
//           minimumSize:
//               Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
//         ),
//       ),

//       // FloatingActionButton Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: AppColors.lightPrimary,
//         foregroundColor: AppColors.lightOnPrimary,
//         elevation: AppDimensions.elevationMedium,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         ),
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.lightSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.lightOutline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.lightOutline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.lightError),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.lightError, width: 2),
//         ),
//         labelStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.lightOnSurfaceVariant,
//         ),
//         hintStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.lightOnSurfaceVariant.withOpacity(0.6),
//         ),
//         contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
//       ),

//       // Icon Theme
//       iconTheme: IconThemeData(
//         color: AppColors.lightOnSurface,
//         size: AppDimensions.iconMedium,
//       ),

//       // Bottom Navigation Bar Theme
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: AppColors.lightSurface,
//         selectedItemColor: AppColors.lightPrimary,
//         unselectedItemColor: AppColors.lightOnSurfaceVariant,
//         type: BottomNavigationBarType.fixed,
//         elevation: AppDimensions.elevationSmall,
//         selectedLabelStyle: AppTextStyles.caption,
//         unselectedLabelStyle: AppTextStyles.caption,
//       ),

//       // Dialog Theme
//       dialogTheme: DialogTheme(
//         backgroundColor: AppColors.lightSurface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         ),
//         elevation: AppDimensions.elevationLarge,
//         titleTextStyle: AppTextStyles.heading3.copyWith(
//           color: AppColors.lightOnSurface,
//         ),
//         contentTextStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.lightOnSurface,
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: AppColors.lightOutline.withOpacity(0.2),
//         thickness: 1,
//         space: 1,
//       ),

//       // List Tile Theme
//       listTileTheme: ListTileThemeData(
//         tileColor: Colors.transparent,
//         selectedTileColor: AppColors.lightPrimary.withOpacity(0.08),
//         iconColor: AppColors.lightOnSurface,
//         textColor: AppColors.lightOnSurface,
//         titleTextStyle: AppTextStyles.bodyLarge,
//         subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.lightOnSurfaceVariant,
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.paddingMedium,
//           vertical: AppDimensions.paddingSmall,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
//         ),
//       ),

//       // Chip Theme
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.lightSurfaceVariant,
//         selectedColor: AppColors.lightPrimary,
//         labelStyle: AppTextStyles.bodySmall,
//         secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
//           color: AppColors.lightOnPrimary,
//         ),
//         padding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.paddingSmall,
//           vertical: AppDimensions.paddingExtraSmall,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
//         ),
//       ),
//     );
//   }

//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       colorScheme: AppColors.darkColorScheme,
//       scaffoldBackgroundColor: AppColors.darkBackground,
//       fontFamily: AppTextStyles.primaryFontFamily,

//       // AppBar Theme
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.darkSurface,
//         foregroundColor: AppColors.darkOnSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: AppTextStyles.heading2.copyWith(
//           color: AppColors.darkOnSurface,
//         ),
//         iconTheme: IconThemeData(
//           color: AppColors.darkOnSurface,
//           size: AppDimensions.iconMedium,
//         ),
//         surfaceTintColor: Colors.transparent,
//       ),

//       // Card Theme
//       cardTheme: CardTheme(
//         color: AppColors.darkSurface,
//         shadowColor: AppColors.darkShadow,
//         elevation: AppDimensions.elevationSmall,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//         ),
//         margin: EdgeInsets.all(AppDimensions.paddingSmall),
//       ),

//       // Elevated Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.darkPrimary,
//           foregroundColor: AppColors.darkOnPrimary,
//           disabledBackgroundColor: AppColors.darkOnSurface.withOpacity(0.12),
//           disabledForegroundColor: AppColors.darkOnSurface.withOpacity(0.38),
//           elevation: AppDimensions.elevationSmall,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLarge,
//             vertical: AppDimensions.paddingMedium,
//           ),
//           textStyle: AppTextStyles.button,
//           minimumSize:
//               Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
//         ),
//       ),

//       // Text Button Theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.darkPrimary,
//           disabledForegroundColor: AppColors.darkOnSurface.withOpacity(0.38),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingMedium,
//             vertical: AppDimensions.paddingSmall,
//           ),
//           textStyle: AppTextStyles.button,
//         ),
//       ),

//       // Outlined Button Theme
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.darkPrimary,
//           disabledForegroundColor: AppColors.darkOnSurface.withOpacity(0.38),
//           side: BorderSide(color: AppColors.darkPrimary, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingLarge,
//             vertical: AppDimensions.paddingMedium,
//           ),
//           textStyle: AppTextStyles.button,
//           minimumSize:
//               Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
//         ),
//       ),

//       // FloatingActionButton Theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: AppColors.darkPrimary,
//         foregroundColor: AppColors.darkOnPrimary,
//         elevation: AppDimensions.elevationMedium,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         ),
//       ),

//       // Input Decoration Theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.darkSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.darkOutline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.darkOutline),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.darkError),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           borderSide: BorderSide(color: AppColors.darkError, width: 2),
//         ),
//         labelStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.darkOnSurfaceVariant,
//         ),
//         hintStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.darkOnSurfaceVariant.withOpacity(0.6),
//         ),
//         contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
//       ),

//       // Icon Theme
//       iconTheme: IconThemeData(
//         color: AppColors.darkOnSurface,
//         size: AppDimensions.iconMedium,
//       ),

//       // Bottom Navigation Bar Theme
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: AppColors.darkSurface,
//         selectedItemColor: AppColors.darkPrimary,
//         unselectedItemColor: AppColors.darkOnSurfaceVariant,
//         type: BottomNavigationBarType.fixed,
//         elevation: AppDimensions.elevationSmall,
//         selectedLabelStyle: AppTextStyles.caption,
//         unselectedLabelStyle: AppTextStyles.caption,
//       ),

//       // Dialog Theme
//       dialogTheme: DialogTheme(
//         backgroundColor: AppColors.darkSurface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         ),
//         elevation: AppDimensions.elevationLarge,
//         titleTextStyle: AppTextStyles.heading3.copyWith(
//           color: AppColors.darkOnSurface,
//         ),
//         contentTextStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.darkOnSurface,
//         ),
//       ),

//       // Divider Theme
//       dividerTheme: DividerThemeData(
//         color: AppColors.darkOutline.withOpacity(0.2),
//         thickness: 1,
//         space: 1,
//       ),

//       // List Tile Theme
//       listTileTheme: ListTileThemeData(
//         tileColor: Colors.transparent,
//         selectedTileColor: AppColors.darkPrimary.withOpacity(0.08),
//         iconColor: AppColors.darkOnSurface,
//         textColor: AppColors.darkOnSurface,
//         titleTextStyle: AppTextStyles.bodyLarge,
//         subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
//           color: AppColors.darkOnSurfaceVariant,
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.paddingMedium,
//           vertical: AppDimensions.paddingSmall,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
//         ),
//       ),

//       // Chip Theme
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.darkSurfaceVariant,
//         selectedColor: AppColors.darkPrimary,
//         labelStyle: AppTextStyles.bodySmall,
//         secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
//           color: AppColors.darkOnPrimary,
//         ),
//         padding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.paddingSmall,
//           vertical: AppDimensions.paddingExtraSmall,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
//         ),
//       ),
//     );
//   }
// }
