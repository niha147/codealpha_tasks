import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../../models/activity.dart';
import '../../models/water_intake.dart';
import '../../models/user_profile.dart';
import '../ai/coach_engine.dart';
import '../utils/notification_service.dart';
import '../gamification/xp_service.dart';

export 'step_provider.dart';
export 'gamification_provider.dart';

// Database Provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  FutureOr<List<Activity>> build() async {
    return ref.read(databaseProvider).getActivities();
  }
}

final activitiesProvider =
    AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(() {
      return ActivitiesNotifier();
    });

// Water Intake Notifier
class WaterNotifier extends AsyncNotifier<List<WaterIntake>> {
  @override
  FutureOr<List<WaterIntake>> build() async {
    return ref.read(databaseProvider).getWaterIntakesForDate(DateTime.now());
  }
}

final waterProvider = AsyncNotifierProvider<WaterNotifier, List<WaterIntake>>(
  () {
    return WaterNotifier();
  },
);

// User Profile Notifier
class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  FutureOr<UserProfile?> build() async {
    return ref.read(databaseProvider).getUserProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await ref.read(databaseProvider).saveUserProfile(profile);
    ref.invalidateSelf();
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  () {
    return ProfileNotifier();
  },
);

// Streaks Provider (Derived)
final streaksProvider = FutureProvider<int>((ref) async {
  final activities = await ref.watch(activitiesProvider.future);
  if (activities.isEmpty) return 0;

  // Sort unique dates descending
  final dates = activities
      .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
      .toSet()
      .toList();
  dates.sort((a, b) => b.compareTo(a));

  int streak = 0;
  DateTime current = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // If today or yesterday has activity, we might have a streak
  if (dates.isNotEmpty &&
      (dates[0] == current ||
          dates[0] == current.subtract(const Duration(days: 1)))) {
    DateTime checkDate = dates[0];
    for (var date in dates) {
      if (date == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
  }
  return streak;
});

// Achievements Provider (Derived)
final achievementsProvider = FutureProvider<List<String>>((ref) async {
  final activities = await ref.watch(activitiesProvider.future);
  final water = await ref.watch(waterProvider.future);
  final streak = await ref.watch(streaksProvider.future);

  List<String> unlocked = [];

  if (activities.isNotEmpty) unlocked.add("First Workout!");
  if (activities.length >= 10) unlocked.add("10 Workouts Milestone");
  if (activities.length >= 50) unlocked.add("Fitness Enthusiast (50)");

  if (streak >= 3) unlocked.add("3-Day Streak!");
  if (streak >= 7) unlocked.add("7-Day Streak!");
  if (streak >= 30) unlocked.add("30-Day Warrior!");

  if (water.fold<int>(0, (sum, w) => sum + w.amountMl) >= 2000)
    unlocked.add("Hydrated (2L Today)");

  return unlocked;
});

// Step History Provider
final stepHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return await ref.read(databaseProvider).getStepHistory(7);
});

// Coach Engine Trigger
class CoachNotifier extends AsyncNotifier<void> {
  bool _hasInitialized = false;

  @override
  FutureOr<void> build() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    // Wait for the streak, activities, and level to be loaded
    final streak = await ref.watch(streaksProvider.future);
    final activities = await ref.watch(activitiesProvider.future);
    final xpState = await ref.watch(xpServiceProvider.future);

    final engine = LocalCoachEngine();

    // Schedule Daily Coach Message
    final workout = engine.getWorkoutSuggestion(streak, xpState.level);
    await NotificationService().sendDailyCoachMessage(streak, workout);

    // XpService handles Streak and Weekly bonuses automatically here
    await ref.read(xpServiceProvider.notifier).addStreakBonus(streak);
    await ref.read(xpServiceProvider.notifier).addWeeklyBonus();

    // If today is Sunday, trigger Weekly Summary once
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      final prefs = await SharedPreferences.getInstance();
      final lastWeeklyDate = prefs.getString('lastWeeklySummaryDate');
      final todayStr = "${now.year}-${now.month}-${now.day}";

      if (lastWeeklyDate != todayStr) {
        await NotificationService().sendWeeklySummary(
          streak,
          activities.length,
        );
        await prefs.setString('lastWeeklySummaryDate', todayStr);
      }
    }
  }
}

final coachProvider = AsyncNotifierProvider<CoachNotifier, void>(() {
  return CoachNotifier();
});
