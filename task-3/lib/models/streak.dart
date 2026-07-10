class Streak {
  final String date; // Format: YYYY-MM-DD
  final bool isActive;

  Streak({required this.date, required this.isActive});

  Map<String, dynamic> toMap() {
    return {'date': date, 'isActive': isActive ? 1 : 0};
  }

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(date: map['date'], isActive: map['isActive'] == 1);
  }
}
