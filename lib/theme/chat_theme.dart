import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class ChatTheme extends ThemeExtension<ChatTheme> {
  const ChatTheme({
    required this.myMessageColor,
    required this.otherMessageColor,
    required this.systemMessageColor,
    required this.myMessageTextColor,
    required this.otherMessageTextColor,
    required this.systemMessageTextColor,
  });

  final Color myMessageColor;
  final Color otherMessageColor;
  final Color systemMessageColor;
  final Color myMessageTextColor;
  final Color otherMessageTextColor;
  final Color systemMessageTextColor;

  @override
  ChatTheme copyWith({
    Color? myMessageColor,
    Color? otherMessageColor,
    Color? systemMessageColor,
    Color? myMessageTextColor,
    Color? otherMessageTextColor,
    Color? systemMessageTextColor,
  }) {
    return ChatTheme(
      myMessageColor: myMessageColor ?? this.myMessageColor,
      otherMessageColor: otherMessageColor ?? this.otherMessageColor,
      systemMessageColor: systemMessageColor ?? this.systemMessageColor,
      myMessageTextColor: myMessageTextColor ?? this.myMessageTextColor,
      otherMessageTextColor:
          otherMessageTextColor ?? this.otherMessageTextColor,
      systemMessageTextColor:
          systemMessageTextColor ?? this.systemMessageTextColor,
    );
  }

  @override
  ChatTheme lerp(ChatTheme? other, double t) {
    if (other is! ChatTheme) {
      return this;
    }
    return ChatTheme(
      myMessageColor: Color.lerp(myMessageColor, other.myMessageColor, t)!,
      otherMessageColor:
          Color.lerp(otherMessageColor, other.otherMessageColor, t)!,
      systemMessageColor:
          Color.lerp(systemMessageColor, other.systemMessageColor, t)!,
      myMessageTextColor:
          Color.lerp(myMessageTextColor, other.myMessageTextColor, t)!,
      otherMessageTextColor:
          Color.lerp(otherMessageTextColor, other.otherMessageTextColor, t)!,
      systemMessageTextColor:
          Color.lerp(systemMessageTextColor, other.systemMessageTextColor, t)!,
    );
  }

  // Light theme - Beautiful purple gradient palette
  static const light = ChatTheme(
    myMessageColor: AppColors.myMessageLight,
    otherMessageColor: AppColors.otherMessageLight,
    systemMessageColor: Color(0xFFF5F2FF), // Very light mauve
    myMessageTextColor: AppColors.myMessageTextLight,
    otherMessageTextColor: AppColors.otherMessageTextLight,
    systemMessageTextColor: Color(0xFF6B6B9F), // Muted ultra violet
  );

  // Dark theme - Sophisticated purple-blue harmony
  static const dark = ChatTheme(
    myMessageColor: AppColors.myMessageDark,
    otherMessageColor: AppColors.otherMessageDark,
    systemMessageColor: Color(0xFF353350), // Darker space cadet
    myMessageTextColor: AppColors.myMessageTextDark,
    otherMessageTextColor: AppColors.otherMessageTextDark,
    systemMessageTextColor:
        Color(0xFFB8A5E8), // Lighter tropical indigo for visibility
  );
}
