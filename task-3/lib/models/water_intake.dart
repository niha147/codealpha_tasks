class WaterIntake {
  final String id;
  final int amountMl;
  final DateTime date;

  WaterIntake({required this.id, required this.amountMl, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'amountMl': amountMl, 'date': date.toIso8601String()};
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      amountMl: map['amountMl'],
      date: DateTime.parse(map['date']),
    );
  }
}
