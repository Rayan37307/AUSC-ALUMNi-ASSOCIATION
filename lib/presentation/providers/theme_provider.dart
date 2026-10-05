import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode provider for dark/light mode support
class ThemeProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  bool _isDarkMode = false;

  ThemeProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
