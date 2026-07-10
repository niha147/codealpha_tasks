import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/notification_service.dart';

class GoalCelebrationOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GoalCelebrationOverlay({super.key, required this.child});

  @override
  ConsumerState<GoalCelebrationOverlay> createState() =>
      _GoalCelebrationOverlayState();
}

class _GoalCelebrationOverlayState
    extends ConsumerState<GoalCelebrationOverlay> {
  late ConfettiController _confettiController;
  int _lastTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showAchievementDialog(String title, String message) {
    NotificationService().showGoalCelebration(title, message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CelebrationState?>(celebrationProvider, (previous, next) {
      if (next != null && next.timestamp != _lastTimestamp) {
        _lastTimestamp = next.timestamp;
        _confettiController.play();
        _showAchievementDialog(next.title, next.message);
      }
    });

    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
