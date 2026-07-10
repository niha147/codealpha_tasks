import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity.dart';
import '../providers/providers.dart';
import '../gamification/xp_service.dart';

class WorkoutService {
  final Ref ref;

  WorkoutService(this.ref);

  Future<void> addWorkout(Activity activity) async {
    // Persist to SQLite
    await ref.read(databaseProvider).insertActivity(activity);

    // Invalidate the activities provider so UI updates
    ref.invalidate(activitiesProvider);

    // Reward XP through XpService
    try {
      await ref.read(xpServiceProvider.notifier).addWorkoutXp(activity.id);

      final gNotifier = ref.read(gamificationProvider.notifier);
      final currentActivities = await ref.read(activitiesProvider.future);

      int totalMins =
          activity.durationMinutes.toInt() +
          currentActivities.fold<int>(0, (sum, act) {
            if (act.date.year == DateTime.now().year &&
                act.date.month == DateTime.now().month &&
                act.date.day == DateTime.now().day) {
              return sum + act.durationMinutes.toInt();
            }
            return sum;
          });
      await gNotifier.updateChallengeProgress('activity', totalMins);
    } catch (e) {
      debugPrint("Error updating activity gamification logic: \$e");
    }
  }

  Future<void> deleteWorkout(String id) async {
    await ref.read(databaseProvider).deleteActivity(id);
    ref.invalidate(activitiesProvider);
  }
}

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService(ref);
});
