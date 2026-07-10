class UserProfile {
  final int id; // SQLite singleton row (id=1)
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender;
  final int xp;
  final int level;

  UserProfile({
    this.id = 1,
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    this.xp = 0,
    this.level = 1,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'gender': gender,
      'xp': xp,
      'level': level,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? 1,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      heightCm: map['heightCm'] ?? 0.0,
      weightKg: map['weightKg'] ?? 0.0,
      gender: map['gender'] ?? 'Unknown',
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
    );
  }
}
