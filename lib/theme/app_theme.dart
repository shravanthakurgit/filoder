import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2A5EE8);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color accentBlue = Color(0xFF4285F4);
  static const Color background = Color(0xFFF8FAFF);
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF707782);
  static const Color cardBg = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: primaryBlue.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
