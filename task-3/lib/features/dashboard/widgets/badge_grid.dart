import 'package:flutter/material.dart';
import '../../../core/gamification/badge_model.dart' as model;
import '../../../core/widgets/glass_card.dart';

class BadgeGrid extends StatelessWidget {
  final List<model.Badge> badges;

  const BadgeGrid({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isUnlocked = badge.unlocked;

        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Text(badge.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(badge.title)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badge.description),
                    const SizedBox(height: 16),
                    Text(
                      'Status: ${isUnlocked ? "Unlocked \u{1F389}" : "Locked \u{1F512}"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (badge.progress / badge.target).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      color: isUnlocked
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text('${badge.progress} / ${badge.target}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: GlassCard(
            color: isUnlocked
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 40,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.lock, size: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
