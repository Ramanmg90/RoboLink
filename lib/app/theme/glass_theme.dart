import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme tokens used by every glass component. Dark values follow the brand
/// spec; the light set keeps the same structure with readable contrast.
@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.isDark,
    required this.bgTop,
    required this.bgBottom,
    required this.glassFill,
    required this.glassFillStrong,
    required this.border,
    required this.highlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.glowOpacity,
  });

  final bool isDark;
  final Color bgTop;
  final Color bgBottom;
  final Color glassFill;
  final Color glassFillStrong;
  final Color border;
  final Color highlight;
  final Color textPrimary;
  final Color textSecondary;
  final double glowOpacity;

  static const dark = GlassTheme(
    isDark: true,
    bgTop: AppColors.navy,
    bgBottom: AppColors.navy2,
    glassFill: Color(0x1F8FA3D1),
    glassFillStrong: Color(0x338FA3D1),
    border: Color(0x2EFFFFFF),
    highlight: Color(0x14FFFFFF),
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    glowOpacity: 0.45,
  );

  static const light = GlassTheme(
    isDark: false,
    bgTop: Color(0xFFEAF0FB),
    bgBottom: Color(0xFFD7E2F4),
    glassFill: Color(0xA6FFFFFF),
    glassFillStrong: Color(0xD9FFFFFF),
    border: Color(0x33111A2E),
    highlight: Color(0x80FFFFFF),
    textPrimary: Color(0xFF0D1426),
    textSecondary: Color(0xFF4A5673),
    glowOpacity: 0.28,
  );

  /// Neon accents are too bright on light backgrounds; darken them for text.
  Color readable(Color accent) {
    if (isDark) return accent;
    return HSLColor.fromColor(accent).withLightness(0.30).toColor();
  }

  @override
  GlassTheme copyWith({
    bool? isDark,
    Color? bgTop,
    Color? bgBottom,
    Color? glassFill,
    Color? glassFillStrong,
    Color? border,
    Color? highlight,
    Color? textPrimary,
    Color? textSecondary,
    double? glowOpacity,
  }) {
    return GlassTheme(
      isDark: isDark ?? this.isDark,
      bgTop: bgTop ?? this.bgTop,
      bgBottom: bgBottom ?? this.bgBottom,
      glassFill: glassFill ?? this.glassFill,
      glassFillStrong: glassFillStrong ?? this.glassFillStrong,
      border: border ?? this.border,
      highlight: highlight ?? this.highlight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      glowOpacity: glowOpacity ?? this.glowOpacity,
    );
  }

  @override
  GlassTheme lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      isDark: t < 0.5 ? isDark : other.isDark,
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassFillStrong: Color.lerp(glassFillStrong, other.glassFillStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      glowOpacity: glowOpacity + (other.glowOpacity - glowOpacity) * t,
    );
  }
}

extension GlassContext on BuildContext {
  GlassTheme get glass => Theme.of(this).extension<GlassTheme>()!;
}
