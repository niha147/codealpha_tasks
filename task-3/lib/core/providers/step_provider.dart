import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers.dart';

// 0 = Loading, -1 = Permission Denied, -2 = Sensor Error
class StepState {
  final int steps;
  final bool isError;
  final String errorMessage;
  final bool permissionPermanentlyDenied;

  StepState({
    required this.steps,
    this.isError = false,
    this.errorMessage = '',
    this.permissionPermanentlyDenied = false,
  });

  StepState copyWith({
    int? steps,
    bool? isError,
    String? errorMessage,
    bool? permissionPermanentlyDenied,
  }) {
    return StepState(
      steps: steps ?? this.steps,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionPermanentlyDenied:
          permissionPermanentlyDenied ?? this.permissionPermanentlyDenied,
    );
  }
}

class StepNotifier extends AsyncNotifier<StepState> {
  StreamSubscription<StepCount>? _stepCountStream;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  FutureOr<StepState> build() async {
    ref.onDispose(() {
      _stepCountStream?.cancel();
    });
    return _initPedometer();
  }

  Future<StepState> _initPedometer() async {
    try {
      // 1. Check permissions safely
      var status = await Permission.activityRecognition.status;
      if (status.isDenied) {
        status = await Permission.activityRecognition.request();
      }

      if (status.isPermanentlyDenied) {
        return StepState(
          steps: 0,
          isError: true,
          errorMessage: 'Permission permanently denied.',
          permissionPermanentlyDenied: true,
        );
      } else if (!status.isGranted) {
        return StepState(
          steps: 0,
          isError: true,
          errorMessage: 'Permission denied. Cannot track steps.',
        );
      }

      // 2. Initialize DB for today
      int initialSteps = 0;
      try {
        await _loadStepsFromDb();
        final dbData = await ref
            .read(databaseProvider)
            .getStepsForDate(_currentDate);
        initialSteps = dbData?['steps'] as int? ?? 0;
      } catch (dbError) {
        // Fallback if DB fails completely, though DatabaseHelper should handle creation
        print('Warning: step DB load failed: $dbError');
      }

      // 3. Start listening to stream safely
      try {
        _stepCountStream = Pedometer.stepCountStream.listen(
          _onStepCount,
          onError: _onStepCountError,
          cancelOnError: false,
        );
      } catch (sensorError) {
        return StepState(
          steps: initialSteps,
          isError: true,
          errorMessage: 'Step sensor not available: $sensorError',
        );
      }

      return StepState(steps: initialSteps);
    } catch (e) {
      return StepState(
        steps: 0,
        isError: true,
        errorMessage: 'Unexpected error initializing step tracking: $e',
      );
    }
  }

  Future<void> _loadStepsFromDb() async {
    _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final db = ref.read(databaseProvider);
      var data = await db.getStepsForDate(_currentDate);
      if (data == null) {
        // Create record for today
        await db.updateSteps(_currentDate, 0, 0);
      }
    } catch (e) {
      print('Database error loading steps: $e');
    }
  }

  void _onStepCount(StepCount event) async {
    // Check if the day changed
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (today != _currentDate) {
      await _loadStepsFromDb();
    }

    final db = ref.read(databaseProvider);
    var data = await db.getStepsForDate(_currentDate);
    if (data == null) return;

    int currentSteps = data['steps'] as int;
    int lastRaw = data['last_raw_step_count'] as int;
    int eventSteps = event.steps;

    if (lastRaw == 0) {
      // First boot/run of the day
      lastRaw = eventSteps;
    } else if (eventSteps < lastRaw) {
      // Device was rebooted, pedometer reset
      currentSteps += eventSteps;
      lastRaw = eventSteps;
    } else if (eventSteps > lastRaw) {
      // Normal increment
      currentSteps += (eventSteps - lastRaw);
      lastRaw = eventSteps;
    }

    // Update DB
    await db.updateSteps(_currentDate, currentSteps, lastRaw);

    // Update State
    state = AsyncData(StepState(steps: currentSteps));

    // Update Gamification
    try {
      ref
          .read(gamificationProvider.notifier)
          .updateChallengeProgress('steps', currentSteps);
    } catch (_) {}
  }

  void _onStepCountError(error) {
    state = AsyncData(
      StepState(
        steps: state.value?.steps ?? 0,
        isError: true,
        errorMessage: 'Step sensor not available or error: $error',
      ),
    );
  }

  Future<void> requestPermissionAgain() async {
    state = const AsyncLoading();
    state = AsyncData(await _initPedometer());
  }
}

final stepProvider = AsyncNotifierProvider<StepNotifier, StepState>(() {
  return StepNotifier();
});
