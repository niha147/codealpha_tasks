import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:intl/intl.dart';

class StepService {
  final Ref ref;

  StepService(this.ref);

  Future<void> addManualSteps(int steps) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Attempt to get existing step count
    final existingData = await ref
        .read(databaseProvider)
        .getStepsForDate(todayStr);
    int currentSteps = 0;

    if (existingData != null) {
      currentSteps = existingData['steps'] as int;
      int lastRaw = existingData['last_raw_step_count'] as int;
      await ref
          .read(databaseProvider)
          .updateSteps(todayStr, currentSteps + steps, lastRaw);
    } else {
      await ref.read(databaseProvider).updateSteps(todayStr, steps, 0);
      currentSteps = 0;
    }

    // Invalidate step history
    ref.invalidate(stepHistoryProvider);

    // Update Daily Challenge progress
    try {
      final gNotifier = ref.read(gamificationProvider.notifier);
      await gNotifier.updateChallengeProgress('steps', currentSteps + steps);
    } catch (e) {
      debugPrint("Error updating steps gamification logic: \$e");
    }
  }
}

final stepServiceProvider = Provider<StepService>((ref) {
  return StepService(ref);
});
