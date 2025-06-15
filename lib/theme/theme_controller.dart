// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// Controller for managing theme state and persistence
// class ThemeController extends ChangeNotifier {
//   static const String _themeKey = 'theme_mode';
//   ThemeMode _themeMode = ThemeMode.system;

//   ThemeMode get themeMode => _themeMode;

//   bool get isDarkMode {
//     if (_themeMode == ThemeMode.system) {
//       return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
//           Brightness.dark;
//     }
//     return _themeMode == ThemeMode.dark;
//   }

//   bool get isLightMode => !isDarkMode;

//   /// Initialize theme from shared preferences
//   Future<void> init() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeModeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
//     _themeMode = ThemeMode.values[themeModeIndex];
//     notifyListeners();
//   }

//   /// Set theme mode and persist to shared preferences
//   Future<void> setThemeMode(ThemeMode mode) async {
//     if (_themeMode == mode) return;

//     _themeMode = mode;
//     notifyListeners();

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_themeKey, mode.index);
//   }

//   /// Toggle between light and dark modes
//   Future<void> toggleTheme() async {
//     final newMode =
//         _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     await setThemeMode(newMode);
//   }
// }
