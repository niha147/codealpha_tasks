import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String themeMode; // system, light, dark
  final bool voiceFeedback;
  final bool largeText;
  final bool highContrast;
  final bool sedentaryAlerts;
  final int stepGoal;
  final int calorieGoal;
  final int minuteGoal;
  final int waterGoal;

  AppSettings({
    this.themeMode = 'system',
    this.voiceFeedback = false,
    this.largeText = false,
    this.highContrast = false,
    this.sedentaryAlerts = true,
    this.stepGoal = 10000,
    this.calorieGoal = 500,
    this.minuteGoal = 60,
    this.waterGoal = 2000,
  });

  AppSettings copyWith({
    String? themeMode,
    bool? voiceFeedback,
    bool? largeText,
    bool? highContrast,
    bool? sedentaryAlerts,
    int? stepGoal,
    int? calorieGoal,
    int? minuteGoal,
    int? waterGoal,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
      largeText: largeText ?? this.largeText,
      highContrast: highContrast ?? this.highContrast,
      sedentaryAlerts: sedentaryAlerts ?? this.sedentaryAlerts,
      stepGoal: stepGoal ?? this.stepGoal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      minuteGoal: minuteGoal ?? this.minuteGoal,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      themeMode: prefs.getString('themeMode') ?? 'system',
      voiceFeedback: prefs.getBool('voiceFeedback') ?? false,
      largeText: prefs.getBool('largeText') ?? false,
      highContrast: prefs.getBool('highContrast') ?? false,
      sedentaryAlerts: prefs.getBool('sedentaryAlerts') ?? true,
      stepGoal: prefs.getInt('stepGoal') ?? 10000,
      calorieGoal: prefs.getInt('calorieGoal') ?? 500,
      minuteGoal: prefs.getInt('minuteGoal') ?? 60,
      waterGoal: prefs.getInt('waterGoal') ?? 2000,
    );
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newSettings.themeMode);
    await prefs.setBool('voiceFeedback', newSettings.voiceFeedback);
    await prefs.setBool('largeText', newSettings.largeText);
    await prefs.setBool('highContrast', newSettings.highContrast);
    await prefs.setBool('sedentaryAlerts', newSettings.sedentaryAlerts);
    await prefs.setInt('stepGoal', newSettings.stepGoal);
    await prefs.setInt('calorieGoal', newSettings.calorieGoal);
    await prefs.setInt('minuteGoal', newSettings.minuteGoal);
    await prefs.setInt('waterGoal', newSettings.waterGoal);
    state = newSettings;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
