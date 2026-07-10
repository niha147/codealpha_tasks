class Quote {
  final int id;
  final String text;
  final String author;
  final String category;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      // Fallback to hashcode if id is missing in json
      id: json['id'] as int? ?? (json['text'] as String).hashCode,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author &&
          category == other.category;

  @override
  int get hashCode => text.hashCode ^ author.hashCode ^ category.hashCode;
}
