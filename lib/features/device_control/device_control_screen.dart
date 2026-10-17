import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/labels.dart';
import '../../core/widgets/section_widgets.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/connection_status.dart';
import '../devices/devices_notifier.dart';
import 'demo_panel.dart';
import 'device_controller.dart';
import 'power_panel.dart';

class DeviceControlScreen extends ConsumerWidget {
  const DeviceControlScreen({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final cfg = ref.read(deviceControllerProvider).config;
    if (cfg == null) return;
    final name = await promptText(
      context,
      title: 'نام نمایشی دستگاه',
      initial: cfg.name,
      hint: 'مثلاً چراغ اتاق',
    );
    if (name == null || name.isEmpty || name == cfg.name) return;
    ref.read(devicesProvider.notifier).update(cfg.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final s = ref.watch(deviceControllerProvider);
    final cfg = s.config;

    if (cfg == null) {
      return GlassScaffold(
        title: 'کنترل دستگاه',
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: EmptyState(
            icon: Icons.power_off_outlined,
            title: 'دستگاهی فعال نیست',
            message: 'ابتدا یک دستگاه اضافه یا حالت دمو را فعال کنید.',
            actions: [
              GlassButton(
                label: 'رفتن به دستگاه‌ها',
                onPressed: () => context.go('/devices'),
              ),
            ],
          ),
        ),
      );
    }

    final address = cfg.isDemo
        ? 'شبیه‌سازی‌شده (بدون شبکه)'
        : '${cfg.host.trim()}${cfg.host.contains(':') || cfg.host.contains('://') ? '' : ':${faDigits(cfg.port)}'}';

    return GlassScaffold(
      title: 'کنترل دستگاه',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: g.readable(AppColors.orange)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cfg.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'ویرایش نام',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _rename(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            glow: s.relay.name == 'on' ? AppColors.green : null,
            child: const Center(child: PowerPanel(size: 220)),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                InfoRow(
                  label: 'وضعیت اتصال',
                  trailing: ConnectionBadge(status: s.connection),
                ),
                InfoRow(
                  label: 'وضعیت رله',
                  trailing: RelayBadge(state: s.relay),
                ),
                InfoRow(
                  label: 'آخرین ارتباط موفق',
                  value: s.lastSuccessAt == null
                      ? 'هنوز ارتباطی برقرار نشده'
                      : '${formatRelative(s.lastSuccessAt!)}\n${formatJalaliDateTime(s.lastSuccessAt!)}',
                ),
                InfoRow(label: 'آدرس IP', value: address),
                if (s.firmwareVersion != null)
                  InfoRow(
                      label: 'نسخهٔ فریمور', value: faDigits(s.firmwareVersion)),
                if (s.deviceId != null)
                  InfoRow(label: 'شناسهٔ دستگاه', value: s.deviceId),
                if (s.connectionError != null &&
                    s.connection == ConnectionStatus.offline)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      s.connectionError!,
                      style: TextStyle(
                          color: g.readable(AppColors.red), height: 1.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'اتصال مجدد',
            icon: Icons.refresh_rounded,
            filled: true,
            loading: s.connection == ConnectionStatus.checking,
            onPressed: s.commandPending
                ? null
                : () async {
                    await ref.read(deviceControllerProvider.notifier).refresh();
                    if (!context.mounted) return;
                    final now = ref.read(deviceControllerProvider);
                    final ok = now.connection == ConnectionStatus.online;
                    showToast(
                      context,
                      ok
                          ? 'اتصال برقرار است.'
                          : (now.connectionError ?? 'اتصال برقرار نشد.'),
                      color: ok ? AppColors.green : AppColors.red,
                      aboveNav: false,
                    );
                  },
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'ویرایش تنظیمات اتصال',
            icon: Icons.settings_ethernet_rounded,
            color: g.textSecondary,
            onPressed: () => context.push('/devices/edit/${cfg.id}'),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: g.textSecondary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('زمان‌بندی',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const StatusBadge(
                  label: 'در نسخه‌های بعدی',
                  color: AppColors.orange,
                ),
              ],
            ),
          ),
          if (s.isDemo) ...[
            const SizedBox(height: 16),
            const DemoPanel(),
          ],
        ],
      ),
    );
  }
}
