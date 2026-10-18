import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

enum PowerVisual { off, on, pending, error, unknown }

/// Large circular glass power control.
///  off     -> muted surface, red accent
///  on      -> green neon glow
///  pending -> rotating yellow ring (taps are ignored)
///  error   -> red warning
///  unknown -> neutral, does not imply OFF
class PowerButton extends StatefulWidget {
  const PowerButton({
    super.key,
    required this.visual,
    required this.onPressed,
    this.size = 200,
  });

  final PowerVisual visual;
  final VoidCallback? onPressed;
  final double size;

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.visual == PowerVisual.pending) _spin.repeat();
  }

  @override
  void didUpdateWidget(PowerButton old) {
    super.didUpdateWidget(old);
    if (widget.visual == PowerVisual.pending) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  String get _semanticLabel => switch (widget.visual) {
        PowerVisual.on => 'کلید برق، روشن',
        PowerVisual.off => 'کلید برق، خاموش',
        PowerVisual.pending => 'کلید برق، در حال ارسال فرمان',
        PowerVisual.error => 'کلید برق، خطا',
        PowerVisual.unknown => 'کلید برق، وضعیت نامشخص',
      };

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final size = widget.size;
    final v = widget.visual;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final Color accent = switch (v) {
      PowerVisual.on => AppColors.green,
      PowerVisual.off => AppColors.red,
      PowerVisual.pending => AppColors.yellow,
      PowerVisual.error => AppColors.red,
      PowerVisual.unknown => g.textSecondary,
    };
    final double glow = switch (v) {
      PowerVisual.on => 0.55,
      PowerVisual.pending => 0.30,
      PowerVisual.error => 0.35,
      _ => 0.0,
    };
    final icon = v == PowerVisual.error
        ? Icons.warning_amber_rounded
        : Icons.power_settings_new_rounded;
    final iconColor = g.readable(accent);
    final enabled = v != PowerVisual.pending && widget.onPressed != null;

    return RepaintBoundary(
      child: Semantics(
      button: true,
      enabled: enabled,
      label: _semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    g.glassFillStrong,
                    g.isDark ? AppColors.navy.fade(0.85) : g.bgTop,
                  ],
                ),
                border: Border.all(color: accent.fade(0.85), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: accent.fade(glow),
                    blurRadius: 44,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            if (v == PowerVisual.pending)
              RepaintBoundary(
                child: RotationTransition(
                  turns: reduceMotion
                      ? const AlwaysStoppedAnimation<double>(0)
                      : _spin,
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: CustomPaint(painter: _ArcPainter(accent)),
                  ),
                ),
              ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? widget.onPressed : null,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        size: size * 0.38,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc((Offset.zero & size).deflate(3), 0, 1.8, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
