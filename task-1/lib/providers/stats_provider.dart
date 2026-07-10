import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/app_stats.dart';

class StatsProvider extends ChangeNotifier {
  final Box<AppStats> _appStatsBox = Hive.box<AppStats>('app_stats');

  AppStats get stats {
    var s = _appStatsBox.get('main_stats');
    if (s == null) {
      s = AppStats();
      _appStatsBox.put('main_stats', s);
    }
    return s;
  }

  Future<void> recordStudySession(int durationSeconds, int cardsReviewed) async {
    final s = stats;
    s.totalSessions += 1;
    s.totalStudyTimeSeconds += durationSeconds;
    s.totalCardsReviewed += cardsReviewed;
    await s.save();
    notifyListeners();
  }

  Future<void> clearStats() async {
    final s = stats;
    s.totalSessions = 0;
    s.totalStudyTimeSeconds = 0;
    s.totalCardsReviewed = 0;
    await s.save();
    notifyListeners();
  }
}
