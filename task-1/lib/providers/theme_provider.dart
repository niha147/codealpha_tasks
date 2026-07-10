import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  late bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    final settingsBox = Hive.box('settings');
    _isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    Hive.box('settings').put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
