import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/glass_card.dart';
import '../coach/coach_chat_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Insights')),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add activities to see insights!',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Compute Insights

          // Average Duration
          int totalDuration = activities.fold(
            0,
            (sum, act) => sum + act.durationMinutes.toInt(),
          );
          int avgDuration = (totalDuration / activities.length).round();

          // Top Activity
          Map<String, int> activityCounts = {};
          for (var act in activities) {
            activityCounts[act.name] = (activityCounts[act.name] ?? 0) + 1;
          }
          String topActivity = '';
          int topCount = 0;
          activityCounts.forEach((key, value) {
            if (value > topCount) {
              topCount = value;
              topActivity = key;
            }
          });
          int topPercent = ((topCount / activities.length) * 100).round();

          // Calories compare (This week vs Last week)
          final now = DateTime.now();
          int thisWeekCals = 0;
          int lastWeekCals = 0;
          for (var act in activities) {
            final diffDays = now.difference(act.date).inDays;
            if (diffDays <= 7) {
              thisWeekCals += act.caloriesBurned.toInt();
            } else if (diffDays <= 14) {
              lastWeekCals += act.caloriesBurned.toInt();
            }
          }
          String calorieInsight = 'Keep pushing to burn more calories!';
          if (lastWeekCals > 0) {
            int calDiff = thisWeekCals - lastWeekCals;
            int calPercent = ((calDiff / lastWeekCals) * 100).round();
            if (calPercent > 0) {
              calorieInsight =
                  'You burned $calPercent% more calories this week.';
            } else if (calPercent < 0) {
              calorieInsight =
                  'You burned ${calPercent.abs()}% fewer calories this week.';
            }
          } else if (thisWeekCals > 0) {
            calorieInsight =
                'You burned $thisWeekCals calories this week. Great start!';
          }

          // Most active day
          Map<int, int> weekdayCounts = {};
          for (var act in activities) {
            weekdayCounts[act.date.weekday] =
                (weekdayCounts[act.date.weekday] ?? 0) + 1;
          }
          int bestWeekday = 1;
          int bestWeekdayCount = 0;
          weekdayCounts.forEach((key, value) {
            if (value > bestWeekdayCount) {
              bestWeekdayCount = value;
              bestWeekday = key;
            }
          });
          List<String> weekdays = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];
          String bestDayName = weekdays[bestWeekday - 1];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.smart_toy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text("Coach History & Reports"),
                  subtitle: const Text("View AI Coach conversations"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CoachChatScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Activity Insights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _InsightCard(
                icon: Icons.timer,
                color: Colors.blue,
                text: 'Your average workout duration is $avgDuration minutes.',
              ),
              const SizedBox(height: 16),
              _InsightCard(
                icon: Icons.pie_chart,
                color: Colors.orange,
                text:
                    '$topActivity accounts for $topPercent% of your workouts.',
              ),
              const SizedBox(height: 16),
              _InsightCard(
                icon: Icons.local_fire_department,
                color: Colors.red,
                text: calorieInsight,
              ),
              const SizedBox(height: 16),
              _InsightCard(
                icon: Icons.calendar_today,
                color: Colors.green,
                text: 'You are most active on ${bestDayName}s.',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
