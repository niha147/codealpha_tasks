import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 0)
class Flashcard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  String answer;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Flashcard({
    String? id,
    required this.question,
    required this.answer,
    required this.categoryId,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      categoryId: json['categoryId'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }
}
