import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';
import '../repositories/quote_repository.dart';
import 'theme_provider.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository();
});

class QuoteState {
  final Quote? currentQuote;
  final String activeMood;
  final bool isLoading;

  QuoteState({
    this.currentQuote,
    this.activeMood = 'All',
    this.isLoading = true,
  });

  QuoteState copyWith({
    Quote? currentQuote,
    String? activeMood,
    bool? isLoading,
  }) {
    return QuoteState(
      currentQuote: currentQuote ?? this.currentQuote,
      activeMood: activeMood ?? this.activeMood,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(() {
  return QuoteNotifier();
});

class QuoteNotifier extends Notifier<QuoteState> {
  late final QuoteRepository _repository;
  List<Quote> _allQuotes = [];
  Set<int> _seenQuotes = {};
  final Random _random = Random();
  bool _initialized = false;

  final Quote _fallbackQuote = Quote(
    id: "Every moment is a new beginning.".hashCode,
    text: "Every moment is a new beginning.",
    author: "Quotiva",
    category: "Motivational",
  );

  @override
  QuoteState build() {
    _repository = ref.watch(quoteRepositoryProvider);
    if (!_initialized) {
      Future.microtask(() => _initSystem());
    }
    return QuoteState();
  }

  Future<void> _initSystem() async {
    try {
      _initialized = true;
      state = state.copyWith(isLoading: true);
      
      // Load seen quotes from SharedPreferences persistently
      final prefs = await SharedPreferences.getInstance();
      final seenList = prefs.getStringList('seenQuotes') ?? [];
      _seenQuotes = seenList.map((e) => int.tryParse(e)).whereType<int>().toSet();

      // Load all quotes
      _allQuotes = await _repository.loadQuotes();
      
      if (_allQuotes.isEmpty) {
        _allQuotes = [_fallbackQuote];
      }
      
      generateNewQuote();
    } catch (e) {
      debugPrint("Error initializing quote system: $e");
      state = state.copyWith(
        currentQuote: _fallbackQuote,
        isLoading: false,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveSeenQuotesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('seenQuotes', _seenQuotes.map((e) => e.toString()).toList());
    } catch (e) {
      debugPrint("Error saving seen quotes: $e");
    }
  }

  void generateNewQuote() {
    try {
      if (_allQuotes.isEmpty) {
        state = state.copyWith(currentQuote: _fallbackQuote);
        return;
      }

      // STEP 1 -> Mood Filter
      List<Quote> moodQuotes = state.activeMood == 'All'
          ? List.from(_allQuotes)
          : _allQuotes.where((q) => q.category.toLowerCase() == state.activeMood.toLowerCase()).toList();

      if (moodQuotes.isEmpty) {
        moodQuotes = [_fallbackQuote];
      }

      // STEP 2 -> Remove Seen Quotes
      List<Quote> availableQuotes = moodQuotes.where((q) => !_seenQuotes.contains(q.id)).toList();

      // STEP 3 -> Handle Empty State Safely (Reset ONLY current mood pool)
      if (availableQuotes.isEmpty) {
        if (state.activeMood == 'All') {
          _seenQuotes.clear();
        } else {
          for (var q in moodQuotes) {
            _seenQuotes.remove(q.id);
          }
        }
        
        // Persist the targeted reset
        _saveSeenQuotesToPrefs();

        // Re-calculate after reset
        availableQuotes = moodQuotes.where((q) => !_seenQuotes.contains(q.id)).toList();
        
        // Ultimate safe fallback
        if (availableQuotes.isEmpty) {
          availableQuotes = List.from(moodQuotes);
        }
      }

      // STEP 4 -> Select Quote Safely
      final int length = availableQuotes.length;
      if (length == 0) {
        state = state.copyWith(currentQuote: _fallbackQuote);
        return;
      }

      final int index = length > 1 ? _random.nextInt(length) : 0;
      final Quote quote = availableQuotes[index];

      // STEP 5 -> Mark as Seen Immediately
      _seenQuotes.add(quote.id);
      _saveSeenQuotesToPrefs();
      
      state = state.copyWith(currentQuote: quote);
      
      // Defer theme update to prevent "state update during rebuild" framework errors
      Future.microtask(() {
        ref.read(themeProvider.notifier).updateThemeForMood(
          state.activeMood == 'All' ? quote.category : state.activeMood
        );
      });
    } catch (e) {
      debugPrint("Error generating quote: $e");
      state = state.copyWith(currentQuote: _fallbackQuote);
    }
  }

  void setMood(String mood) {
    try {
      // Mood switching MUST respect seen system - DO NOT reset history
      state = state.copyWith(activeMood: mood);
      generateNewQuote();
    } catch (e) {
      debugPrint("Error setting mood: $e");
      state = state.copyWith(currentQuote: _fallbackQuote);
    }
  }
}
