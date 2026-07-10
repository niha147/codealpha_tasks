class EmergencyCard {
  final int id; // Singleton row id = 1
  final String name;
  final String bloodGroup;
  final String emergencyContact;
  final String medicalNotes;
  final String allergies;

  EmergencyCard({
    this.id = 1,
    required this.name,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.medicalNotes,
    required this.allergies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'medicalNotes': medicalNotes,
      'allergies': allergies,
    };
  }

  factory EmergencyCard.fromMap(Map<String, dynamic> map) {
    return EmergencyCard(
      id: map['id'] ?? 1,
      name: map['name'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      medicalNotes: map['medicalNotes'] ?? '',
      allergies: map['allergies'] ?? '',
    );
  }
}
