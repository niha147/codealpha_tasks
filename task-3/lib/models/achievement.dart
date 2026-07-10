class Achievement {
  final String id;
  final String title;
  final String description;
  final String rarity; // Bronze, Silver, Gold, Platinum
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.rarity,
    required this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rarity': rarity,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      rarity: map['rarity'],
      unlockedAt: DateTime.parse(map['unlockedAt']),
    );
  }
}
