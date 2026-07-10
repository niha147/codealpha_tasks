import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;

  bool get isSupported {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) return true;
    return false; // Disable TTS on desktop to avoid missing dependency crashes
  }

  Future<void> speak(String text) async {
    if (!isSupported) {
      print("TTS not supported on this platform: $text");
      return;
    }

    _flutterTts ??= FlutterTts();
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(1.0);
    await _flutterTts!.speak(text);
  }

  Future<void> stop() async {
    if (isSupported) {
      await _flutterTts?.stop();
    }
  }
}
