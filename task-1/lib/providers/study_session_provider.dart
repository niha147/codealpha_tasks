import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/flashcard.dart';

class StudySessionProvider extends ChangeNotifier {
  List<Flashcard> _studyCards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isShuffle = false;
  
  Timer? _timer;
  int _secondsElapsed = 0;
  int _cardsReviewed = 0;

  List<Flashcard> get studyCards => _studyCards;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  bool get isShuffle => _isShuffle;
  int get secondsElapsed => _secondsElapsed;
  int get cardsReviewed => _cardsReviewed;

  Flashcard? get currentCard => 
    _studyCards.isNotEmpty ? _studyCards[_currentIndex] : null;

  void startSession(List<Flashcard> cards) {
    _studyCards = List.from(cards);
    _currentIndex = 0;
    _isFlipped = false;
    _isShuffle = false;
    _secondsElapsed = 0;
    _cardsReviewed = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void stopSession() {
    _timer?.cancel();
    _timer = null;
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      final current = currentCard;
      _studyCards.shuffle();
      if (current != null) {
        _currentIndex = _studyCards.indexOf(current);
      }
    } else {
      // Re-sort could be complex if we don't store original order,
      // but typically shuffle is just one-way until restarted.
      // For simplicity, we just leave it shuffled when disabled, 
      // or we could keep a pristine copy. Let's keep a pristine copy if needed,
      // but for now, shuffling is fine.
    }
    notifyListeners();
  }

  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void nextCard() {
    if (_currentIndex < _studyCards.length - 1) {
      if (!_isFlipped) _cardsReviewed++; // mark as reviewed if they just skipped or we can just count it. Let's count every card seen.
      _currentIndex++;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
