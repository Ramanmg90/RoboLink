import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';
import '../../data/models/device_config.dart';
import '../../data/models/history_event.dart';
import '../history/history_notifier.dart';

class DevicesState {
  const DevicesState({this.devices = const [], this.activeId});
  final List<DeviceConfig> devices;
  final String? activeId;

  DeviceConfig? get active {
    for (final d in devices) {
      if (d.id == activeId) return d;
    }
    return null;
  }

  bool get hasDemo => devices.any((d) => d.isDemo);
}

String newDeviceId() => DateTime.now().microsecondsSinceEpoch.toString();

final devicesProvider =
    NotifierProvider<DevicesNotifier, DevicesState>(DevicesNotifier.new);

class DevicesNotifier extends Notifier<DevicesState> {
  LocalStore get _store => ref.read(storeProvider);

  @override
  DevicesState build() {
    var devices = _store.loadDevices();
    if (devices == null) {
      // First run: start with the simulated device so the UI is explorable.
      devices = [DeviceConfig.demo()];
      unawaited(_store.saveDevices(devices));
      unawaited(_store.saveActiveId(devices.first.id));
    }
    var active = _store.loadActiveId();
    if (!devices.any((d) => d.id == active)) {
      active = devices.isEmpty ? null : devices.first.id;
    }
    return DevicesState(devices: devices, activeId: active);
  }

  void _commit(DevicesState next) {
    state = next;
    unawaited(_store.saveDevices(next.devices));
    unawaited(_store.saveActiveId(next.activeId));
  }

  void _log(String message, String name) => ref
      .read(historyProvider.notifier)
      .add(HistoryType.settingsChanged, message, deviceName: name);

  void add(DeviceConfig config, {bool activate = true}) {
    _commit(DevicesState(
      devices: [...state.devices, config],
      activeId: activate ? config.id : state.activeId,
    ));
    _log('دستگاه افزوده شد.', config.name);
  }

  void update(DeviceConfig config) {
    _commit(DevicesState(
      devices: [for (final d in state.devices) d.id == config.id ? config : d],
      activeId: state.activeId,
    ));
    _log('تنظیمات دستگاه تغییر کرد.', config.name);
  }

  void remove(String id) {
    final removed = state.devices.where((d) => d.id == id).firstOrNull;
    final rest = state.devices.where((d) => d.id != id).toList();
    var active = state.activeId;
    if (active == id) active = rest.isEmpty ? null : rest.first.id;
    _commit(DevicesState(devices: rest, activeId: active));
    if (removed != null) _log('دستگاه حذف شد.', removed.name);
  }

  void setActive(String id) {
    if (state.activeId == id) return;
    _commit(DevicesState(devices: state.devices, activeId: id));
  }

  /// Adds the simulated device if missing and makes it active.
  void useDemo() {
    final existing = state.devices.where((d) => d.isDemo).firstOrNull;
    if (existing != null) {
      setActive(existing.id);
    } else {
      add(DeviceConfig.demo());
    }
  }
}
