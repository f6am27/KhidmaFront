import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromStorage();
  }

  // تحميل الثيم المحفوظ من التخزين
  void _loadThemeFromStorage() async {
    try {
      _isDarkMode = await StorageService.getThemeMode();
      notifyListeners();
    } catch (e) {
      // في حالة وجود خطأ، استخدم الثيم الافتراضي
      _isDarkMode = false;
    }
  }

  // تبديل الثيم
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  // تعيين الثيم مباشرة
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await StorageService.saveThemeMode(_isDarkMode);
      notifyListeners();
    }
  }
}
