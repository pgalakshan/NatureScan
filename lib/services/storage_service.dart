import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _langKey = 'settings_language_code'; // 'en'|'si'|'ta'
  static const String _darkModeKey = 'settings_dark_mode';

  // ── Language ──────────────────────────────────────────────
  Future<String> loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'en';
  }

  Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  // ── Dark Mode ─────────────────────────────────────────────
  Future<bool> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveIsDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
