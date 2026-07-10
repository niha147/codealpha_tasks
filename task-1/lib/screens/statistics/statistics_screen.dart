import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/stats_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/category_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer3<StatsProvider, FlashcardProvider, CategoryProvider>(
        builder: (context, statsProv, flashcardProv, categoryProv, _) {
          final stats = statsProv.stats;
          final totalCards = flashcardProv.flashcards.length;
          final favorites = flashcardProv.favoriteFlashcards.length;
          final categories = categoryProv.categories.length;

          // Simple completion rate logic: (totalCardsReviewed / totalCards) * 100
          // For a real app, you might track unique cards reviewed, but this satisfies the requirement.
          final completionRate = totalCards > 0 
              ? ((stats.totalCardsReviewed / (totalCards * (stats.totalSessions == 0 ? 1 : stats.totalSessions))) * 100).clamp(0, 100).toInt()
              : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildOverviewCards(context, stats, totalCards, favorites, categories),
                const SizedBox(height: 32),
                Text('Study Performance', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPerformanceStats(context, stats, completionRate),
                const SizedBox(height: 32),
                Text('Category Breakdown', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildChart(context, flashcardProv, categoryProv),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, dynamic stats, int totalCards, int favorites, int categories) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, 'Total Cards', totalCards.toString(), Icons.style, Colors.indigo),
        _buildStatCard(context, 'Favorites', favorites.toString(), Icons.favorite, Colors.pink),
        _buildStatCard(context, 'Categories', categories.toString(), Icons.category, Colors.orange),
        _buildStatCard(context, 'Study Time', _formatDuration(stats.totalStudyTimeSeconds), Icons.timer, Colors.cyan),
      ],
    );
  }

  Widget _buildPerformanceStats(BuildContext context, dynamic stats, int completionRate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildListTile('Study Sessions', stats.totalSessions.toString(), Icons.event_available),
            const Divider(),
            _buildListTile('Cards Reviewed', stats.totalCardsReviewed.toString(), Icons.check_circle_outline),
            const Divider(),
            _buildListTile('Avg Session Time', 
              stats.totalSessions > 0 ? _formatDuration(stats.totalStudyTimeSeconds ~/ stats.totalSessions) : '0s', 
              Icons.timelapse),
            const Divider(),
            _buildListTile('Completion Rate', '$completionRate%', Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, FlashcardProvider fp, CategoryProvider cp) {
    final categories = cp.categories;
    if (categories.isEmpty) return const SizedBox();

    final List<PieChartSectionData> sections = [];
    final colors = [Colors.indigo, Colors.cyan, Colors.orange, Colors.pink, Colors.purple, Colors.teal, Colors.amber];

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final count = fp.getFlashcardsByCategory(cat.id).length;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: count.toString(),
            radius: 50,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    }

    if (sections.isEmpty) {
      return const Center(child: Text('Add cards to see category breakdown.'));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    final count = fp.getFlashcardsByCategory(cat.id).length;
                    if (count == 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, color: colors[i % colors.length]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(cat.name, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
