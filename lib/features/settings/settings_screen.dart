import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/accent.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/constants/app_info.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_widgets.dart';
import '../../data/models/app_settings.dart';
import 'settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.glass;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, navClearance(context)),
        children: [
          const ScreenHeader(title: 'تنظیمات'),
          const SizedBox(height: 20),
          _Section(
            title: 'نمایش',
            children: [
              const Text('پوسته'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    foregroundColor: g.textPrimary,
                    selectedForegroundColor: g.accentText,
                    selectedBackgroundColor: g.accent.withAlpha(45),
                  ),
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('سیستم')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('تیره')),
                    ButtonSegment(value: ThemeMode.light, label: Text('روشن')),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) =>
                      n.update((o) => o.copyWith(themeMode: v.first)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('رنگ تأکیدی'),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final a in AppAccent.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: _AccentDot(
                        accent: a,
                        selected: s.accent == a,
                        onTap: () => n.update((o) => o.copyWith(accent: a)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('سبز و قرمز برای وضعیت روشن/خاموش رزرو شده‌اند.',
                  style: TextStyle(color: g.textSecondary, fontSize: 12)),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('زبان'),
                subtitle: Text('زبان‌های دیگر در نسخه‌های بعدی اضافه می‌شوند.',
                    style: TextStyle(color: g.textSecondary, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('فارسی',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Icon(Icons.check_rounded, color: g.readable(AppColors.green)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'اتصال به دستگاه',
            children: [
              Row(
                children: [
                  const Expanded(child: Text('مهلت درخواست')),
                  Text('${faDigits(s.timeoutSeconds)} ثانیه',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                min: AppSettings.minTimeout.toDouble(),
                max: AppSettings.maxTimeout.toDouble(),
                divisions: AppSettings.maxTimeout - AppSettings.minTimeout,
                value: s.timeoutSeconds.toDouble(),
                label: faDigits(s.timeoutSeconds),
                onChanged: (v) =>
                    n.update((o) => o.copyWith(timeoutSeconds: v.round())),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('بازخوانی خودکار وضعیت'),
                subtitle: Text('هر ۱۰ ثانیه وضعیت دستگاه بررسی می‌شود.',
                    style: TextStyle(color: g.textSecondary, fontSize: 12)),
                value: s.autoRefresh,
                onChanged: (v) => n.update((o) => o.copyWith(autoRefresh: v)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('دستگاه‌ها و تنظیمات اتصال'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => context.go('/devices'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('راهنمای راه‌اندازی دستگاه واقعی'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => context.push('/setup'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'تعامل',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('بازخورد لمسی'),
                subtitle: Text('لرزش کوتاه هنگام لمس کلید برق',
                    style: TextStyle(color: g.textSecondary, fontSize: 12)),
                value: s.haptics,
                onChanged: (v) => n.update((o) => o.copyWith(haptics: v)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'دربارهٔ برنامه',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نسخهٔ برنامه'),
                trailing: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(AppInfo.version,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('دربارهٔ RoboLink'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => _showAbout(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'بازگردانی تنظیمات پیش‌فرض',
            icon: Icons.restore_rounded,
            color: AppColors.red,
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'بازگردانی پیش‌فرض',
                message:
                    'تنظیمات برنامه به حالت اولیه برمی‌گردد. دستگاه‌ها و تاریخچه حذف نمی‌شوند.',
                confirmLabel: 'بازگردانی',
                destructive: true,
              );
              if (ok) {
                n.restoreDefaults();
                if (context.mounted) {
                  showToast(context, 'تنظیمات پیش‌فرض بازگردانده شد.',
                      color: AppColors.green);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final g = context.glass;
    showDialog<void>(
      context: context,
      builder: (ctx) => GlassDialog(
        title: 'دربارهٔ RoboLink',
        content: Text(
          'RoboLink یک برنامهٔ کنترل برق هوشمند برای رلهٔ متصل به Wemos D1 mini (ESP8266) است. ارتباط در نسخهٔ ۱ فقط از طریق شبکهٔ محلی وای‌فای و API ساده‌ی HTTP انجام می‌شود.\n\n'
          'هشدار ایمنی: برای آزمایش اولیه از بار کم‌ولتاژ استفاده کنید. کار با برق شهر فقط با عایق‌بندی، محفظهٔ مناسب و نظارت فرد بزرگسال و مجرب انجام شود.',
          style: TextStyle(color: g.textSecondary, height: 1.8),
        ),
        actions: [
          GlassButton(
            label: 'بستن',
            filled: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: g.accentText)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return Semantics(
      button: true,
      selected: selected,
      label: 'رنگ ${accent.label}',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.color,
            border: Border.all(
              color: selected ? g.textPrimary : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: AppColors.navy)
              : null,
        ),
      ),
    );
  }
}
