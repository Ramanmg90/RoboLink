import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/labels.dart';
import '../../core/widgets/section_widgets.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/device_config.dart';
import '../device_control/device_controller.dart';
import 'devices_notifier.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  Future<void> _remove(
      BuildContext context, WidgetRef ref, DeviceConfig d) async {
    final ok = await confirmDialog(
      context,
      title: 'حذف دستگاه',
      message: 'دستگاه «${d.name}» از برنامه حذف شود؟ این کار روی خود سخت‌افزار اثری ندارد.',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (ok) ref.read(devicesProvider.notifier).remove(d.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final devices = ref.watch(devicesProvider);
    final live = ref.watch(deviceControllerProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, navClearance(context)),
        children: [
          ScreenHeader(
            title: 'دستگاه‌ها',
            subtitle: 'نسخهٔ ۱: فقط دستگاه فعال پایش و کنترل می‌شود.',
            trailing: IconButton.filled(
              tooltip: 'افزودن دستگاه',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.navy,
              ),
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/devices/add'),
            ),
          ),
          const SizedBox(height: 20),
          if (devices.devices.isEmpty)
            EmptyState(
              icon: Icons.devices_other_rounded,
              title: 'دستگاهی ثبت نشده',
              message: 'با دکمهٔ «افزودن» یک دستگاه واقعی تعریف کنید یا حالت دمو را فعال کنید.',
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
          else
            for (final d in devices.devices) ...[
              _DeviceTile(
                device: d,
                isActive: d.id == devices.activeId,
                live: d.id == devices.activeId ? live : null,
                onTap: () {
                  ref.read(devicesProvider.notifier).setActive(d.id);
                  context.push('/device');
                },
                onEdit: () => context.push('/devices/edit/${d.id}'),
                onRemove: () => _remove(context, ref, d),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 4),
          Text(
            'دستگاه‌های دیگر پایش نمی‌شوند؛ برای دیدن وضعیت و کنترل آن‌ها، دستگاه را فعال کنید.',
            style: TextStyle(color: g.textSecondary, fontSize: 12, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.isActive,
    required this.live,
    required this.onTap,
    required this.onEdit,
    required this.onRemove,
  });

  final DeviceConfig device;
  final bool isActive;
  final dynamic live; // DeviceState? (only for the active device)
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return GlassCard(
      onTap: onTap,
      borderColor: isActive ? AppColors.orange.withAlpha(150) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.lightbulb_outline_rounded,
                    color: g.readable(AppColors.orange)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        device.isDemo ? 'simulated' : device.host,
                        style: TextStyle(color: g.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'ویرایش',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'حذف',
                icon: Icon(Icons.delete_outline_rounded,
                    color: g.readable(AppColors.red)),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (isActive)
                const StatusBadge(
                    label: 'دستگاه فعال',
                    color: AppColors.orange,
                    icon: Icons.check_circle_outline_rounded),
              if (device.isDemo)
                const StatusBadge(
                    label: 'شبیه‌سازی‌شده',
                    color: AppColors.yellow,
                    icon: Icons.science_outlined),
              if (live != null) ...[
                ConnectionBadge(status: live.connection),
                RelayBadge(state: live.relay),
              ] else
                StatusBadge(label: 'پایش نمی‌شود', color: g.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
