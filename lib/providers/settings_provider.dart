import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum AppLanguage { english, sinhala, tamil }

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppLanguage _language = AppLanguage.english;
  bool _isDarkMode = false;

  AppLanguage get language => _language;
  bool get isDarkMode => _isDarkMode;

  // Backward-compat helpers
  bool get isSinhala => _language == AppLanguage.sinhala;
  bool get isTamil => _language == AppLanguage.tamil;

  String get languageCode {
    switch (_language) {
      case AppLanguage.sinhala:
        return 'si';
      case AppLanguage.tamil:
        return 'ta';
      default:
        return 'en';
    }
  }

  String get languageLabel {
    switch (_language) {
      case AppLanguage.sinhala:
        return 'සිංහල';
      case AppLanguage.tamil:
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  Future<void> loadSettings() async {
    final code = await _storage.loadLanguageCode();
    _language = _codeToLanguage(code);
    _isDarkMode = await _storage.loadIsDarkMode();
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    await _storage.saveLanguageCode(languageCode);
    notifyListeners();
  }

  // Keep old toggleLanguage for any existing callers
  Future<void> toggleLanguage() async {
    final next = AppLanguage.values[
        (_language.index + 1) % AppLanguage.values.length];
    await setLanguage(next);
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Translates a string to the current language.
  /// [ta] is optional — falls back to [en] if not supplied.
  String text(String en, String si, [String? ta]) {
    switch (_language) {
      case AppLanguage.sinhala:
        return si;
      case AppLanguage.tamil:
        return ta ?? en;
      default:
        return en;
    }
  }

  AppLanguage _codeToLanguage(String code) {
    switch (code) {
      case 'si':
        return AppLanguage.sinhala;
      case 'ta':
        return AppLanguage.tamil;
      default:
        return AppLanguage.english;
    }
  }
}
