import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteRepository {
  Future<List<Quote>> loadQuotes() async {
    try {
      final String response = await rootBundle.loadString('assets/data/quotes.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Quote.fromJson(json)).toList();
    } catch (e) {
      // Return a fallback quote if loading fails
      return [
        Quote(
          id: "The present moment is filled with joy and happiness. If you are attentive, you will see it.".hashCode,
          text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
          author: "Thich Nhat Hanh",
          category: "Calm",
        )
      ];
    }
  }
}
