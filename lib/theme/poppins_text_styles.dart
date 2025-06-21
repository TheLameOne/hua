import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper class for Poppins font styles
class PoppinsTextStyles {
  // Regular text styles
  static TextStyle get regular => GoogleFonts.poppins();
  
  static TextStyle get light => GoogleFonts.poppins(
    fontWeight: FontWeight.w300,
  );
  
  static TextStyle get medium => GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get semiBold => GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get bold => GoogleFonts.poppins(
    fontWeight: FontWeight.w700,
  );
  
  // Heading styles
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get h6 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  // Body text styles
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
  );
  
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
  );
  
  // Caption and label styles
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  // Button text style
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

/// Extension to easily apply Poppins font to any TextStyle
extension PoppinsTextStyleExtension on TextStyle {
  TextStyle get poppins => GoogleFonts.poppins(textStyle: this);
}
