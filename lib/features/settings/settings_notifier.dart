import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';
import '../../data/models/app_settings.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(storeProvider).loadSettings();

  void update(AppSettings Function(AppSettings) change) {
    state = change(state);
    unawaited(ref.read(storeProvider).saveSettings(state));
  }

  void restoreDefaults() => update((_) => const AppSettings());
}
