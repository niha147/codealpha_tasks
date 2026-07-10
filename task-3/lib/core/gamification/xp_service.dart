import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/notification_service.dart';
import 'xp_engine.dart';

class XpState {
  final int totalXp;
  final int level;

  XpState({required this.totalXp, required this.level});
}

class XpService extends AsyncNotifier<XpState> {
  static const String _xpKey = 'total_xp';
  static const String _levelKey = 'user_level';
  static const String _lastWorkoutKey = 'last_processed_workout_id';
  static const String _lastWeeklyKey = 'last_xp_weekly_date';

  @override
  Future<XpState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_xpKey) ?? 0;
    final level = prefs.getInt(_levelKey) ?? 1;
    return XpState(totalXp: xp, level: level);
  }

  Future<void> addWorkoutXp(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString(_lastWorkoutKey);

    // Prevent double increment
    if (lastId == workoutId) return;
    await prefs.setString(_lastWorkoutKey, workoutId);

    await _addXp(10);
  }

  Future<void> addStreakBonus(int streak) async {
    // Every 3rd streak day
    if (streak > 0 && streak % 3 == 0) {
      // To prevent duplicate streak bonuses on multiple opens the same day,
      // we check if we already rewarded this specific streak number today.
      final prefs = await SharedPreferences.getInstance();
      final lastStreakRewarded =
          prefs.getInt('last_streak_bonus_rewarded') ?? 0;
      if (lastStreakRewarded < streak) {
        await _addXp(5);
        await prefs.setInt('last_streak_bonus_rewarded', streak);
      }
    }
  }

  Future<void> addWeeklyBonus() async {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      final prefs = await SharedPreferences.getInstance();
      final lastWeeklyDate = prefs.getString(_lastWeeklyKey);
      final todayStr = "${now.year}-${now.month}-${now.day}";

      if (lastWeeklyDate != todayStr) {
        await _addXp(50);
        await prefs.setString(_lastWeeklyKey, todayStr);
      }
    }
  }

  Future<void> _addXp(int amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    int currentXp = prefs.getInt(_xpKey) ?? 0;
    int currentLevel = prefs.getInt(_levelKey) ?? 1;

    int newXp = currentXp + amount;
    int newLevel = XpEngine.calculateLevel(newXp);

    if (newLevel > currentLevel) {
      int notificationId = 2000 + newLevel; // Different ID range for levels
      NotificationService().sendBadgeUnlockNotification(
        notificationId,
        "Level Up! 🎉",
        "🔥 You reached Level $newLevel! Keep pushing!",
      );
    }

    await prefs.setInt(_xpKey, newXp);
    await prefs.setInt(_levelKey, newLevel);

    state = AsyncData(XpState(totalXp: newXp, level: newLevel));
  }
}

final xpServiceProvider = AsyncNotifierProvider<XpService, XpState>(() {
  return XpService();
});
