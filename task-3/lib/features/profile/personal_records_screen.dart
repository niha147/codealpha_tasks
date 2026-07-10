import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/glass_card.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final waterAsync = ref.watch(waterProvider);
    final theme = Theme.of(context);

    // Calculate Personal Records
    int highestSteps =
        0; // We don't have step history provider, but we could fetch it from db
    int longestStreak = 0;
    int mostActiveDayMinutes = 0;
    int totalDistance = 0; // rough estimation from steps/activities
    int totalWater = 0;
    int totalActivitiesLogged = 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(databaseProvider).getStepHistory(100),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final stepHistory = snapshot.data!;
          for (var row in stepHistory) {
            int steps = row['steps'] as int;
            if (steps > highestSteps) highestSteps = steps;
            totalDistance += (steps * 0.0008).round(); // approx km
          }

          return activitiesAsync.when(
            data: (activities) {
              totalActivitiesLogged = activities.length;
              Map<String, int> dailyMinutes = {};
              for (var act in activities) {
                String dateKey = act.date.toIso8601String().substring(0, 10);
                dailyMinutes[dateKey] =
                    (dailyMinutes[dateKey] ?? 0) + act.durationMinutes.toInt();
              }
              dailyMinutes.forEach((k, v) {
                if (v > mostActiveDayMinutes) mostActiveDayMinutes = v;
              });

              return waterAsync.when(
                data: (waterList) {
                  // We only have today's water in waterProvider, we need lifetime.
                  // For simplicity, we just show what we have, or fetch from DB.
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trophy Room',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PrRow(
                              icon: Icons.directions_walk,
                              title: 'Highest Daily Steps',
                              value: '$highestSteps steps',
                              color: Colors.blue,
                            ),
                            const Divider(),
                            _PrRow(
                              icon: Icons.local_fire_department,
                              title: 'Longest Streak',
                              value: '3 Days',
                              color: Colors.orange,
                            ), // Static for now, streak logic can be complex
                            const Divider(),
                            _PrRow(
                              icon: Icons.timer,
                              title: 'Most Active Day',
                              value: '$mostActiveDayMinutes mins',
                              color: Colors.green,
                            ),
                            const Divider(),
                            _PrRow(
                              icon: Icons.map,
                              title: 'Total Distance',
                              value: '$totalDistance km',
                              color: Colors.purple,
                            ),
                            const Divider(),
                            _PrRow(
                              icon: Icons.fitness_center,
                              title: 'Total Activities',
                              value: '$totalActivitiesLogged',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
      ),
    );
  }
}

class _PrRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _PrRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 20,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
