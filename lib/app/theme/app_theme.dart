import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import 'accent.dart';
import 'app_colors.dart';
import 'glass_theme.dart';

abstract final class AppTheme {
  static const fontFamily = 'Vazirmatn';

  static ThemeData dark([AppAccent accent = AppAccent.orange]) =>
      _build(Brightness.dark, GlassTheme.dark, accent);

  static ThemeData light([AppAccent accent = AppAccent.orange]) =>
      _build(Brightness.light, GlassTheme.light, accent);

  static ThemeData _build(Brightness brightness, GlassTheme base, AppAccent a) {
    final g = base.copyWith(accent: a.color, accentSoft: a.soft);
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: a.color,
      brightness: brightness,
    ).copyWith(
      primary: a.color,
      onPrimary: AppColors.navy,
      error: AppColors.red,
      surface: isDark ? AppColors.navy2 : Colors.white,
      onSurface: g.textPrimary,
    );

    final typography = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = typography.apply(
      fontFamily: fontFamily,
      bodyColor: g.textPrimary,
      displayColor: g.textPrimary,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: g.bgBottom,
      dividerColor: g.border,
      extensions: [g],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: g.textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: g.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: g.glassFill,
        labelStyle: TextStyle(color: g.textSecondary),
        hintStyle: TextStyle(color: g.textSecondary.withAlpha(150)),
        helperStyle: TextStyle(color: g.textSecondary),
        border: border(g.border),
        enabledBorder: border(g.border),
        focusedBorder: border(a.color, 1.6),
        errorBorder: border(AppColors.red),
        focusedErrorBorder: border(AppColors.red, 1.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: a.color,
        thumbColor: a.color,
        inactiveTrackColor: g.border,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
