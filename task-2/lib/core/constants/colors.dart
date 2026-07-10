import 'package:flutter/material.dart';

class AppColors {
  // Gradients for different moods
  static const List<Color> motivationalGradient = [
    Color(0xFF2C3E50),
    Color(0xFFE74C3C),
  ];

  static const List<Color> calmGradient = [
    Color(0xFF141E30),
    Color(0xFF243B55),
  ];

  static const List<Color> successGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  static const List<Color> focusGradient = [
    Color(0xFF232526),
    Color(0xFF414345),
  ];

  static const List<Color> loveGradient = [
    Color(0xFF4A00E0),
    Color(0xFF8E2DE2),
  ];

  static const List<Color> defaultGradient = [
    Color(0xFF000428),
    Color(0xFF004e92),
  ];

  // Glassmorphism colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% opacity white
}
