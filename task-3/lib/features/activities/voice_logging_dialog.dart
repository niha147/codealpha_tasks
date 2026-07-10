import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/voice_parser.dart';

class VoiceLoggingDialog extends StatefulWidget {
  final Function(String activity, int duration, int calories) onParsed;

  const VoiceLoggingDialog({super.key, required this.onParsed});

  @override
  State<VoiceLoggingDialog> createState() => _VoiceLoggingDialogState();
}

class _VoiceLoggingDialogState extends State<VoiceLoggingDialog> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the microphone and start speaking...';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Microphone Permission Denied'),
              content: const Text(
                'Please enable microphone access in settings to use voice logging.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() => _isListening = false);
            _processText();
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _processText();
    }
  }

  void _processText() {
    if (_text.isEmpty || _text == 'Press the microphone and start speaking...')
      return;
    final result = VoiceParser.parse(_text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You said: "$_text"'),
            const SizedBox(height: 16),
            Text('Activity: ${result['activity']}'),
            Text('Duration: ${result['duration']} min'),
            Text('Calories: ${result['calories']} kcal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close confirmation
              setState(() {
                _text = 'Try speaking again...';
              });
            },
            child: const Text('Edit/Retry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close confirmation
              Navigator.of(context).pop(); // close voice dialog
              widget.onParsed(
                result['activity'],
                result['duration'],
                result['calories'],
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voice Logging',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _listen,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
