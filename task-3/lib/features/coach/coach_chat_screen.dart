import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/coach_engine.dart';
import '../../core/ai/gemini_coach_engine.dart';
import '../../core/providers/providers.dart';
import '../../core/gamification/xp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({super.key});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final BaseCoachEngine _coachEngine = GeminiCoachEngine();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? msgs = prefs.getString('coach_chat_history');
    if (msgs != null && msgs.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(msgs);
      setState(() {
        _messages.clear();
        for (var item in decoded) {
          _messages.add({"sender": item["sender"], "text": item["text"]});
        }
      });
      _scrollToBottom();
    } else {
      setState(() {
        _messages.add({
          "sender": "coach",
          "text":
              "Hello! I'm your AI Fitness Coach. Tell me your goal (e.g. weight loss, muscle gain) or ask for a workout plan!",
        });
      });
      _saveMessages();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coach_chat_history', jsonEncode(_messages));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Copy current history before adding the new message
    final historyToPass = List<Map<String, String>>.from(_messages);

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true;
    });
    _controller.clear();
    _saveMessages();
    _scrollToBottom();

    // Get current streak from provider
    final streakAsync = ref.read(streaksProvider);
    final streak = streakAsync.when(
      data: (s) => s,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final xpState = await ref.read(xpServiceProvider.future);
    String goal = "fitness";

    final reply = await _coachEngine.getResponse(
      message: text,
      streak: streak,
      level: xpState.level,
      goal: goal,
      history: historyToPass,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({"sender": "coach", "text": reply});
      });
      _saveMessages();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("AI Fitness Coach")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return _buildChatBubble(msg["text"]!, isUser, theme);
              },
            ),
          ),
          _buildInputField(theme),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              "Coach is thinking...",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: theme.scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask your coach...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
