import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/flashcard.dart';

class FlashcardProvider extends ChangeNotifier {
  final Box<Flashcard> _flashcardBox = Hive.box<Flashcard>('flashcards');

  List<Flashcard> get flashcards => _flashcardBox.values.toList();

  List<Flashcard> get favoriteFlashcards =>
      _flashcardBox.values.where((f) => f.isFavorite).toList();

  List<Flashcard> getFlashcardsByCategory(String categoryId) {
    return _flashcardBox.values.where((f) => f.categoryId == categoryId).toList();
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    await _flashcardBox.put(flashcard.id, flashcard);
    notifyListeners();
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    flashcard.updatedAt = DateTime.now();
    await flashcard.save();
    notifyListeners();
  }

  Future<void> deleteFlashcard(String id) async {
    await _flashcardBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final flashcard = _flashcardBox.get(id);
    if (flashcard != null) {
      flashcard.isFavorite = !flashcard.isFavorite;
      await flashcard.save();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    await _flashcardBox.clear();
    notifyListeners();
  }
}
