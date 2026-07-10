import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/stats_provider.dart';
import '../flashcards/flashcards_screen.dart';
import '../categories/categories_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../flashcards/add_edit_flashcard_screen.dart';
import '../study/study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FlashMaster',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditFlashcardScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Flashcard'),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer3<FlashcardProvider, CategoryProvider, StatsProvider>(
      builder: (context, flashcardProv, categoryProv, statsProv, _) {
        final totalCards = flashcardProv.flashcards.length;
        final favoriteCards = flashcardProv.favoriteFlashcards.length;
        final totalCategories = categoryProv.categories.length;
        final stats = statsProv.stats;

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(context, 'Total Cards', totalCards.toString(), Icons.style, Colors.indigo),
            _buildStatCard(context, 'Favorites', favoriteCards.toString(), Icons.favorite, Colors.pink),
            _buildStatCard(context, 'Categories', totalCategories.toString(), Icons.category, Colors.orange),
            _buildStatCard(context, 'Study Sessions', stats.totalSessions.toString(), Icons.timer, Colors.cyan),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          context,
          'Study Now',
          'Start reviewing your flashcards',
          Icons.school,
          Colors.indigo,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyScreen())),
        ),
        _buildActionTile(
          context,
          'Manage Flashcards',
          'View, edit, or delete flashcards',
          Icons.edit_document,
          Colors.cyan,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardsScreen())),
        ),
        _buildActionTile(
          context,
          'Categories',
          'Organize your flashcards',
          Icons.folder,
          Colors.orange,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
        ),
        _buildActionTile(
          context,
          'Statistics',
          'View your study progress',
          Icons.bar_chart,
          Colors.purple,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen())),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
