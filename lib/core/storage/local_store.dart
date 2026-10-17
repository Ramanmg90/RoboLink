import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/device_config.dart';
import '../../data/models/history_event.dart';

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final storeProvider =
    Provider<LocalStore>((ref) => LocalStore(ref.watch(sharedPreferencesProvider)));

/// Thin typed wrapper over SharedPreferences.
class LocalStore {
  LocalStore(this._p);
  final SharedPreferences _p;

  static const _kDevices = 'devices.v1';
  static const _kActive = 'activeDevice.v1';
  static const _kSettings = 'settings.v1';
  static const _kHistory = 'history.v1';
  static const maxHistory = 300;

  /// null = nothing stored yet (first run) or unreadable.
  List<DeviceConfig>? loadDevices() {
    final raw = _p.getString(_kDevices);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DeviceConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDevices(List<DeviceConfig> devices) => _p.setString(
      _kDevices, jsonEncode(devices.map((d) => d.toJson()).toList()));

  String? loadActiveId() => _p.getString(_kActive);

  Future<void> saveActiveId(String? id) =>
      id == null ? _p.remove(_kActive) : _p.setString(_kActive, id);

  AppSettings loadSettings() {
    final raw = _p.getString(_kSettings);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings s) =>
      _p.setString(_kSettings, jsonEncode(s.toJson()));

  /// Throws when stored history is corrupt so the UI can show an error state.
  List<HistoryEvent> loadHistory() {
    final raw = _p.getString(_kHistory);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HistoryEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<HistoryEvent> events) => _p.setString(
      _kHistory, jsonEncode(events.map((e) => e.toJson()).toList()));

  Future<void> clearHistory() => _p.remove(_kHistory);
}
