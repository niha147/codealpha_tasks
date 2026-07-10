import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/water_intake.dart';
import '../providers/providers.dart';

class WaterService {
  final Ref ref;

  WaterService(this.ref);

  Future<void> addWater(int amountMl) async {
    final intake = WaterIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      date: DateTime.now(),
    );

    // Persist to SQLite
    await ref.read(databaseProvider).insertWaterIntake(intake);

    // Invalidate the water provider so the UI updates
    ref.invalidate(waterProvider);

    // Update Daily Challenge progress
    try {
      final gNotifier = ref.read(gamificationProvider.notifier);
      final currentWater = await ref.read(waterProvider.future);
      // Wait for the invalidated provider to fetch new data or calculate sum here
      int totalWater =
          amountMl + currentWater.fold<int>(0, (sum, w) => sum + w.amountMl);
      await gNotifier.updateChallengeProgress('water', totalWater);
    } catch (e) {
      debugPrint("Error updating water challenge logic: \$e");
    }
  }
}

final waterServiceProvider = Provider<WaterService>((ref) {
  return WaterService(ref);
});
