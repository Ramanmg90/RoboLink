import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/labels.dart';
import '../../data/models/device_config.dart';
import '../../data/models/device_status.dart';
import '../../data/services/gateway_provider.dart';
import '../devices/devices_notifier.dart';
import '../settings/settings_notifier.dart';

/// Connection wizard used for both adding and editing a device.
class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _statusPath;
  late final TextEditingController _relayPath;
  late final TextEditingController _token;
  DeviceConfig? _editing;
  bool _demo = false;
  bool _testing = false;
  bool _showToken = false;
  DeviceStatus? _okStatus;
  String? _testError;
  String? _testedSig;

  @override
  void initState() {
    super.initState();
    final devices = ref.read(devicesProvider);
    final id = widget.editId;
    _editing = id == null
        ? null
        : devices.devices.where((d) => d.id == id).firstOrNull;
    final e = _editing;
    _demo = e?.isDemo ?? false;
    _name = TextEditingController(text: e?.name ?? DeviceConfig.defaultName);
    _host = TextEditingController(text: e?.host ?? '');
    _port = TextEditingController(text: '${e?.port ?? 80}');
    _statusPath = TextEditingController(text: e?.statusPath ?? '/api/status');
    _relayPath = TextEditingController(text: e?.relayPath ?? '/api/relay');
    _token = TextEditingController(text: e?.token ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _host, _port, _statusPath, _relayPath, _token]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _signature => [
        _host.text.trim(),
        _port.text.trim(),
        _statusPath.text.trim(),
        _relayPath.text.trim(),
        _token.text,
      ].join('|');

  bool get _tested => _okStatus != null && _testedSig == _signature;

  DeviceConfig _build() {
    final name = _name.text.trim();
    return DeviceConfig(
      id: _editing?.id ?? newDeviceId(),
      name: name.isEmpty ? DeviceConfig.defaultName : name,
      host: _demo ? '' : _host.text.trim(),
      port: int.tryParse(_port.text.trim()) ?? 80,
      statusPath: _statusPath.text.trim().isEmpty ? '/api/status' : _statusPath.text.trim(),
      relayPath: _relayPath.text.trim().isEmpty ? '/api/relay' : _relayPath.text.trim(),
      token: _token.text.trim(),
      isDemo: _demo,
    );
  }

  Future<void> _test() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _testing = true;
      _okStatus = null;
      _testError = null;
    });
    final timeout = Duration(seconds: ref.read(settingsProvider).timeoutSeconds);
    final gateway = ref.read(gatewayFactoryProvider)(_build(), timeout);
    try {
      final status = await gateway.fetchStatus();
      if (!mounted) return;
      setState(() {
        _okStatus = status;
        _testedSig = _signature;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _testError = e.message);
    } finally {
      gateway.dispose();
      if (mounted) setState(() => _testing = false);
    }
  }

  void _save({required bool untested}) {
    if (!(_form.currentState?.validate() ?? false)) return;
    final config = _build();
    final notifier = ref.read(devicesProvider.notifier);
    if (_editing == null) {
      notifier.add(config);
    } else {
      notifier.update(config);
    }
    showToast(
      context,
      untested ? 'دستگاه بدون تست اتصال ذخیره شد.' : 'دستگاه ذخیره شد.',
      color: AppColors.green,
      aboveNav: false,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final editing = _editing != null;
    final hasOtherDemo = ref
        .watch(devicesProvider)
        .devices
        .any((d) => d.isDemo && d.id != _editing?.id);

    return GlassScaffold(
      title: editing ? 'ویرایش دستگاه' : 'افزودن دستگاه',
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('دستگاه شبیه‌سازی‌شده (دمو)'),
                subtitle: Text(
                  hasOtherDemo
                      ? 'یک دستگاه دمو از قبل وجود دارد.'
                      : 'بدون سخت‌افزار؛ هیچ فرمانی به شبکه ارسال نمی‌شود.',
                  style: TextStyle(color: g.textSecondary, fontSize: 12),
                ),
                value: _demo,
                onChanged: hasOtherDemo && !_demo
                    ? null
                    : (v) => setState(() {
                          _demo = v;
                          _okStatus = null;
                          _testError = null;
                        }),
              ),
            ),
            const SizedBox(height: 20),
            const _StepTitle('۱', 'نام دستگاه'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: 'نام نمایشی',
                hintText: DeviceConfig.defaultName,
              ),
            ),
            if (!_demo) ...[
              const SizedBox(height: 12),
              const _StepTitle('۲', 'آدرس اتصال'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _host,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'آدرس IP یا نام میزبان',
                  hintText: '192.168.1.50',
                ),
                validator: (v) => DeviceConfig.validateHost(v ?? ''),
              ),
              const SizedBox(height: 12),
              const _IpHelp(),
              const SizedBox(height: 8),
              _Advanced(
                port: _port,
                statusPath: _statusPath,
                relayPath: _relayPath,
                token: _token,
                showToken: _showToken,
                onToggleToken: () => setState(() => _showToken = !_showToken),
              ),
              const SizedBox(height: 12),
              const _StepTitle('۳', 'بررسی اتصال'),
              const SizedBox(height: 10),
              GlassButton(
                label: 'تست اتصال',
                icon: Icons.network_check_rounded,
                loading: _testing,
                onPressed: _test,
              ),
              if (_okStatus != null || _testError != null) ...[
                const SizedBox(height: 12),
                _TestResult(status: _okStatus, error: _testError, stale: _okStatus != null && !_tested),
              ],
            ],
            const SizedBox(height: 24),
            GlassButton(
              label: editing ? 'ذخیرهٔ تغییرات' : 'ذخیره',
              icon: Icons.check_rounded,
              filled: true,
              color: AppColors.orange,
              onPressed: (_demo || _tested) ? () => _save(untested: false) : null,
            ),
            if (!_demo && !_tested) ...[
              const SizedBox(height: 10),
              GlassButton(
                label: 'ذخیره بدون تست (حالت آفلاین)',
                icon: Icons.save_outlined,
                color: g.textSecondary,
                onPressed: () => _save(untested: true),
              ),
              const SizedBox(height: 8),
              Text(
                'اگر دستگاه هنوز روشن یا آماده نیست می‌توانید بدون تست ذخیره کنید؛ وضعیت آن تا برقراری اتصال «نامشخص» می‌ماند.',
                style: TextStyle(color: g.textSecondary, fontSize: 12, height: 1.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.number, this.title);
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.orange.withAlpha(40),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orange.withAlpha(160)),
          ),
          child: Text(number,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.glass.readable(AppColors.orange))),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _IpHelp extends StatelessWidget {
  const _IpHelp();

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          title: const Text('آدرس IP دستگاه را از کجا پیدا کنم؟',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• سریال مانیتور: فریمور را روی Wemos آپلود کنید و Serial Monitor را با سرعت ۱۱۵۲۰۰ باز کنید. پس از اتصال به وای‌فای، آدرس IP چاپ می‌شود.\n'
              '• پنل مودم/روتر: وارد پنل روتر شوید و در فهرست دستگاه‌های متصل (DHCP Clients) نام «robolink» را پیدا کنید.\n'
              '• بهتر است در روتر برای دستگاه یک IP ثابت (DHCP Reservation) تعریف کنید.\n'
              '• گوشی و دستگاه باید به یک شبکهٔ وای‌فای متصل باشند.\n'
              '• هرگز برای این دستگاه پورت روتر را به اینترنت باز نکنید.\n'
              '• برنامه دستگاه را خودکار پیدا نمی‌کند؛ آدرس را باید دستی وارد کنید.',
              style: TextStyle(color: g.textSecondary, height: 1.9, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _Advanced extends StatelessWidget {
  const _Advanced({
    required this.port,
    required this.statusPath,
    required this.relayPath,
    required this.token,
    required this.showToken,
    required this.onToggleToken,
  });

  final TextEditingController port;
  final TextEditingController statusPath;
  final TextEditingController relayPath;
  final TextEditingController token;
  final bool showToken;
  final VoidCallback onToggleToken;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          title: const Text('تنظیمات پیشرفتهٔ API و توکن',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
          children: [
            TextFormField(
              controller: port,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'پورت'),
              validator: (v) => DeviceConfig.validatePort(v ?? ''),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: statusPath,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'مسیر وضعیت (GET)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: relayPath,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'مسیر رله (POST)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: token,
              obscureText: !showToken,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'توکن دسترسی (اختیاری)',
                helperText: 'باید با AUTH_TOKEN در فریمور یکی باشد.',
                suffixIcon: IconButton(
                  tooltip: showToken ? 'پنهان کردن' : 'نمایش',
                  icon: Icon(showToken
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: onToggleToken,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestResult extends StatelessWidget {
  const _TestResult({this.status, this.error, this.stale = false});
  final DeviceStatus? status;
  final String? error;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final ok = status != null;
    final color = ok ? AppColors.green : AppColors.red;
    return GlassCard(
      borderColor: color.withAlpha(160),
      glow: stale ? null : color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded,
              color: g.readable(color)),
          const SizedBox(width: 10),
          Expanded(
            child: ok
                ? Text(
                    stale
                        ? 'تنظیمات بعد از تست تغییر کرده‌اند؛ دوباره تست کنید.'
                        : 'اتصال موفق و پاسخ معتبر بود.\nشناسه: ${status!.deviceId} • فریمور: ${faDigits(status!.firmwareVersion)} • رله: ${status!.relay.label}',
                    style: const TextStyle(height: 1.8),
                  )
                : Text(error ?? '', style: const TextStyle(height: 1.8)),
          ),
        ],
      ),
    );
  }
}
