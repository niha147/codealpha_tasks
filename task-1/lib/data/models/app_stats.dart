import 'package:hive/hive.dart';

part 'app_stats.g.dart';

@HiveType(typeId: 3)
class AppStats extends HiveObject {
  @HiveField(0)
  int totalStudyTimeSeconds;

  @HiveField(1)
  int totalSessions;

  @HiveField(2)
  int totalCardsReviewed;

  AppStats({
    this.totalStudyTimeSeconds = 0,
    this.totalSessions = 0,
    this.totalCardsReviewed = 0,
  });
}
