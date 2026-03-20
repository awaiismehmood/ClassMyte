import 'package:classmyte/core/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_preference';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.light) {
    _initTheme();
  }

  void _initTheme() {
    final themeStr = _prefs.getString(_key);
    if (themeStr == 'dark') {
      state = ThemeMode.dark;
    } else {
      // Default or explicit light
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    state = newTheme;
    await _prefs.setString(_key, isDark ? 'dark' : 'light');
  }
}
