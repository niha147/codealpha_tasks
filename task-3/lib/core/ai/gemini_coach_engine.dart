import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:math';
import 'coach_engine.dart';
import '../services/secure_storage_service.dart';

class GeminiCoachEngine implements BaseCoachEngine {
  final BaseCoachEngine _fallbackEngine = LocalCoachEngine();

  String _buildSystemPrompt(int streak, int level, String goal) {
    return '''
You are the FitTrack AI Coach, a highly motivational, expert personal fitness coach inside a mobile app.

User Context:
- Current Level: $level
- Current Workout Streak: $streak days
- Primary Goal: $goal

Rules:
1. Always behave exactly like a personal fitness coach. Be friendly, energetic, and concise.
2. Provide highly specific, actionable advice based on the user's answers.
3. Tailor the difficulty of your suggestions to the user's level.
4. Reference their streak and level to motivate them.
5. NEVER give formal medical diagnosis; always prioritize safe fitness advice and tell them to consult a doctor if they mention pain/injury.
6. Keep responses relatively short (1-3 paragraphs max) as this is a mobile chat interface.
''';
  }

  @override
  Future<String> getResponse({
    required String message,
    required int streak,
    required int level,
    required String goal,
    required List<Map<String, String>> history,
  }) async {
    final apiKey = await SecureStorageService.getApiKey();

    // Fallback to local engine if no API key is provided
    if (apiKey == null || apiKey.isEmpty) {
      return await _fallbackEngine.getResponse(
        message: message,
        streak: streak,
        level: level,
        goal: goal,
        history: history,
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        systemInstruction: Content.system(
          _buildSystemPrompt(streak, level, goal),
        ),
      );

      // Take the last 15 messages (plus the new one) to keep context small and relevant
      final recentHistory = history.length > 15
          ? history.sublist(history.length - 15)
          : history;

      final List<Content> chatHistory = [];
      String? lastRole;

      for (var msg in recentHistory) {
        final role = msg['sender'] == 'user' ? 'user' : 'model';
        final text = msg['text'] ?? '';

        // Gemini API strictly requires the first message to be from the 'user'
        if (chatHistory.isEmpty && role == 'model') {
          continue;
        }

        // Gemini API strictly requires alternating roles (user, model, user, model)
        if (role == lastRole) {
          final lastContent = chatHistory.removeLast();
          final lastText = (lastContent.parts.first as TextPart).text;
          final mergedText = lastText + "\\n\\n" + text;
          if (role == 'user') {
            chatHistory.add(Content.text(mergedText));
          } else {
            chatHistory.add(Content.model([TextPart(mergedText)]));
          }
        } else {
          if (role == 'user') {
            chatHistory.add(Content.text(text));
          } else {
            chatHistory.add(Content.model([TextPart(text)]));
          }
        }
        lastRole = role;
      }

      final chat = model.startChat(history: chatHistory);

      final response = await chat.sendMessage(Content.text(message));

      return response.text?.trim() ??
          "I'm having trouble thinking right now. Let's focus on your next workout!";
    } catch (e) {
      // Fallback on error (network, rate limit, invalid key)
      print('Gemini API Error: $e');
      return "Coach is temporarily unavailable. Error details: " + e.toString();
    }
  }

  @override
  String getWorkoutSuggestion(int streak, int level) {
    return _fallbackEngine.getWorkoutSuggestion(streak, level);
  }

  @override
  String getDifficultyLevel(int streak) {
    return _fallbackEngine.getDifficultyLevel(streak);
  }
}
