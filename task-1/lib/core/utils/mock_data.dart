import '../../data/models/category.dart';
import '../../data/models/flashcard.dart';

class MockData {
  static List<Category> getCategories() {
    return [
      Category(name: 'Programming'),
      Category(name: 'Mathematics'),
      Category(name: 'Science'),
      Category(name: 'English'),
      Category(name: 'General Knowledge'),
    ];
  }

  static List<Flashcard> getFlashcards(List<Category> categories) {
    final programmingCatId = categories.firstWhere((c) => c.name == 'Programming').id;
    final mathCatId = categories.firstWhere((c) => c.name == 'Mathematics').id;
    final scienceCatId = categories.firstWhere((c) => c.name == 'Science').id;
    final englishCatId = categories.firstWhere((c) => c.name == 'English').id;
    final gkCatId = categories.firstWhere((c) => c.name == 'General Knowledge').id;

    return [
      // Programming
      Flashcard(
        question: 'What is Flutter?',
        answer: 'Flutter is an open-source UI software development kit created by Google.',
        categoryId: programmingCatId,
      ),
      Flashcard(
        question: 'What language is used in Flutter?',
        answer: 'Dart',
        categoryId: programmingCatId,
      ),
      Flashcard(
        question: 'What is a Widget in Flutter?',
        answer: 'Everything in Flutter is a Widget. Widgets are the building blocks of a Flutter app\'s user interface.',
        categoryId: programmingCatId,
      ),
      Flashcard(
        question: 'Explain state management in Flutter.',
        answer: 'State management refers to the handling of the state of an app. Popular approaches include Provider, Riverpod, and BLoC.',
        categoryId: programmingCatId,
      ),
      // Mathematics
      Flashcard(
        question: 'What is the value of Pi to 2 decimal places?',
        answer: '3.14',
        categoryId: mathCatId,
      ),
      Flashcard(
        question: 'What is the square root of 144?',
        answer: '12',
        categoryId: mathCatId,
      ),
      Flashcard(
        question: 'What is a prime number?',
        answer: 'A whole number greater than 1 whose only divisors are 1 and itself.',
        categoryId: mathCatId,
      ),
      // Science
      Flashcard(
        question: 'What is the chemical symbol for Gold?',
        answer: 'Au',
        categoryId: scienceCatId,
      ),
      Flashcard(
        question: 'What planet is known as the Red Planet?',
        answer: 'Mars',
        categoryId: scienceCatId,
      ),
      Flashcard(
        question: 'What is the powerhouse of the cell?',
        answer: 'Mitochondria',
        categoryId: scienceCatId,
      ),
      // English
      Flashcard(
        question: 'What is a noun?',
        answer: 'A word that represents a person, place, thing, or idea.',
        categoryId: englishCatId,
      ),
      Flashcard(
        question: 'Identify the synonym for "Happy".',
        answer: 'Joyful, glad, or cheerful.',
        categoryId: englishCatId,
      ),
      Flashcard(
        question: 'What is an adjective?',
        answer: 'A word that describes or modifies a noun or pronoun.',
        categoryId: englishCatId,
      ),
      // General Knowledge
      Flashcard(
        question: 'What is the capital of Japan?',
        answer: 'Tokyo',
        categoryId: gkCatId,
      ),
      Flashcard(
        question: 'Who wrote the play "Romeo and Juliet"?',
        answer: 'William Shakespeare',
        categoryId: gkCatId,
      ),
      Flashcard(
        question: 'What is the tallest mountain in the world?',
        answer: 'Mount Everest',
        categoryId: gkCatId,
      ),
    ];
  }
}
