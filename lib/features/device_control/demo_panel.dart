import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/services/gateway_provider.dart';
import 'device_controller.dart';

/// Lets the user trigger error / offline (unknown) situations in demo mode.
class DemoPanel extends ConsumerWidget {
  const DemoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final sim = ref.watch(demoSimulatorProvider);
    return GlassCard(
      borderColor: AppColors.yellow.withAlpha(120),
      child: ListenableBuilder(
        listenable: sim,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('پنل شبیه‌ساز',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const StatusBadge(
                  label: 'شبیه‌سازی‌شده',
                  color: AppColors.yellow,
                  icon: Icons.science_outlined,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'در حالت دمو هیچ فرمانی به شبکه ارسال نمی‌شود. برای دیدن حالت‌های «خطا» و «نامشخص» از گزینه‌های زیر استفاده کنید.',
              style: TextStyle(color: g.textSecondary, height: 1.7, fontSize: 13),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('قطع ارتباط دستگاه'),
              subtitle: Text('وضعیت رله «نامشخص» می‌شود',
                  style: TextStyle(color: g.textSecondary, fontSize: 12)),
              value: sim.offline,
              onChanged: (v) {
                sim.setOffline(v);
                ref.read(deviceControllerProvider.notifier).refresh();
              },
            ),
            GlassButton(
              label: sim.failNext
                  ? 'خطا برای فرمان بعدی فعال است'
                  : 'شبیه‌سازی خطا در فرمان بعدی',
              icon: Icons.error_outline_rounded,
              color: AppColors.red,
              onPressed: sim.failNext
                  ? null
                  : () {
                      sim.setFailNext(true);
                      showToast(context, 'فرمان بعدی با خطا مواجه می‌شود.',
                          color: AppColors.yellow);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
