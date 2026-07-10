import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We would need an achievementsProvider to get this.
    // For now, let's just show an empty list or the actual achievements if we implemented them in providers.dart

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: const Center(child: Text('Achievements Engine syncing...')),
    );
  }
}
