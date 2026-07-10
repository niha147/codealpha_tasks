import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../models/water_intake.dart';
import '../../core/widgets/glass_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/xp_card.dart';
import 'widgets/streak_widget.dart';
import 'widgets/badge_grid.dart';
import '../coach/coach_chat_screen.dart';
import '../../core/gamification/xp_service.dart';
import '../../core/gamification/badge_service.dart';
import '../../core/services/water_service.dart';
import '../../core/services/step_service.dart';
import '../../core/services/workout_service.dart';
import '../../models/activity.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final waterAsync = ref.watch(waterProvider);
    final stepStateAsync = ref.watch(stepProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final xpStateAsync = ref.watch(xpServiceProvider);
    final badgeStateAsync = ref.watch(badgeServiceProvider);
    final streaksAsync = ref.watch(streaksProvider);

    // Trigger the Coach AI Engine quietly in the background
    ref.watch(coachProvider);

    // Calculate Today's Stats
    int todayCalories = 0;
    int todayMinutes = 0;

    String greeting = "Good Morning,";
    int hour = DateTime.now().hour;
    if (hour >= 12 && hour < 17)
      greeting = "Good Afternoon,";
    else if (hour >= 17)
      greeting = "Good Evening,";

    // Step Data
    int todaySteps = 0;
    bool stepError = false;
    String stepErrorMessage = '';
    bool permPermanentlyDenied = false;

    stepStateAsync.whenData((state) {
      todaySteps = state.steps;
      stepError = state.isError;
      stepErrorMessage = state.errorMessage;
      permPermanentlyDenied = state.permissionPermanentlyDenied;
    });

    activitiesAsync.whenData((activities) {
      final now = DateTime.now();
      for (var act in activities) {
        if (act.date.year == now.year &&
            act.date.month == now.month &&
            act.date.day == now.day) {
          todayCalories += act.caloriesBurned.toInt();
          todayMinutes += act.durationMinutes.toInt();
        }
      }
    });

    int todayWater = 0;
    waterAsync.whenData((waterList) {
      for (var w in waterList) {
        todayWater += w.amountMl.toInt();
      }
    });

    // Calculate Fitness Score
    double stepScore =
        (todaySteps / settings.stepGoal).clamp(0.0, 1.0) *
        40; // Steps carry highest weight
    double calorieScore =
        (todayCalories / settings.calorieGoal).clamp(0.0, 1.0) * 20;
    double activeScore =
        (todayMinutes / settings.minuteGoal).clamp(0.0, 1.0) * 20;
    double waterScore = (todayWater / settings.waterGoal).clamp(0.0, 1.0) * 20;
    int fitnessScore = (stepScore + calorieScore + activeScore + waterScore)
        .round();

    // Motivational logic
    int stepsLeft = settings.stepGoal - todaySteps;
    String motivationMsg = stepsLeft > 0
        ? "Only $stepsLeft steps remaining today!"
        : "You crushed your step goal! 🔥";

    final gamificationAsync = ref.watch(gamificationProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Error Banner
              if (stepError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stepErrorMessage,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                      if (permPermanentlyDenied)
                        TextButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: const Text('SETTINGS'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Fitness Champion',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // XP & Level Card
              xpStateAsync.when(
                data: (xpState) => XpCard(xp: xpState.totalXp),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Streak Visualization
              streaksAsync.when(
                data: (streak) => StreakWidget(streak: streak),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Fitness Score Card
              GlassCard(
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fitness Score',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$fitnessScore / 100',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: fitnessScore / 100,
                            ),
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Motivational Quote
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    motivationMsg,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Challenges
              Text('Daily Challenges', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              gamificationAsync.when(
                data: (state) {
                  return Column(
                    children: state.dailyChallenges.map((c) {
                      bool completed = c['isCompleted'] == 1;
                      int target = c['target'] as int;
                      int progress = c['progress'] as int;
                      double pct = (progress / target).clamp(0.0, 1.0);

                      String title = "";
                      IconData icon = Icons.star;
                      Color cColor = Colors.grey;
                      if (c['type'] == 'steps') {
                        title = "Walk $target steps";
                        icon = Icons.directions_walk;
                        cColor = Colors.blue;
                      } else if (c['type'] == 'water') {
                        title = "Drink $target ml of water";
                        icon = Icons.water_drop;
                        cColor = Colors.cyan;
                      } else if (c['type'] == 'activity') {
                        title = "Exercise for $target mins";
                        icon = Icons.timer;
                        cColor = Colors.orange;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: completed
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : cColor.withValues(alpha: 0.2),
                              child: Icon(
                                completed ? Icons.check : icon,
                                color: completed ? Colors.green : cColor,
                              ),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: cColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  color: completed ? Colors.green : cColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$progress / $target',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (completed) return;
                              if (c['type'] == 'steps') {
                                final controller = TextEditingController(
                                  text: '1000',
                                );
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Log Steps'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Steps Count',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          int steps =
                                              int.tryParse(controller.text) ??
                                              0;
                                          ref
                                              .read(stepServiceProvider)
                                              .addManualSteps(steps);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (c['type'] == 'water') {
                                ref.read(waterServiceProvider).addWater(250);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logged 250ml of water'),
                                  ),
                                );
                              } else if (c['type'] == 'activity') {
                                final controller = TextEditingController(
                                  text: '30',
                                );
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Log Activity Duration'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Duration (minutes)',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          int mins =
                                              int.tryParse(controller.text) ??
                                              0;
                                          final act = Activity(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            name: "Quick Challenge Workout",
                                            durationMinutes: mins,
                                            caloriesBurned: mins * 5,
                                            date: DateTime.now(),
                                            notes: 'Completed Daily Challenge',
                                          );
                                          ref
                                              .read(workoutServiceProvider)
                                              .addWorkout(act);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: GridView.count(
                        crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        children: [
                          _StatCard(
                            title: 'Steps',
                            value: '$todaySteps',
                            goal: '${settings.stepGoal}',
                            icon: Icons.directions_walk,
                            color: Colors.blue,
                            progress: todaySteps / settings.stepGoal,
                          ),
                          _StatCard(
                            title: 'Calories',
                            value: '$todayCalories kcal',
                            goal: '${settings.calorieGoal} kcal',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                            progress: todayCalories / settings.calorieGoal,
                          ),
                          _StatCard(
                            title: 'Minutes',
                            value: '$todayMinutes min',
                            goal: '${settings.minuteGoal} min',
                            icon: Icons.timer,
                            color: Colors.green,
                            progress: todayMinutes / settings.minuteGoal,
                          ),
                          _StatCard(
                            title: 'Water',
                            value: '${todayWater}ml',
                            goal: '${settings.waterGoal}ml',
                            icon: Icons.water_drop,
                            color: Colors.cyan,
                            progress: todayWater / settings.waterGoal,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Badge Grid
              Text('Achievements', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              badgeStateAsync.when(
                data: (badges) => BadgeGrid(badges: badges),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text('Quick Actions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Drink Water (250ml)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        ref.read(waterServiceProvider).addWater(250);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged 250ml of water'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoachChatScreen()),
          );
        },
        icon: const Icon(Icons.smart_toy),
        label: const Text('Ask Coach'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final IconData icon;
  final Color color;
  final double progress;

  const _StatCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    backgroundColor: color.withValues(alpha: 0.2),
                    color: color,
                    strokeWidth: 4,
                  );
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Goal: $goal',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
