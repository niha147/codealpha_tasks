import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

final themeProvider = NotifierProvider<ThemeNotifier, List<Color>>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<List<Color>> {
  @override
  List<Color> build() {
    return AppColors.defaultGradient;
  }

  void updateThemeForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'motivational':
        state = AppColors.motivationalGradient;
        break;
      case 'calm':
        state = AppColors.calmGradient;
        break;
      case 'success':
        state = AppColors.successGradient;
        break;
      case 'focus':
        state = AppColors.focusGradient;
        break;
      case 'love':
        state = AppColors.loveGradient;
        break;
      default:
        state = AppColors.defaultGradient;
    }
  }
}
