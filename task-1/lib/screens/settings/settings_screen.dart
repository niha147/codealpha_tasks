import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../providers/theme_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/stats_provider.dart';
import '../../data/models/flashcard.dart';
import '../../data/models/category.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final fp = Provider.of<FlashcardProvider>(context, listen: false);
      final cp = Provider.of<CategoryProvider>(context, listen: false);

      final data = {
        'categories': cp.categories.map((c) => c.toJson()).toList(),
        'flashcards': fp.flashcards.map((f) => f.toJson()).toList(),
      };

      final jsonStr = jsonEncode(data);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'flashmaster_export.json',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonStr);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data exported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonStr);

        if (!context.mounted) return;

        final fp = Provider.of<FlashcardProvider>(context, listen: false);
        final cp = Provider.of<CategoryProvider>(context, listen: false);

        if (data.containsKey('categories')) {
          final List cats = data['categories'];
          for (var c in cats) {
            final cat = Category.fromJson(c);
            // Replace if exists or add
            if (cp.getCategoryById(cat.id) == null) {
              await cp.addCategory(cat);
            }
          }
        }

        if (data.containsKey('flashcards')) {
          final List cards = data['flashcards'];
          for (var c in cards) {
            final card = Flashcard.fromJson(c);
            await fp.addFlashcard(card);
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data imported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  void _resetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will delete all flashcards, categories, and statistics. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<FlashcardProvider>(context, listen: false).clearAll();
              Provider.of<CategoryProvider>(context, listen: false).clearAll();
              Provider.of<StatsProvider>(context, listen: false).clearStats();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data reset.')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: themeProv.isDarkMode,
            onChanged: (val) => themeProv.toggleTheme(),
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Save your flashcards and categories to a JSON file'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Load flashcards and categories from a JSON file'),
            onTap: () => _importData(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Clear all local data and statistics'),
            onTap: () => _resetData(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About FlashMaster'),
            subtitle: Text('Version 1.0.0\nCodeAlpha Task 1'),
          ),
        ],
      ),
    );
  }
}
