import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  late TextEditingController _stepCtrl;
  late TextEditingController _calCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _waterCtrl;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _stepCtrl = TextEditingController(text: settings.stepGoal.toString());
    _calCtrl = TextEditingController(text: settings.calorieGoal.toString());
    _minCtrl = TextEditingController(text: settings.minuteGoal.toString());
    _waterCtrl = TextEditingController(text: settings.waterGoal.toString());
  }

  void _saveGoals() {
    final currentSettings = ref.read(settingsProvider);
    final updated = currentSettings.copyWith(
      stepGoal: int.tryParse(_stepCtrl.text) ?? 10000,
      calorieGoal: int.tryParse(_calCtrl.text) ?? 500,
      minuteGoal: int.tryParse(_minCtrl.text) ?? 60,
      waterGoal: int.tryParse(_waterCtrl.text) ?? 2000,
    );
    ref.read(settingsProvider.notifier).updateSettings(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Goals saved successfully')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Goals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGoalInput(
              'Daily Steps Goal',
              _stepCtrl,
              Icons.directions_walk,
            ),
            const SizedBox(height: 16),
            _buildGoalInput(
              'Daily Calories Goal',
              _calCtrl,
              Icons.local_fire_department,
            ),
            const SizedBox(height: 16),
            _buildGoalInput('Workout Minutes Goal', _minCtrl, Icons.timer),
            const SizedBox(height: 16),
            _buildGoalInput(
              'Water Intake Goal (ml)',
              _waterCtrl,
              Icons.water_drop,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveGoals,
                child: const Text('Save Goals', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
