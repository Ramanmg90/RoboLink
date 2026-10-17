import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

/// Frosted glass panel: restrained blur, thin border, soft highlight and an
/// optional neon glow outside the clip.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.glow,
    this.borderColor,
    this.onTap,
    this.blur = 12,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: glow == null
            ? null
            : [
                BoxShadow(
                  color: glow!.a(g.glowOpacity),
                  blurRadius: 26,
                  spreadRadius: -4,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              color: solid ? g.bgBottom.a(0.9) : null,
              border: Border.all(color: borderColor ?? g.border),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [g.highlight, g.glassFill],
              ),
            ),
            // A Material inside the card makes ListTile/InkWell splashes
            // paint above the glass instead of behind the page background.
            child: Material(
              type: MaterialType.transparency,
              child: onTap == null
                  ? content
                  : InkWell(onTap: onTap, borderRadius: r, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
