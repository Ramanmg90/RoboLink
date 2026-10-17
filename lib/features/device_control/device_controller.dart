import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/connection_status.dart';
import '../../data/models/device_status.dart';
import '../../data/models/history_event.dart';
import '../../data/models/relay_state.dart';
import '../../data/services/device_gateway.dart';
import '../../data/services/gateway_provider.dart';
import '../devices/devices_notifier.dart';
import '../history/history_notifier.dart';
import '../settings/settings_notifier.dart';
import 'device_state.dart';

const kAutoRefreshInterval = Duration(seconds: 10);

String relayWord(RelayState s) => switch (s) {
      RelayState.on => 'روشن',
      RelayState.off => 'خاموش',
      RelayState.unknown => 'نامشخص',
    };

final deviceControllerProvider =
    NotifierProvider<DeviceController, DeviceState>(DeviceController.new);

/// Owns the connection to the ACTIVE device: polling, commands and state.
///
/// Rules enforced here:
///  * a command is never reported as successful until the device confirmed it
///    (command response + a fresh status read that matches the target);
///  * overlapping commands are ignored;
///  * when the device cannot be reached the relay state becomes UNKNOWN
///    instead of keeping a stale value.
class DeviceController extends Notifier<DeviceState> {
  DeviceGateway? _gateway;
  Timer? _timer;
  int _gen = 0;
  bool _refreshing = false;

  @override
  DeviceState build() {
    final config = ref.watch(devicesProvider.select((s) => s.active));
    final timeout = ref.watch(settingsProvider.select((s) => s.timeoutSeconds));
    final auto = ref.watch(settingsProvider.select((s) => s.autoRefresh));

    ref.onDispose(() {
      _gen++;
      _timer?.cancel();
      _timer = null;
      _gateway?.dispose();
      _gateway = null;
    });

    if (config == null) return const DeviceState();

    _gateway = ref.read(gatewayFactoryProvider)(config, Duration(seconds: timeout));
    if (auto) {
      _timer = Timer.periodic(kAutoRefreshInterval, (_) => refresh(silent: true));
    }
    Future.microtask(refresh);
    return DeviceState(config: config);
  }

  void _log(HistoryType type, String message) {
    final config = state.config;
    final name = config == null
        ? null
        : (config.isDemo ? '${config.name} (شبیه‌سازی)' : config.name);
    ref.read(historyProvider.notifier).add(type, message, deviceName: name);
  }

  /// Re-reads the device status. [silent] polls don't show the "checking"
  /// state.
  Future<void> refresh({bool silent = false}) async {
    final gw = _gateway;
    if (gw == null || state.commandPending || _refreshing) return;
    final gen = _gen;
    _refreshing = true;
    if (!silent) {
      state = state.copyWith(
          connection: ConnectionStatus.checking, clearError: true);
    }
    try {
      final status = await gw.fetchStatus();
      if (gen != _gen) return;
      _applyStatus(status);
    } on AppException catch (e) {
      if (gen != _gen) return;
      _applyFailure(e);
    } finally {
      _refreshing = false;
    }
  }

  void _applyStatus(DeviceStatus s) {
    final was = state.connection;
    state = state.copyWith(
      connection: ConnectionStatus.online,
      relay: s.relay,
      lastSuccessAt: DateTime.now(),
      firmwareVersion: s.firmwareVersion,
      deviceId: s.deviceId,
      clearError: true,
      clearConnectionError: true,
    );
    if (was != ConnectionStatus.online) {
      _log(HistoryType.connectionEstablished, 'اتصال با دستگاه برقرار شد.');
    }
  }

  void _applyFailure(AppException e) {
    final was = state.connection;
    state = state.copyWith(
      connection: ConnectionStatus.offline,
      relay: RelayState.unknown,
      connectionError: e.message,
    );
    if (was != ConnectionStatus.offline) {
      _log(
        HistoryType.connectionLost,
        was == ConnectionStatus.online
            ? 'اتصال با دستگاه قطع شد.'
            : 'اتصال با دستگاه برقرار نشد.',
      );
    }
  }

  /// Toggles the relay. When the current state is unknown the app does not
  /// guess a target: it re-reads the device instead.
  Future<CommandOutcome> toggle() async {
    if (state.commandPending) return CommandOutcome.noop;
    switch (state.relay) {
      case RelayState.on:
        return setRelay(RelayState.off);
      case RelayState.off:
        return setRelay(RelayState.on);
      case RelayState.unknown:
        await refresh();
        if (state.relay == RelayState.unknown) {
          return CommandOutcome(
              false, state.connectionError ?? 'وضعیت دستگاه هنوز نامشخص است.');
        }
        return const CommandOutcome(true, 'وضعیت دستگاه به‌روزرسانی شد.');
    }
  }

  Future<CommandOutcome> setRelay(RelayState target) async {
    final gw = _gateway;
    final config = state.config;
    if (gw == null || config == null || target == RelayState.unknown) {
      return CommandOutcome.noop;
    }
    if (state.commandPending) return CommandOutcome.noop;

    final gen = _gen;
    state = state.copyWith(
      commandPending: true,
      pendingTarget: target,
      clearError: true,
    );
    _log(HistoryType.commandSent,
        'فرمان «${relayWord(target)}» ارسال شد (هنوز تأیید نشده).');

    try {
      await gw.setRelay(target);
      final DeviceStatus status;
      try {
        status = await gw.fetchStatus();
      } on AppException catch (e) {
        throw CommandUnconfirmedException(
            'فرمان ارسال شد، اما تأیید وضعیت ناموفق بود. ${e.message}');
      }
      if (gen != _gen) return CommandOutcome.noop;
      if (status.relay != target) {
        throw const DeviceRejectedException(
            'دستگاه وضعیت درخواستی را تأیید نکرد.');
      }
      state = state.copyWith(commandPending: false, clearPending: true);
      _applyStatus(status);
      _log(HistoryType.commandConfirmed,
          'دستگاه تأیید کرد: رله ${relayWord(status.relay)} است.');
      return CommandOutcome(true, '${config.name} ${relayWord(target)} شد.');
    } on AppException catch (e) {
      if (gen != _gen) return CommandOutcome.noop;
      final lost = e is DeviceUnreachableException || e is DeviceTimeoutException;
      final was = state.connection;
      state = state.copyWith(
        commandPending: false,
        clearPending: true,
        errorMessage: e.message,
        relay: RelayState.unknown,
        connection: lost ? ConnectionStatus.offline : null,
        connectionError: lost ? e.message : null,
      );
      _log(HistoryType.commandFailed, e.message);
      if (lost && was != ConnectionStatus.offline) {
        _log(HistoryType.connectionLost, 'اتصال با دستگاه قطع شد.');
      }
      return CommandOutcome(false, e.message);
    }
  }
}
