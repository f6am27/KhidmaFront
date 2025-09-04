import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language';

  // حفظ وضع الثيم
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // قراءة وضع الثيم
  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // افتراضي: الثيم الفاتح
  }

  // حفظ اللغة (للمستقبل)
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // قراءة اللغة
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'fr'; // افتراضي: الفرنسية
  }
}
