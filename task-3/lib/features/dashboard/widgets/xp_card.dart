import 'package:flutter/material.dart';
import '../../../core/gamification/xp_engine.dart';
import '../../../core/widgets/glass_card.dart';

class XpCard extends StatelessWidget {
  final int xp;

  const XpCard({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    int level = XpEngine.calculateLevel(xp);
    int nextXp = XpEngine.xpForNextLevel(xp);
    // Calculate progress for current level
    // Calculate progress for current level
    // To make progress bar smooth, we show: (currentXp - floorXp) / (nextXp - floorXp)
    int currentLevelBaseXp = (level - 1) * 100;
    double progress = (xp - currentLevelBaseXp) / 100.0;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Level $level 🔥",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "XP: $xp / $nextXp",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
