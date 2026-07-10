import 'package:flutter_test/flutter_test.dart';
import 'package:flashmaster/providers/study_session_provider.dart';
import 'package:flashmaster/data/models/flashcard.dart';

void main() {
  group('StudySessionProvider Tests', () {
    late StudySessionProvider provider;

    setUp(() {
      provider = StudySessionProvider();
    });

    test('startSession initializes values correctly', () {
      final cards = [
        Flashcard(question: 'Q1', answer: 'A1', categoryId: '1'),
        Flashcard(question: 'Q2', answer: 'A2', categoryId: '1'),
      ];

      provider.startSession(cards);

      expect(provider.studyCards.length, 2);
      expect(provider.currentIndex, 0);
      expect(provider.isFlipped, false);
      expect(provider.secondsElapsed, 0);
      expect(provider.cardsReviewed, 0);
    });

    test('nextCard increments index', () {
      final cards = [
        Flashcard(question: 'Q1', answer: 'A1', categoryId: '1'),
        Flashcard(question: 'Q2', answer: 'A2', categoryId: '1'),
      ];

      provider.startSession(cards);
      provider.nextCard();

      expect(provider.currentIndex, 1);
      expect(provider.cardsReviewed, 1); // card was reviewed
    });

    test('flipCard toggles isFlipped', () {
      final cards = [
        Flashcard(question: 'Q1', answer: 'A1', categoryId: '1'),
      ];

      provider.startSession(cards);
      
      expect(provider.isFlipped, false);
      provider.flipCard();
      expect(provider.isFlipped, true);
    });
  });
}
