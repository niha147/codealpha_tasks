import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/providers.dart';
import '../../models/activity.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final stepHistoryAsync = ref.watch(stepHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not enough data for analytics.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Process data for last 7 days
          final now = DateTime.now();
          final last7Days = List.generate(
            7,
            (index) => now.subtract(Duration(days: 6 - index)),
          );

          List<BarChartGroupData> barGroups = [];
          List<FlSpot> lineSpots = [];

          for (int i = 0; i < last7Days.length; i++) {
            final date = last7Days[i];
            int dailyCals = 0;
            int dailyMins = 0;

            for (var act in activities) {
              if (act.date.year == date.year &&
                  act.date.month == date.month &&
                  act.date.day == date.day) {
                dailyCals += act.caloriesBurned.toInt();
                dailyMins += act.durationMinutes.toInt();
              }
            }

            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: dailyCals.toDouble(),
                    color: Colors.orange,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );

            lineSpots.add(FlSpot(i.toDouble(), dailyMins.toDouble()));
          }

          return stepHistoryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading steps: $e')),
            data: (stepHistory) {
              // Process steps for last 7 days
              List<BarChartGroupData> stepBarGroups = [];
              int totalWeeklySteps = 0;
              int bestDaySteps = 0;

              for (int i = 0; i < last7Days.length; i++) {
                final dateStr = DateFormat('yyyy-MM-dd').format(last7Days[i]);
                final record = stepHistory.firstWhere(
                  (r) => r['date'] == dateStr,
                  orElse: () => {'steps': 0},
                );
                int steps = record['steps'] as int;
                totalWeeklySteps += steps;
                if (steps > bestDaySteps) bestDaySteps = steps;

                stepBarGroups.add(
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: steps.toDouble(),
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }

              int avgDailySteps = (totalWeeklySteps / 7).round();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // STEP STATS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Steps',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Text(
                              '$totalWeeklySteps',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Daily Avg',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Text(
                              '$avgDailySteps',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: stepBarGroups,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = last7Days[value.toInt()];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(DateFormat('E').format(date)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CALORIES STATS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Calories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            const Text('Calories'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = last7Days[value.toInt()];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(DateFormat('E').format(date)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Duration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            const Text('Minutes'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: lineSpots,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.2),
                              ),
                            ),
                          ],
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = last7Days[value.toInt()];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(DateFormat('E').format(date)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Activity Heatmap (This Week)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildHeatmap(last7Days, activities),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeatmap(List<DateTime> days, List<Activity> activities) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: days.map((date) {
        int count = activities
            .where(
              (a) =>
                  a.date.year == date.year &&
                  a.date.month == date.month &&
                  a.date.day == date.day,
            )
            .length;
        return Column(
          children: [
            for (int i = 0; i < count.clamp(0, 5); i++)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            if (count == 0)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            const SizedBox(height: 8),
            Text(DateFormat('E').format(date)),
          ],
        );
      }).toList(),
    );
  }
}
