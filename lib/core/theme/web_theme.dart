// ═══════════════════════════════════════════════════════════════════════════
// WEB THEME
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class WebTheme {
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color backgroundLight = Color(0xFF1A1928);
  static const Color primaryOrange = Color(0xFFFF8906);
  static const Color secondaryYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFFF4757);
  static const Color successGreen = Color(0xFF2ED573);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color cardBackground = Color(0xFF1E1D2F);
  static const Color borderColor = Color(0xFF2D2D44);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: secondaryYellow,
        error: errorRed,
        surface: backgroundLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
      ),
    );
  }
}