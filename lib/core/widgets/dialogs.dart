import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../utils/color_ext.dart';
import 'glass_button.dart';
import 'glass_card.dart';

class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: GlassCard(
        radius: 28,
        blur: 20,
        solid: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            content,
            const SizedBox(height: 20),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns true only when the user explicitly confirms.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final g = context.glass;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => GlassDialog(
      title: title,
      content: Text(message, style: TextStyle(color: g.textSecondary, height: 1.7)),
      actions: [
        GlassButton(
          label: 'انصراف',
          color: g.textSecondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        GlassButton(
          label: confirmLabel,
          color: destructive ? AppColors.red : AppColors.orange,
          filled: !destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Asks for one line of text. Returns null when cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  int maxLength = 30,
}) {
  final controller = TextEditingController(text: initial);
  final g = context.glass;
  return showDialog<String>(
    context: context,
    builder: (ctx) => GlassDialog(
      title: title,
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: maxLength,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        GlassButton(
          label: 'انصراف',
          color: g.textSecondary,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        GlassButton(
          label: 'ذخیره',
          filled: true,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
        ),
      ],
    ),
  );
}

void showToast(
  BuildContext context,
  String message, {
  Color color = AppColors.orange,
  bool aboveNav = true,
}) {
  final g = context.glass;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: g.bgBottom,
        margin: EdgeInsets.fromLTRB(16, 0, 16, aboveNav ? 100 : 24),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.fade(0.7)),
        ),
        content: Text(message, style: TextStyle(color: g.textPrimary)),
      ),
    );
}
