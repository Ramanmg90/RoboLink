import 'package:flutter/material.dart';

import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.busy = false,
  });

  final String label;
  final Color color;
  final IconData? icon;

  /// Shows a small spinner instead of the icon/dot.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final fg = g.readable(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.fade(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.fade(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          else if (icon != null)
            Icon(icon, size: 14, color: fg)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
