import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class FavoritesRepository {
  static const String _favoritesKey = 'favorites_quotes';

  Future<List<Quote>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) {
      return [];
    }

    try {
      final List<dynamic> data = json.decode(favoritesJson);
      return data.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Quote> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(favorites.map((q) => q.toJson()).toList());
    await prefs.setString(_favoritesKey, favoritesJson);
  }
}
