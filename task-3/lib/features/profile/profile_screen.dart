import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../models/user_profile.dart';
import '../goals/goals_screen.dart';
import '../../core/widgets/glass_card.dart';

import 'emergency_card_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';
import 'personal_records_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        data: (profile) {
          final p =
              profile ??
              UserProfile(
                name: 'Guest',
                age: 25,
                heightCm: 170,
                weightKg: 65,
                gender: 'Not specified',
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  p.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // BMI Card
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'BMI',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            p.bmi.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            p.bmiCategory,
                            style: TextStyle(
                              fontSize: 20,
                              color: _getBmiColor(p.bmiCategory),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.military_tech),
                  title: const Text('Personal Records'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalRecordsScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Goals'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_information),
                  title: const Text('Emergency Health Card'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmergencyCardScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Achievements'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Accessibility Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _getBmiColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
