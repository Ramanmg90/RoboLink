import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';

/// Text-and-symbol brand mark. The product name stays LTR in RTL layouts.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.orange, Color(0xFFFFB35C)],
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.orange.fade(0.45),
                  blurRadius: 16,
                  spreadRadius: -3),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: AppColors.navy, size: 24),
        ),
        const SizedBox(width: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            'RoboLink',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: g.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
