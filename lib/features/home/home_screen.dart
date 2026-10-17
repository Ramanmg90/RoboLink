import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/labels.dart';
import '../../core/widgets/power_button.dart';
import '../../core/widgets/section_widgets.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/connection_status.dart';
import '../device_control/demo_panel.dart';
import '../device_control/device_controller.dart';
import '../device_control/device_state.dart';
import '../device_control/power_panel.dart';
import '../devices/devices_notifier.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) return 'صبح بخیر';
  if (h >= 12 && h < 17) return 'ظهر بخیر';
  if (h >= 17 && h < 20) return 'عصر بخیر';
  return 'شب بخیر';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(deviceControllerProvider);
    final devices = ref.watch(devicesProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Row(
            children: [
              const BrandMark(),
              const Spacer(),
              ConnectionBadge(status: s.connection),
            ],
          ),
          const SizedBox(height: 24),
          ScreenHeader(title: _greeting(), subtitle: 'کنترل برق هوشمند شما'),
          const SizedBox(height: 20),
          _Summary(state: s, total: devices.devices.length),
          const SizedBox(height: 16),
          if (!s.hasDevice)
            EmptyState(
              icon: Icons.power_off_outlined,
              title: 'هنوز دستگاهی فعال نیست',
              message:
                  'یک دستگاه واقعی اضافه کنید یا برای دیدن برنامه بدون سخت‌افزار، حالت دمو را فعال کنید.',
              actions: [
                GlassButton(
                  label: 'افزودن دستگاه',
                  icon: Icons.add_rounded,
                  filled: true,
                  onPressed: () => context.push('/devices/add'),
                ),
                GlassButton(
                  label: 'فعال‌سازی حالت دمو',
                  icon: Icons.science_outlined,
                  color: AppColors.yellow,
                  onPressed: () => ref.read(devicesProvider.notifier).useDemo(),
                ),
              ],
            )
          else ...[
            _DeviceCard(state: s),
            if (s.isDemo) ...[
              const SizedBox(height: 16),
              const DemoPanel(),
            ],
          ],
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state, required this.total});
  final DeviceState state;
  final int total;

  @override
  Widget build(BuildContext context) {
    // Only the active device is monitored in v1; the others are "unknown".
    var online = 0, offline = 0, unknown = 0;
    if (state.hasDevice) {
      switch (state.connection) {
        case ConnectionStatus.online:
          online = 1;
        case ConnectionStatus.offline:
          offline = 1;
        default:
          unknown = 1;
      }
      unknown += total - 1;
    } else {
      unknown = total;
    }
    final g = context.glass;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          _Stat('آنلاین', online, g.readable(AppColors.green)),
          _Stat('آفلاین', offline, g.readable(AppColors.red)),
          _Stat('نامشخص', unknown, g.textSecondary),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return Expanded(
      child: Semantics(
        label: '$label: ${faDigits(count)}',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(faDigits(count),
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: g.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  const _DeviceCard({required this.state});
  final DeviceState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final cfg = state.config!;
    final glow = state.visual == PowerVisual.on
        ? AppColors.green
        : (state.visual == PowerVisual.error ? AppColors.red : null);
    return GlassCard(
      glow: glow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/device'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: g.readable(AppColors.orange)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cfg.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            RelayBadge(state: state.relay),
                            if (cfg.isDemo)
                              const StatusBadge(
                                label: 'شبیه‌سازی‌شده',
                                color: AppColors.yellow,
                                icon: Icons.science_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: g.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: PowerPanel(size: 190)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'اتصال مجدد',
                  icon: Icons.refresh_rounded,
                  loading: state.connection == ConnectionStatus.checking,
                  onPressed: state.commandPending
                      ? null
                      : () => ref
                          .read(deviceControllerProvider.notifier)
                          .refresh(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: 'جزئیات',
                  icon: Icons.tune_rounded,
                  color: g.textSecondary,
                  onPressed: () => context.push('/device'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
