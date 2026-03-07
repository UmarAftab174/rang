import 'package:flutter/material.dart';

/// App-wide color theme for ChromaLens
class AppTheme {
  // Primary colors
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPurpleDark = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFFA78BFA);
  
  // Background colors
  static const Color backgroundDark = Color(0xFF0A0A12);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundCardLight = Color(0xFF2D2D4A);
  
  // Accent colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF59E0B);
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurpleDark, primaryPurple],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, Color(0xFF16162A)],
  );
  
  // Shadows
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryPurple.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primaryPurple.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: 10,
    ),
  ];
  
  // Border
  static Border primaryBorder = Border.all(
    color: primaryPurple.withOpacity(0.3),
    width: 1,
  );
  
  // ThemeData
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPurple,
      surface: backgroundCard,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primaryPurple),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
