import 'dart:math';

abstract class BaseCoachEngine {
  Future<String> getResponse({
    required String message,
    required int streak,
    required int level,
    required String goal,
    required List<Map<String, String>> history,
  });
  String getWorkoutSuggestion(int streak, int level);
  String getDifficultyLevel(int streak);
}

enum CoachIntent { workout, diet, motivation, fatigue, stats, unknown }

class LocalCoachEngine implements BaseCoachEngine {
  final Random _random = Random();

  CoachIntent _detectIntent(String message) {
    final msg = message.toLowerCase();
    if (msg.contains("workout") ||
        msg.contains("exercise") ||
        msg.contains("train"))
      return CoachIntent.workout;
    if (msg.contains("diet") || msg.contains("food") || msg.contains("eat"))
      return CoachIntent.diet;
    if (msg.contains("lazy") ||
        msg.contains("tired") ||
        msg.contains("exhausted"))
      return CoachIntent.fatigue;
    if (msg.contains("motivate") ||
        msg.contains("give up") ||
        msg.contains("help"))
      return CoachIntent.motivation;
    if (msg.contains("level") ||
        msg.contains("xp") ||
        msg.contains("progress") ||
        msg.contains("streak"))
      return CoachIntent.stats;
    return CoachIntent.unknown;
  }

  @override
  Future<String> getResponse({
    required String message,
    required int streak,
    required int level,
    required String goal,
    required List<Map<String, String>> history,
  }) async {
    // Simulate slight delay
    await Future.delayed(const Duration(milliseconds: 600));
    final intent = _detectIntent(message);

    switch (intent) {
      case CoachIntent.workout:
        return _generateWorkoutResponse(streak, level, message);
      case CoachIntent.diet:
        return _generateDietResponse(goal, message);
      case CoachIntent.fatigue:
        return _generateFatigueResponse(streak, level, message);
      case CoachIntent.motivation:
        return _generateMotivationResponse(streak, level, message);
      case CoachIntent.stats:
        return _generateStatsResponse(streak, level);
      case CoachIntent.unknown:
        return _generateDefaultResponse(message);
    }
  }

  String _generateWorkoutResponse(int streak, int level, String message) {
    if (level >= 10 || streak >= 14) {
      return "🌟 Elite Status Confirmed. Let's push past limits.\nSuggested Plan: High-Intensity Hybrid Training (45 mins). Core, Cardio, and Power!";
    } else if (streak >= 7) {
      return "🔥 You're on fire with a \$streak-day streak! Let's escalate.\nSuggested Plan: Advanced HIIT (30 mins). Keep the momentum going!";
    } else if (streak >= 3) {
      return "💪 You're building a solid habit. Great job reaching level \$level.\nSuggested Plan: Intermediate Strength & Cardio Mix (20 mins).";
    } else {
      return "🚶 Every journey starts with a single step. Let's get moving!\nSuggested Plan: Light Walk & Active Stretching (15 mins).";
    }
  }

  String _generateDietResponse(String goal, String message) {
    final g = goal.toLowerCase();
    if (g.contains("weight loss") || g.contains("lose weight")) {
      return "🥗 Fueling for weight loss: Focus on lean proteins, lots of greens, and stay in a slight calorie deficit. Hydration is key!";
    } else if (g.contains("muscle gain") || g.contains("bulk")) {
      return "🍗 Building muscle takes fuel! Ensure you're hitting your protein targets today (Eggs, Chicken, Lentils, Dairy).";
    } else {
      return "🥦 Balanced nutrition is the foundation of fitness. Aim for a mix of complex carbs, healthy fats, and quality protein today.";
    }
  }

  String _generateFatigueResponse(int streak, int level, String message) {
    if (message.toLowerCase().contains("hurt") ||
        message.toLowerCase().contains("pain") ||
        message.toLowerCase().contains("injury")) {
      return "🚨 If you are experiencing pain or an injury, please prioritize rest and consult a doctor! Recovery is more important than forcing a workout.";
    }

    if (level >= 5) {
      return "🔋 Elite athletes (like you at Level \$level) know when to rest. If you're truly exhausted, take an active recovery day. Listen to your body!";
    }
    return "😌 I can tell you're feeling drained. Try the '5-Minute Rule': Commit to just 5 minutes of light movement. Usually, momentum takes over. If not, it's okay to rest.";
  }

  String _generateMotivationResponse(int streak, int level, String message) {
    if (streak > 0) {
      return "🔥 You have a \$streak-day streak to protect! Don't break the chain today.";
    }
    return "💡 Today is a perfect day to start a new streak. Let's go!";
  }

  String _generateStatsResponse(int streak, int level) {
    return "📊 Your Current Stats:\nLevel: \$level 🌟\nActive Streak: \$streak days 🔥\n\nKeep logging workouts and water to unlock more badges and rank up!";
  }

  String _generateDefaultResponse(String message) {
    return "As your AI coach, I'm best at giving specific workout plans, diet advice, or motivation! Try asking me for a 'workout' or tell me if you're feeling 'tired'.";
  }

  @override
  String getWorkoutSuggestion(int streak, int level) {
    if (level >= 10 || streak >= 14) {
      return "🌟 Elite Workout: Intense Hybrid Training";
    } else if (streak >= 7) {
      return "🔥 Advanced Workout: HIIT + Core Blast";
    } else if (streak >= 4) {
      return "💪 Intermediate: Cardio + Strength Mix";
    } else {
      return "🚶 Beginner: Light walk + stretching";
    }
  }

  @override
  String getDifficultyLevel(int streak) {
    if (streak >= 7) return "Hard 🔥";
    if (streak >= 4) return "Medium 💪";
    return "Easy 🚶";
  }
}
