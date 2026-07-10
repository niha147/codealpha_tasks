import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/activity.dart';
import '../../models/water_intake.dart';
import '../../models/achievement.dart';
import '../../models/streak.dart';
import '../../models/user_profile.dart';
import '../../models/emergency_card.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseFuture;

  DatabaseHelper._init();

  Future<Database> get database {
    if (_database != null) return Future.value(_database!);

    _databaseFuture ??= () async {
      try {
        final db = await _initDB(
          'fittrack_ai.db',
        ).timeout(const Duration(seconds: 5));
        _database = db;
        return db;
      } catch (e) {
        _databaseFuture = null;
        throw Exception('Database initialization failed or timed out: $e');
      }
    }();

    return _databaseFuture!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {},
    );

    // Verify and create tables if missing on every startup
    await _verifyAndCreateTables(db);
    return db;
  }

  Future<void> _verifyAndCreateTables(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE IF NOT EXISTS activities (
  id $idType,
  name $textType,
  durationMinutes $integerType,
  caloriesBurned $integerType,
  date $textType,
  notes $textType
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS water_intake (
  id $idType,
  amountMl $integerType,
  date $textType
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS daily_steps (
  date $idType,
  steps INTEGER NOT NULL DEFAULT 0,
  last_raw_step_count INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS achievements (
  id $idType,
  title $textType,
  description $textType,
  rarity $textType,
  unlockedAt $textType
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS streaks (
  date $textType PRIMARY KEY,
  isActive INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS user_profile (
  id INTEGER PRIMARY KEY,
  name $textType,
  age $integerType,
  heightCm $realType,
  weightKg $realType,
  gender $textType,
  xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1
)
''');

    // Add columns dynamically for migration if they don't exist
    try {
      await db.execute(
        'ALTER TABLE user_profile ADD COLUMN xp INTEGER NOT NULL DEFAULT 0',
      );
    } catch (_) {}
    try {
      await db.execute(
        'ALTER TABLE user_profile ADD COLUMN level INTEGER NOT NULL DEFAULT 1',
      );
    } catch (_) {}

    await db.execute('''
CREATE TABLE IF NOT EXISTS daily_challenges (
  id $idType,
  date $textType,
  type $textType,
  target $integerType,
  progress $integerType,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS emergency_card (
  id INTEGER PRIMARY KEY,
  name $textType,
  bloodGroup $textType,
  emergencyContact $textType,
  medicalNotes $textType,
  allergies $textType
)
''');
  }

  // Activity Methods
  Future<void> insertActivity(Activity activity) async {
    final db = await instance.database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Activity>> getActivities() async {
    final db = await instance.database;
    final result = await db.query('activities', orderBy: 'date DESC');
    return result.map((json) => Activity.fromMap(json)).toList();
  }

  Future<void> deleteActivity(String id) async {
    final db = await instance.database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Water Intake Methods
  Future<void> insertWaterIntake(WaterIntake intake) async {
    final db = await instance.database;
    await db.insert(
      'water_intake',
      intake.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WaterIntake>> getWaterIntakesForDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final result = await db.query(
      'water_intake',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return result.map((json) => WaterIntake.fromMap(json)).toList();
  }

  // Achievement Methods
  Future<void> insertAchievement(Achievement achievement) async {
    final db = await instance.database;
    await db.insert(
      'achievements',
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Achievement>> getAchievements() async {
    final db = await instance.database;
    final result = await db.query('achievements', orderBy: 'unlockedAt DESC');
    return result.map((json) => Achievement.fromMap(json)).toList();
  }

  // Streak Methods
  Future<void> upsertStreak(Streak streak) async {
    final db = await instance.database;
    await db.insert(
      'streaks',
      streak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Streak>> getStreaks() async {
    final db = await instance.database;
    final result = await db.query('streaks', orderBy: 'date DESC');
    return result.map((json) => Streak.fromMap(json)).toList();
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await instance.database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await instance.database;
    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      return UserProfile.fromMap(result.first);
    }
    return null;
  }

  // Emergency Card
  Future<void> saveEmergencyCard(EmergencyCard card) async {
    final db = await instance.database;
    await db.insert(
      'emergency_card',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EmergencyCard?> getEmergencyCard() async {
    final db = await instance.database;
    final result = await db.query(
      'emergency_card',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      return EmergencyCard.fromMap(result.first);
    }
    return null;
  }

  // Daily Steps Methods
  Future<Map<String, dynamic>?> getStepsForDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'daily_steps',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> updateSteps(String date, int steps, int lastRaw) async {
    final db = await instance.database;
    await db.insert('daily_steps', {
      'date': date,
      'steps': steps,
      'last_raw_step_count': lastRaw,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStepHistory(int limit) async {
    final db = await instance.database;
    return await db.query('daily_steps', orderBy: 'date DESC', limit: limit);
  }

  // Daily Challenges Methods
  Future<void> insertChallenge(Map<String, dynamic> challenge) async {
    final db = await instance.database;
    await db.insert(
      'daily_challenges',
      challenge,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getChallengesForDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'daily_challenges',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> updateChallengeProgress(
    String id,
    int progress,
    int isCompleted,
  ) async {
    final db = await instance.database;
    await db.update(
      'daily_challenges',
      {'progress': progress, 'isCompleted': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
