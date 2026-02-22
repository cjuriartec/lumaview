import 'package:flutter/material.dart';
import 'package:lumaview/core/theme/app_theme.dart';

class ThemeUtils {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceColor(BuildContext context) =>
      isDark(context) ? AppTheme.darkSurface : AppTheme.lightSurface;
}

