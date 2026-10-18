import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

/// Frosted glass panel: thin border, soft highlight and an optional neon glow.
///
/// Blur is OFF by default ([blur] = 0): cards sit on a plain gradient, so a
/// backdrop blur would cost GPU time without changing what you see. Enable it
/// only for surfaces that overlap content (navigation bar, dialogs).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.glow,
    this.borderColor,
    this.onTap,
    this.blur = 0,
    this.solid = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? glow;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double blur;

  /// Adds an opaque-ish base so text stays readable (dialogs).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final r = BorderRadius.circular(radius);
    final content = Padding(padding: padding, child: child);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        color: solid ? g.bgBottom.fade(0.92) : null,
        border: Border.all(color: borderColor ?? g.border),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [g.highlight, g.glassFill],
        ),
      ),
      // A Material inside the card makes ListTile/InkWell splashes paint above
      // the glass instead of behind the page background.
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, borderRadius: r, child: content),
      ),
    );

    if (blur > 0) {
      surface = ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: surface,
        ),
      );
    }

    if (glow == null) return surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: glow!.fade(g.glowOpacity),
            blurRadius: 26,
            spreadRadius: -4,
          ),
        ],
      ),
      child: surface,
    );
  }
}
