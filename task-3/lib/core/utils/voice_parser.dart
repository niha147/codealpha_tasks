class VoiceParser {
  static Map<String, dynamic> parse(String text) {
    text = text.toLowerCase();

    String activity = 'Unknown Activity';
    int duration = 0;
    int calories = 0;

    // Detect Activity
    if (text.contains('run') || text.contains('ran'))
      activity = 'Running';
    else if (text.contains('walk'))
      activity = 'Walking';
    else if (text.contains('cycl') || text.contains('bike'))
      activity = 'Cycling';
    else if (text.contains('yoga'))
      activity = 'Yoga';
    else if (text.contains('swim'))
      activity = 'Swimming';
    else if (text.contains('gym') || text.contains('weight'))
      activity = 'Gym Workout';

    // Detect Duration
    final durationRegex = RegExp(r'(\d+)\s*(minute|min|hour|hr)s?');
    final durationMatch = durationRegex.firstMatch(text);
    if (durationMatch != null) {
      int val = int.tryParse(durationMatch.group(1) ?? '0') ?? 0;
      String unit = durationMatch.group(2) ?? 'minute';
      if (unit.startsWith('hour') || unit.startsWith('hr')) {
        duration = val * 60;
      } else {
        duration = val;
      }
    }

    // Detect Calories
    final caloriesRegex = RegExp(r'(\d+)\s*(calorie|cal)s?');
    final caloriesMatch = caloriesRegex.firstMatch(text);
    if (caloriesMatch != null) {
      calories = int.tryParse(caloriesMatch.group(1) ?? '0') ?? 0;
    } else if (duration > 0) {
      // Estimate calories based on activity and duration if not provided
      switch (activity) {
        case 'Running':
          calories = (duration * 11.4).round();
          break;
        case 'Walking':
          calories = (duration * 4.3).round();
          break;
        case 'Cycling':
          calories = (duration * 8.5).round();
          break;
        case 'Yoga':
          calories = (duration * 3.2).round();
          break;
        case 'Swimming':
          calories = (duration * 9.8).round();
          break;
        case 'Gym Workout':
          calories = (duration * 6.5).round();
          break;
        default:
          calories = (duration * 5.0).round();
          break;
      }
    }

    return {'activity': activity, 'duration': duration, 'calories': calories};
  }
}
