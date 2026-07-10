import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote.dart';
import '../repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Quote>>(() {
  return FavoritesNotifier();
});

class FavoritesNotifier extends Notifier<List<Quote>> {
  late final FavoritesRepository _repository;

  @override
  List<Quote> build() {
    _repository = ref.watch(favoritesRepositoryProvider);
    Future.microtask(() => _loadFavorites());
    return [];
  }

  Future<void> _loadFavorites() async {
    final favorites = await _repository.getFavorites();
    state = favorites;
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (state.contains(quote)) {
      state = state.where((q) => q != quote).toList();
    } else {
      state = [...state, quote];
    }
    await _repository.saveFavorites(state);
  }

  bool isFavorite(Quote quote) {
    return state.contains(quote);
  }
}
