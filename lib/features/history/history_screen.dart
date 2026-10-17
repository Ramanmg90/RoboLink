import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_widgets.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/history_event.dart';
import 'history_notifier.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(
      context,
      title: 'پاک کردن تاریخچه',
      message: 'همهٔ رویدادهای ذخیره‌شده حذف شوند؟ این کار قابل بازگشت نیست.',
      confirmLabel: 'پاک کردن',
      destructive: true,
    );
    if (ok) await ref.read(historyProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final h = ref.watch(historyProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          ScreenHeader(
            title: 'تاریخچه',
            subtitle: 'فقط رویدادهایی که برنامه در حال اجرا مشاهده کرده ثبت می‌شود.',
            trailing: IconButton(
              tooltip: 'پاک کردن تاریخچه',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: h.events.isEmpty ? null : () => _clear(context, ref),
            ),
          ),
          const SizedBox(height: 20),
          if (h.loadError != null)
            EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'خطا در خواندن تاریخچه',
              message: h.loadError!,
              actions: [
                GlassButton(
                  label: 'تلاش دوباره',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.read(historyProvider.notifier).reload(),
                ),
                GlassButton(
                  label: 'پاک کردن دادهٔ خراب',
                  color: AppColors.red,
                  onPressed: () => ref
                      .read(historyProvider.notifier)
                      .clear()
                      .then((_) => ref.read(historyProvider.notifier).reload()),
                ),
              ],
            )
          else if (h.events.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'هنوز رویدادی ثبت نشده',
              message: 'با روشن و خاموش کردن دستگاه یا تغییر تنظیمات، رویدادها اینجا نمایش داده می‌شوند.',
            )
          else
            for (final e in h.events) ...[
              _EventTile(event: e),
              const SizedBox(height: 10),
            ],
          if (h.events.isNotEmpty)
            Text('${faDigits(h.events.length)} رویداد',
                textAlign: TextAlign.center,
                style: TextStyle(color: g.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Meta {
  const _Meta(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;
}

_Meta _metaOf(HistoryType t) => switch (t) {
      HistoryType.commandSent =>
        const _Meta(Icons.send_rounded, AppColors.yellow, 'ارسال‌شده (تأیید‌نشده)'),
      HistoryType.commandConfirmed =>
        const _Meta(Icons.check_circle_rounded, AppColors.green, 'تأیید‌شده توسط دستگاه'),
      HistoryType.commandFailed =>
        const _Meta(Icons.error_rounded, AppColors.red, 'ناموفق'),
      HistoryType.connectionEstablished =>
        const _Meta(Icons.wifi_rounded, AppColors.green, 'اتصال برقرار شد'),
      HistoryType.connectionLost =>
        const _Meta(Icons.wifi_off_rounded, AppColors.red, 'اتصال قطع شد'),
      HistoryType.settingsChanged =>
        const _Meta(Icons.tune_rounded, AppColors.orange, 'تغییر تنظیمات'),
    };

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final m = _metaOf(event.type);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(m.icon, color: g.readable(m.color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(label: m.label, color: m.color),
                const SizedBox(height: 8),
                Text(event.message, style: const TextStyle(height: 1.7)),
                const SizedBox(height: 6),
                Text(
                  '${event.deviceName == null ? '' : '${event.deviceName} • '}${formatJalaliDateTime(event.time)}',
                  style: TextStyle(color: g.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
