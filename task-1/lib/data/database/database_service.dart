import 'package:hive_flutter/hive_flutter.dart';
import '../models/flashcard.dart';
import '../models/category.dart';
import '../models/study_session.dart';
import '../models/app_stats.dart';
import '../../core/utils/mock_data.dart';

class DatabaseService {
  static const String flashcardBoxName = 'flashcards';
  static const String categoryBoxName = 'categories';
  static const String studySessionBoxName = 'study_sessions';
  static const String appStatsBoxName = 'app_stats';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    // We can use Hive.initFlutter() directly as it's a Flutter app.
    await Hive.initFlutter();

    Hive.registerAdapter(FlashcardAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(AppStatsAdapter());

    await Hive.openBox<Flashcard>(flashcardBoxName);
    await Hive.openBox<Category>(categoryBoxName);
    await Hive.openBox<StudySession>(studySessionBoxName);
    await Hive.openBox<AppStats>(appStatsBoxName);
    await Hive.openBox(settingsBoxName);

    await _checkAndSeedData();
  }

  Future<void> _checkAndSeedData() async {
    final settingsBox = Hive.box(settingsBoxName);
    final isSeeded = settingsBox.get('isSeeded', defaultValue: false);

    if (!isSeeded) {
      final categoryBox = Hive.box<Category>(categoryBoxName);
      final flashcardBox = Hive.box<Flashcard>(flashcardBoxName);
      final appStatsBox = Hive.box<AppStats>(appStatsBoxName);

      if (appStatsBox.isEmpty) {
        await appStatsBox.put('main_stats', AppStats());
      }

      final categories = MockData.getCategories();
      for (var cat in categories) {
        await categoryBox.put(cat.id, cat);
      }

      final flashcards = MockData.getFlashcards(categories);
      for (var card in flashcards) {
        await flashcardBox.put(card.id, card);
      }

      await settingsBox.put('isSeeded', true);
    }
  }
}
