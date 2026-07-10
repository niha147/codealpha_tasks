import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
import '../../models/activity.dart';
import '../../core/services/workout_service.dart';
import 'voice_logging_dialog.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String _filter = 'All'; // 'All', 'Today', 'Week', 'Month'

  void _showAddActivityDialog([
    String? initialActivity,
    int? initialDuration,
    int? initialCalories,
  ]) {
    final nameController = TextEditingController(text: initialActivity ?? '');
    final durationController = TextEditingController(
      text: initialDuration?.toString() ?? '',
    );
    final caloriesController = TextEditingController(
      text: initialCalories?.toString() ?? '',
    );
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
              ),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories Burned'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  durationController.text.isNotEmpty) {
                final newActivity = Activity(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  durationMinutes: int.tryParse(durationController.text) ?? 0,
                  caloriesBurned: int.tryParse(caloriesController.text) ?? 0,
                  date: DateTime.now(),
                  notes: notesController.text,
                );
                ref.read(workoutServiceProvider).addWorkout(newActivity);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity saved successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => VoiceLoggingDialog(
        onParsed: (activity, duration, calories) {
          _showAddActivityDialog(activity, duration, calories);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _filter = val),
            itemBuilder: (ctx) => [
              'All',
              'Today',
              'Week',
              'Month',
            ].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          // Apply filter
          final now = DateTime.now();
          List<Activity> filtered = activities.where((act) {
            if (_filter == 'Today') {
              return act.date.year == now.year &&
                  act.date.month == now.month &&
                  act.date.day == now.day;
            } else if (_filter == 'Week') {
              return now.difference(act.date).inDays <= 7;
            } else if (_filter == 'Month') {
              return act.date.year == now.year && act.date.month == now.month;
            }
            return true;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities found.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + or use voice logging to add one!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final act = filtered[index];
              return Dismissible(
                key: Key(act.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text(
                          "Are you sure you want to delete this activity?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (_) {
                  ref.read(workoutServiceProvider).deleteWorkout(act.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activity deleted')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      act.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${act.durationMinutes} min • ${act.caloriesBurned} kcal\n${DateFormat.yMMMd().format(act.date)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'voiceBtn',
            onPressed: _showVoiceDialog,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'addBtn',
            onPressed: () => _showAddActivityDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
