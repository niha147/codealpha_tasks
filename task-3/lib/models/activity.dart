class Activity {
  final String id;
  final String name;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;
  final String notes;

  Activity({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      durationMinutes: map['durationMinutes'],
      caloriesBurned: map['caloriesBurned'],
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
    );
  }
}
