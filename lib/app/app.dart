import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/device_control/device_controller.dart';
import '../features/settings/settings_notifier.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RoboLinkApp extends ConsumerStatefulWidget {
  const RoboLinkApp({super.key});

  @override
  ConsumerState<RoboLinkApp> createState() => _RoboLinkAppState();
}

class _RoboLinkAppState extends ConsumerState<RoboLinkApp>
    with WidgetsBindingObserver {
  final _router = createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Returning to the app (e.g. after switching Wi-Fi) re-checks the device.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(deviceControllerProvider.notifier).refresh(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    return MaterialApp.router(
      title: 'RoboLink',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(accent),
      darkTheme: AppTheme.dark(accent),
      themeMode: mode,
      routerConfig: _router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
