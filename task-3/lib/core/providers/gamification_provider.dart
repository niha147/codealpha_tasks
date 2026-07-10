import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile.dart';
import 'providers.dart';
import '../database/database_helper.dart';
import '../gamification/xp_service.dart';

class GamificationState {
  final List<Map<String, dynamic>> dailyChallenges;

  GamificationState({required this.dailyChallenges});

  GamificationState copyWith({List<Map<String, dynamic>>? dailyChallenges}) {
    return GamificationState(
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
    );
  }
}

class GamificationNotifier extends AsyncNotifier<GamificationState> {
  static const List<int> _levelThresholds = [
    0, // Level 1
    100, // Level 2
    250, // Level 3
    500, // Level 4
    900, // Level 5
    1400, // Level 6
    2000, // Level 7
    2700, // Level 8
    3500, // Level 9
    4500, // Level 10
  ];

  @override
  FutureOr<GamificationState> build() async {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = ref.read(databaseProvider);

    var challenges = await db.getChallengesForDate(todayStr);

    if (challenges.isEmpty) {
      // Generate new challenges for today
      challenges = [
        {
          'id': '${todayStr}_steps',
          'date': todayStr,
          'type': 'steps',
          'target': 10000,
          'progress': 0,
          'isCompleted': 0,
        },
        {
          'id': '${todayStr}_water',
          'date': todayStr,
          'type': 'water',
          'target': 2000,
          'progress': 0,
          'isCompleted': 0,
        },
        {
          'id': '${todayStr}_activity',
          'date': todayStr,
          'type': 'activity',
          'target': 30, // 30 minutes
          'progress': 0,
          'isCompleted': 0,
        },
      ];

      for (var c in challenges) {
        await db.insertChallenge(c);
      }
    }

    return GamificationState(dailyChallenges: challenges);
  }

  Future<void> updateChallengeProgress(String type, int newProgress) async {
    final current = state.value;
    if (current == null) return;

    List<Map<String, dynamic>> updatedChallenges = List.from(
      current.dailyChallenges,
    );
    bool changed = false;

    for (int i = 0; i < updatedChallenges.length; i++) {
      var c = updatedChallenges[i];
      if (c['type'] == type && c['isCompleted'] == 0) {
        int target = c['target'] as int;
        if (newProgress >= target) {
          // Completed!
          updatedChallenges[i] = Map.from(c)
            ..['progress'] = target
            ..['isCompleted'] = 1;
          await ref
              .read(databaseProvider)
              .updateChallengeProgress(c['id'] as String, target, 1);
          changed = true;
          // Reward XP for Challenge Complete
          try {
            await ref
                .read(xpServiceProvider.notifier)
                .addWorkoutXp("challenge_c_${c['id']}");
            ref
                .read(celebrationProvider.notifier)
                .triggerCelebration("Challenge Completed!", "You earned XP!");
          } catch (_) {}
        } else {
          // Only update if progress actually increased
          if (newProgress > (c['progress'] as int)) {
            updatedChallenges[i] = Map.from(c)..['progress'] = newProgress;
            await ref
                .read(databaseProvider)
                .updateChallengeProgress(c['id'] as String, newProgress, 0);
            changed = true;
          }
        }
      }
    }

    if (changed) {
      state = AsyncData(current.copyWith(dailyChallenges: updatedChallenges));
    }
  }
}

final gamificationProvider =
    AsyncNotifierProvider<GamificationNotifier, GamificationState>(() {
      return GamificationNotifier();
    });

// A simple provider to trigger global celebrations
class CelebrationState {
  final String title;
  final String message;
  final int timestamp;

  CelebrationState(this.title, this.message, this.timestamp);
}

class CelebrationNotifier extends Notifier<CelebrationState?> {
  @override
  CelebrationState? build() => null;

  void triggerCelebration(String title, String message) {
    state = CelebrationState(
      title,
      message,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

final celebrationProvider =
    NotifierProvider<CelebrationNotifier, CelebrationState?>(() {
      return CelebrationNotifier();
    });
