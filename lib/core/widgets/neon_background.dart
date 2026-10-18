import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

/// Deep navy gradient with two soft radial glows (no blur filters, so it is
/// cheap on mid-range devices).
class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: g.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [g.bgTop, g.bgBottom],
              ),
            ),
          ),
          RepaintBoundary(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    top: -140,
                    right: -100,
                    child: _Glow(
                        color: g.accent,
                        size: 340,
                        opacity: g.isDark ? 0.20 : 0.16),
                  ),
                  Positioned(
                    bottom: -160,
                    left: -120,
                    child: _Glow(
                        color: AppColors.green,
                        size: 360,
                        opacity: g.isDark ? 0.07 : 0.08),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, required this.opacity});
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.fade(opacity), color.fade(0)]),
      ),
    );
  }
}
