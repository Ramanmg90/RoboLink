import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/power_button.dart';
import '../../data/models/connection_status.dart';
import '../../data/models/relay_state.dart';
import '../settings/settings_notifier.dart';
import 'device_controller.dart';
import 'device_state.dart';

/// Power button + one-line status caption, shared by Home and Device screens.
class PowerPanel extends ConsumerWidget {
  const PowerPanel({super.key, this.size = 200});
  final double size;

  String _caption(DeviceState s) {
    switch (s.visual) {
      case PowerVisual.pending:
        return 'در حال ارسال فرمان «${relayWord(s.pendingTarget ?? RelayState.unknown)}»… منتظر تأیید دستگاه';
      case PowerVisual.error:
        return s.errorMessage ?? 'خطا در اجرای فرمان';
      case PowerVisual.on:
        return 'روشن — تأیید‌شده توسط دستگاه';
      case PowerVisual.off:
        return 'خاموش — تأیید‌شده توسط دستگاه';
      case PowerVisual.unknown:
        if (s.connection == ConnectionStatus.checking) {
          return 'در حال بررسی وضعیت دستگاه…';
        }
        if (s.connection == ConnectionStatus.offline) {
          return 'دستگاه در دسترس نیست — وضعیت رله نامشخص است. برای تلاش دوباره، کلید را بزنید.';
        }
        return 'وضعیت رله نامشخص است. برای بررسی، کلید را بزنید.';
    }
  }

  Color _captionColor(DeviceState s, GlassTheme g) => switch (s.visual) {
        PowerVisual.error => g.readable(AppColors.red),
        PowerVisual.pending => g.readable(AppColors.yellow),
        PowerVisual.on => g.readable(AppColors.green),
        _ => g.textSecondary,
      };

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    if (ref.read(settingsProvider).haptics) {
      HapticFeedback.mediumImpact();
    }
    final outcome = await ref.read(deviceControllerProvider.notifier).toggle();
    if (!context.mounted || outcome.ignored || outcome.message.isEmpty) return;
    showToast(
      context,
      outcome.message,
      color: outcome.ok ? AppColors.green : AppColors.red,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final s = ref.watch(deviceControllerProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PowerButton(
          visual: s.visual,
          size: size,
          onPressed: s.hasDevice ? () => _onTap(context, ref) : null,
        ),
        const SizedBox(height: 18),
        Semantics(
          liveRegion: true,
          child: Text(
            _caption(s),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _captionColor(s, g),
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
