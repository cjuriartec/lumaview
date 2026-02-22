import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

ThemeMode _stringToThemeMode(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

ThemeMode nextThemeMode(ThemeMode current, Brightness platformBrightness) {
  final effective = current == ThemeMode.system &&
          platformBrightness == Brightness.dark
      ? ThemeMode.dark
      : current == ThemeMode.system
          ? ThemeMode.light
          : current;
  return effective == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    return _stringToThemeMode(stored);
  }

  Future<void> toggleTheme() async {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final current = state.asData?.value ?? ThemeMode.system;
    final next = nextThemeMode(current, platformBrightness);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeModeToString(next));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeModeToString(mode));
  }
}

final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

