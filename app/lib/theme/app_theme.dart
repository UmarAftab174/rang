import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide design system for Rang
class AppTheme {
  AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryDark = Color(0xFF6C4FE0);
  static const Color primaryLight = Color(0xFF9D8AFF);
  static const Color accent = Color(0xFF00F5D4);

  // Legacy aliases (keep existing references working)
  static const Color primaryPurple = primary;
  static const Color primaryPurpleDark = primaryDark;
  static const Color primaryPurpleLight = primaryLight;

  // ── Background ──────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundCard = Color(0xFF14142B);
  static const Color backgroundCardLight = Color(0xFF1E1E3A);
  static const Color backgroundElevated = Color(0xFF1A1A2E);

  // ── Semantic Colors ─────────────────────────────────────────────────────────
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF59E0B);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9); // slate-100
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400
  static const Color textMuted = Color(0xFF64748B);     // slate-500

  // ── Spacing constants ───────────────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 28;
  static const double radiusFull = 9999;

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, Color(0xFF10102A)],
  );

  // ── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: 10,
    ),
  ];

  // ── Border ──────────────────────────────────────────────────────────────────
  static Border primaryBorder = Border.all(
    color: primary.withOpacity(0.3),
    width: 1,
  );

  // ── ThemeData ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: backgroundCard,
    ),
    // Use a distinctly smooth/rounded font instead of Inter or system font
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.nunito(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        elevation: 0,
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
