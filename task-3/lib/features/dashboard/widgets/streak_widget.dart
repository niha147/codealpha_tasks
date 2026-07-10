import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class StreakWidget extends StatelessWidget {
  final int streak;

  const StreakWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Column(
        children: [
          const Text(
            "🔥 Current Streak",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            "$streak Days",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (streak % 7 == 0 && streak > 0) ? 1.0 : (streak % 7) / 7.0,
            color: Colors.orange,
            backgroundColor: Colors.orange.withValues(alpha: 0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            "Next milestone in ${7 - (streak % 7)} days!",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
