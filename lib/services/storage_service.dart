import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveLastRead(String text) async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      // Web storage logic
      await prefs.setString('lastRead', text);
    } else {
      // iOS storage logic - could use different storage mechanisms
      await prefs.setString('lastRead', text);
    }
  }
} 