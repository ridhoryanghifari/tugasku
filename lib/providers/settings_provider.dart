import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  static const _key = 'dark_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_key);
    if (v != null) {
      themeMode = v ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  bool isDark(BuildContext context) =>
      themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system &&
          MediaQuery.platformBrightnessOf(context) == Brightness.dark);

  Future<void> setDark(bool dark) async {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}
