import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity.dart';
import '../providers/providers.dart';
import '../utils/notification_service.dart';
import 'badge_model.dart';
import 'xp_service.dart';

class BadgeService extends AsyncNotifier<List<Badge>> {
  @override
  Future<List<Badge>> build() async {
    final streak = await ref.watch(streaksProvider.future);
    final activities = await ref.watch(activitiesProvider.future);
    final xpState = await ref.watch(xpServiceProvider.future);

    final badges = _evaluateBadges(
      streak: streak,
      totalWorkouts: activities.length,
      level: xpState.level,
    );

    // Check for newly unlocked badges that we haven't notified about yet.
    // (We could persist standard "notified badges" set in SharedPreferences to avoid repeated notifications,
    // but the system asked for deterministic read-only approach.
    // We will assume that NotificationService checks or we just evaluate and send it if we transition states.
    // Actually, AsyncNotifier handles state transition when it rebuilds.)

    final previousBadges = state.value;
    if (previousBadges != null) {
      for (var badge in badges) {
        if (badge.unlocked) {
          final oldBadge = previousBadges.firstWhere(
            (b) => b.id == badge.id,
            orElse: () => badge,
          );
          if (!oldBadge.unlocked) {
            // Newly unlocked!
            int notificationId = 200 + badge.id.hashCode.abs();
            NotificationService().sendBadgeUnlockNotification(
              notificationId,
              "🎉 New Badge Unlocked!",
              badge.title,
            );
          }
        }
      }
    }

    return badges;
  }

  List<Badge> _evaluateBadges({
    required int streak,
    required int totalWorkouts,
    required int level,
  }) {
    return [
      Badge(
        id: "streak_3",
        title: "Getting Started",
        description: "3 Day Streak",
        icon: "🔥",
        unlocked: streak >= 3,
        progress: streak,
        target: 3,
      ),
      Badge(
        id: "streak_7",
        title: "Consistency King",
        description: "7 Day Streak",
        icon: "👑",
        unlocked: streak >= 7,
        progress: streak,
        target: 7,
      ),
      Badge(
        id: "streak_14",
        title: "Unstoppable",
        description: "14 Day Streak",
        icon: "🚀",
        unlocked: streak >= 14,
        progress: streak,
        target: 14,
      ),
      Badge(
        id: "workout_10",
        title: "Dedicated Trainer",
        description: "10 Workouts Completed",
        icon: "💪",
        unlocked: totalWorkouts >= 10,
        progress: totalWorkouts,
        target: 10,
      ),
      Badge(
        id: "workout_50",
        title: "Fitness Warrior",
        description: "50 Workouts Completed",
        icon: "⚔️",
        unlocked: totalWorkouts >= 50,
        progress: totalWorkouts,
        target: 50,
      ),
      Badge(
        id: "level_5",
        title: "Rising Athlete",
        description: "Reach Level 5",
        icon: "⚡",
        unlocked: level >= 5,
        progress: level,
        target: 5,
      ),
      Badge(
        id: "level_10",
        title: "Elite Performer",
        description: "Reach Level 10",
        icon: "🌟",
        unlocked: level >= 10,
        progress: level,
        target: 10,
      ),
    ];
  }
}

final badgeServiceProvider = AsyncNotifierProvider<BadgeService, List<Badge>>(
  () {
    return BadgeService();
  },
);
