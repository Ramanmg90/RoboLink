import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'glass_theme.dart';

abstract final class AppTheme {
  static const fontFamily = 'Vazirmatn';

  static ThemeData dark() => _build(Brightness.dark, GlassTheme.dark);
  static ThemeData light() => _build(Brightness.light, GlassTheme.light);

  static ThemeData _build(Brightness brightness, GlassTheme g) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.orange,
      onPrimary: AppColors.navy,
      error: AppColors.red,
      surface: isDark ? AppColors.navy2 : Colors.white,
      onSurface: g.textPrimary,
    );

    final base = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = base.apply(
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
        focusedBorder: border(AppColors.orange, 1.6),
        errorBorder: border(AppColors.red),
        focusedErrorBorder: border(AppColors.red, 1.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.orange,
        thumbColor: AppColors.orange,
        inactiveTrackColor: g.border,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
