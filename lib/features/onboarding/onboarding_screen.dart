import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/color_ext.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';

class _Step {
  const _Step(this.icon, this.title, this.body, {this.warning});
  final IconData icon;
  final String title;
  final String body;
  final String? warning;
}

const _steps = [
  _Step(
    Icons.electrical_services_rounded,
    'سخت‌افزار را وصل کنید',
    'سیم سیگنال رله (IN) را به پین D1 بردی Wemos وصل کنید و تغذیهٔ ماژول (۵ ولت و GND) را طبق دیتاشیت ماژول بدهید.\nبرای اولین تست فقط از بار کم‌ولتاژ استفاده کنید.',
    warning:
        'کار با برق شهر فقط با عایق‌بندی، محفظهٔ مناسب و نظارت فرد بزرگسال و مجرب.',
  ),
  _Step(
    Icons.memory_rounded,
    'فریمور را آپلود کنید',
    'در پوشهٔ firmware فایل secrets.example.h را به secrets.h کپی کنید، نام و رمز وای‌فای را بنویسید و با Arduino IDE روی برد LOLIN(WEMOS) D1 R2 & mini آپلود کنید.',
  ),
  _Step(
    Icons.wifi_find_rounded,
    'آدرس IP را پیدا کنید',
    'Serial Monitor را با سرعت ۱۱۵۲۰۰ باز کنید؛ پس از اتصال به وای‌فای، آدرس IP چاپ می‌شود. یا در پنل مودم، دستگاه «robolink» را پیدا کنید.\nبهتر است برای آن IP ثابت (DHCP Reservation) تعریف کنید و پورت روتر را هرگز باز نکنید.',
  ),
  _Step(
    Icons.task_alt_rounded,
    'اضافه و تست کنید',
    'آدرس را وارد کنید، «تست اتصال» را بزنید و بعد از پاسخ معتبر دستگاه را ذخیره کنید. دستگاه واقعی به‌عنوان دستگاه فعال جایگزین دمو می‌شود.',
  ),
];

/// Step-by-step guide for connecting the first real device.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _last => _page == _steps.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    _controller.animateToPage(
      _page + delta,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return GlassScaffold(
      title: 'راه‌اندازی دستگاه واقعی',
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) =>
                  _StepPage(step: _steps[i], number: i + 1),
            ),
          ),
          _Dots(count: _steps.length, index: _page),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                if (_page > 0) ...[
                  Expanded(
                    child: GlassButton(
                      label: 'قبلی',
                      color: g.textSecondary,
                      onPressed: () => _go(-1),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: GlassButton(
                    label: _last ? 'افزودن دستگاه' : 'بعدی',
                    icon: _last ? Icons.add_rounded : null,
                    filled: true,
                    onPressed: _last
                        ? () => context.pushReplacement('/devices/add')
                        : () => _go(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({required this.step, required this.number});
  final _Step step;
  final int number;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: g.accent.fade(0.14),
              border: Border.all(color: g.accent.fade(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: g.accent.fade(g.glowOpacity * 0.6),
                  blurRadius: 28,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Icon(step.icon, size: 42, color: g.accentText),
          ),
          const SizedBox(height: 22),
          Text(
            'مرحلهٔ ${faDigits(number)} از ${faDigits(_steps.length)}',
            style: TextStyle(color: g.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Text(
              step.body,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.9),
            ),
          ),
          if (step.warning != null) ...[
            const SizedBox(height: 12),
            GlassCard(
              borderColor: AppColors.red.fade(0.55),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: g.readable(AppColors.red)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(step.warning!,
                        style: const TextStyle(height: 1.8, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i == index ? g.accent : g.border,
            ),
          ),
      ],
    );
  }
}
