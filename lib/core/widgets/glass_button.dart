import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

/// Translucent tinted button. [filled] gives the solid primary variant.
/// [color] defaults to the user's accent colour.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.filled = false,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final c = color ?? g.accent;
    final enabled = onPressed != null && !loading;
    final r = BorderRadius.circular(18);
    final fg = filled
        ? AppColors.navy
        : (enabled ? g.readable(c) : g.textSecondary);

    final row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: fg),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: _Dim(
        dim: !(enabled || loading),
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: r,
              color: filled ? c : c.fade(g.isDark ? 0.12 : 0.10),
              border: Border.all(color: filled ? c : c.fade(0.55)),
            ),
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: r,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: row),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dim extends StatelessWidget {
  const _Dim({required this.dim, required this.child});
  final bool dim;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      dim ? Opacity(opacity: 0.55, child: child) : child;
}
