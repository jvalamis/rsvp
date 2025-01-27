import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String _wpmKey = 'wpm';
  static const String _focusScaleKey = 'focusScale';
  double focusScale = 1.0;

  Settings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    focusScale = prefs.getDouble(_focusScaleKey) ?? 1.0;
  }

  static Future<void> saveWPM(int wpm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_wpmKey, wpm);
  }

  static Future<void> saveFocusScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_focusScaleKey, scale);
  }

  static Future<int> getWPM() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wpmKey) ?? 300;
  }

  static Future<double> getFocusScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_focusScaleKey) ?? 1.0;
  }
} 