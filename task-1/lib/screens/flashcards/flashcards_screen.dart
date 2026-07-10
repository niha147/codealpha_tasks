import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/category_provider.dart';
import 'add_edit_flashcard_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Flashcards'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer2<FlashcardProvider, CategoryProvider>(
              builder: (context, fp, cp, _) {
                var cards = fp.flashcards;
                
                if (_selectedCategoryId != null) {
                  cards = cards.where((c) => c.categoryId == _selectedCategoryId).toList();
                }
                
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  cards = cards.where((c) => 
                    c.question.toLowerCase().contains(q) || 
                    c.answer.toLowerCase().contains(q)
                  ).toList();
                }

                if (cards.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final cat = cp.getCategoryById(card.categoryId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          card.question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${cat?.name ?? 'Unknown'} • ${card.answer}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditFlashcardScreen(flashcard: card)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, card.id, fp),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditFlashcardScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<CategoryProvider>(
      builder: (context, cp, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search question or answer...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryId == null,
                      onSelected: (val) {
                        setState(() => _selectedCategoryId = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...cp.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (val) {
                          setState(() => _selectedCategoryId = val ? cat.id : null);
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Flashcards Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add a new one.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, FlashcardProvider fp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard?'),
        content: const Text('Are you sure you want to delete this flashcard? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              fp.deleteFlashcard(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Flashcard deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
