import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _geminiKey = 'gemini_api_key';

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _geminiKey, value: key);
  }

  static Future<String?> getApiKey() async {
    return await _storage.read(key: _geminiKey);
  }

  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _geminiKey);
  }
}
