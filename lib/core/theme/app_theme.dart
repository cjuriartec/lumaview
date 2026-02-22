import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF00C583);
  static const Color lightOnBackground = Color(0xFF111827);
  static const Color lightOnSurface = Color(0xFF111827);
  static const Color lightSecondary = Color(0xFF0EA5E9);

  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color darkSurface = Color(0xFF020617);
  static const Color darkPrimary = Color(0xFF00D492);
  static const Color darkOnBackground = Color(0xFFF9FAFB);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkSecondary = Color(0xFF38BDF8);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimary,
        brightness: Brightness.light,
        surface: lightSurface,
        onSurface: lightOnSurface,
        primary: lightPrimary,
        secondary: lightSecondary,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
        surface: darkSurface,
        onSurface: darkOnSurface,
        primary: darkPrimary,
        secondary: darkSecondary,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
