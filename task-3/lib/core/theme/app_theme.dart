import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4CAF50); // Fitness Green
  static const Color secondaryColor = Color(0xFF2196F3); // Blue
  static const Color accentColor = Color(0xFFFF9800); // Orange

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get highContrastLightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.highContrastLight(
        primary: Color(0xFF006400), // Darker green for high contrast
        secondary: Color(0xFF00008B), // Darker blue
        tertiary: Color(0xFF8B4500), // Darker orange
      ),
    );
  }

  static ThemeData get highContrastDarkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.highContrastDark(
        primary: Color(0xFF98FB98), // Lighter green for dark high contrast
        secondary: Color(0xFF87CEFA),
        tertiary: Color(0xFFFFDAB9),
      ),
    );
  }
}
