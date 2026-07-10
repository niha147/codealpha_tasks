import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/flashcard.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/category_provider.dart';

class AddEditFlashcardScreen extends StatefulWidget {
  final Flashcard? flashcard;
  const AddEditFlashcardScreen({super.key, this.flashcard});

  @override
  State<AddEditFlashcardScreen> createState() => _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController = TextEditingController(text: widget.flashcard?.answer ?? '');
    _selectedCategoryId = widget.flashcard?.categoryId;

    if (_selectedCategoryId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cp = Provider.of<CategoryProvider>(context, listen: false);
        if (cp.categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = cp.categories.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final fp = Provider.of<FlashcardProvider>(context, listen: false);
      if (widget.flashcard == null) {
        final newCard = Flashcard(
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          categoryId: _selectedCategoryId!,
        );
        fp.addFlashcard(newCard);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flashcard created')));
      } else {
        widget.flashcard!.question = _questionController.text.trim();
        widget.flashcard!.answer = _answerController.text.trim();
        widget.flashcard!.categoryId = _selectedCategoryId!;
        fp.updateFlashcard(widget.flashcard!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flashcard updated')));
      }
      Navigator.pop(context);
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flashcard != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Flashcard' : 'Add Flashcard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Consumer<CategoryProvider>(
                builder: (context, cp, _) {
                  if (cp.categories.isEmpty) {
                    return const Text('No categories available. Create one first.', style: TextStyle(color: Colors.red));
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: cp.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    validator: (val) => val == null ? 'Please select a category' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Question', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter the question here...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Question cannot be empty' : null,
              ),
              const SizedBox(height: 24),
              const Text('Answer', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter the answer here...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Answer cannot be empty' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update Flashcard' : 'Save Flashcard',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
