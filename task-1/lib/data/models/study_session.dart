import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'study_session.g.dart';

@HiveType(typeId: 2)
class StudySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationSeconds;

  @HiveField(4)
  final int cardsReviewed;

  @HiveField(5)
  final String? categoryId;

  StudySession({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.cardsReviewed,
    this.categoryId,
  }) : id = id ?? const Uuid().v4();
}
