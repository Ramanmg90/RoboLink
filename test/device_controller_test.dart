import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robolink/core/errors/app_exception.dart';
import 'package:robolink/core/storage/key_value_store.dart';
import 'package:robolink/core/storage/local_store.dart';
import 'package:robolink/core/widgets/power_button.dart';
import 'package:robolink/data/models/connection_status.dart';
import 'package:robolink/data/models/device_status.dart';
import 'package:robolink/data/models/history_event.dart';
import 'package:robolink/data/models/relay_state.dart';
import 'package:robolink/data/services/device_gateway.dart';
import 'package:robolink/data/services/gateway_provider.dart';
import 'package:robolink/features/device_control/device_controller.dart';
import 'package:robolink/features/history/history_notifier.dart';

class FakeGateway implements DeviceGateway {
  RelayState relay = RelayState.off;
  bool offline = false;
  bool reject = false;
  bool lieAboutState = false;
  int setCalls = 0;
  Completer<void>? gate;

  @override
  Future<DeviceStatus> fetchStatus() async {
    if (offline) throw const DeviceUnreachableException();
    return DeviceStatus(
        deviceId: 'fake', online: true, relay: relay, firmwareVersion: '1.0.0');
  }

  @override
  Future<RelayState> setRelay(RelayState target) async {
    setCalls++;
    if (gate != null) await gate!.future;
    if (offline) throw const DeviceTimeoutException();
    if (reject) throw const DeviceRejectedException('رد شد');
    if (!lieAboutState) relay = target;
    return target;
  }

  @override
  void dispose() {}
}

Future<(ProviderContainer, FakeGateway)> setup() async {
  final fake = FakeGateway();
  final container = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
    gatewayFactoryProvider.overrideWithValue((config, timeout) => fake),
  ]);
  addTearDown(container.dispose);
  container.read(deviceControllerProvider); // build + initial refresh
  await pumpEventQueue();
  return (container, fake);
}

List<HistoryType> types(ProviderContainer c) =>
    c.read(historyProvider).events.map((e) => e.type).toList();

void main() {
  test('initial refresh reaches ONLINE with the device relay state', () async {
    final (c, fake) = await setup();
    fake.relay = RelayState.off;
    final s = c.read(deviceControllerProvider);
    expect(s.connection, ConnectionStatus.online);
    expect(s.relay, RelayState.off);
    expect(s.visual, PowerVisual.off);
    expect(s.lastSuccessAt, isNotNull);
    expect(types(c), contains(HistoryType.connectionEstablished));
  });

  test('toggle succeeds only after the device confirms', () async {
    final (c, fake) = await setup();
    final ctrl = c.read(deviceControllerProvider.notifier);
    final outcome = await ctrl.toggle();
    expect(outcome.ok, isTrue);
    expect(fake.relay, RelayState.on);
    final s = c.read(deviceControllerProvider);
    expect(s.relay, RelayState.on);
    expect(s.commandPending, isFalse);
    expect(s.visual, PowerVisual.on);
    final t = types(c);
    expect(t, containsAll([HistoryType.commandSent, HistoryType.commandConfirmed]));
    // newest first: confirmed must come after sent chronologically
    expect(t.indexOf(HistoryType.commandConfirmed) <
        t.indexOf(HistoryType.commandSent), isTrue);
  });

  test('state is PENDING while a command is in flight and duplicates are ignored',
      () async {
    final (c, fake) = await setup();
    fake.gate = Completer<void>();
    final ctrl = c.read(deviceControllerProvider.notifier);
    final first = ctrl.toggle();
    await pumpEventQueue();
    expect(c.read(deviceControllerProvider).visual, PowerVisual.pending);

    final second = await ctrl.toggle();
    expect(second.ignored, isTrue);

    fake.gate!.complete();
    final r = await first;
    expect(r.ok, isTrue);
    expect(fake.setCalls, 1);
  });

  test('rejected command -> ERROR visual, relay UNKNOWN, failure logged', () async {
    final (c, fake) = await setup();
    fake.reject = true;
    final r = await c.read(deviceControllerProvider.notifier).toggle();
    expect(r.ok, isFalse);
    final s = c.read(deviceControllerProvider);
    expect(s.visual, PowerVisual.error);
    expect(s.relay, RelayState.unknown);
    expect(s.commandPending, isFalse);
    expect(types(c), contains(HistoryType.commandFailed));
  });

  test('device that does not confirm the target state is reported as failure',
      () async {
    final (c, fake) = await setup();
    fake.lieAboutState = true;
    final r = await c.read(deviceControllerProvider.notifier).toggle();
    expect(r.ok, isFalse);
    expect(c.read(deviceControllerProvider).visual, PowerVisual.error);
    expect(types(c), isNot(contains(HistoryType.commandConfirmed)));
  });

  test('unreachable device -> OFFLINE and relay UNKNOWN (not OFF)', () async {
    final (c, fake) = await setup();
    fake.offline = true;
    await c.read(deviceControllerProvider.notifier).refresh();
    final s = c.read(deviceControllerProvider);
    expect(s.connection, ConnectionStatus.offline);
    expect(s.relay, RelayState.unknown);
    expect(s.visual, PowerVisual.unknown);
    expect(types(c), contains(HistoryType.connectionLost));
  });

  test('toggle with unknown relay re-reads the device instead of guessing',
      () async {
    final (c, fake) = await setup();
    fake.offline = true;
    final ctrl = c.read(deviceControllerProvider.notifier);
    await ctrl.refresh();
    final r = await ctrl.toggle();
    expect(r.ok, isFalse);
    expect(fake.setCalls, 0);

    fake.offline = false;
    final r2 = await ctrl.toggle();
    expect(r2.ok, isTrue);
    expect(fake.setCalls, 0); // refreshed only, no command sent
    expect(c.read(deviceControllerProvider).connection, ConnectionStatus.online);
  });

  test('connection recovery is logged', () async {
    final (c, fake) = await setup();
    final ctrl = c.read(deviceControllerProvider.notifier);
    fake.offline = true;
    await ctrl.refresh();
    fake.offline = false;
    await ctrl.refresh();
    final t = types(c);
    expect(t.where((e) => e == HistoryType.connectionEstablished).length, 2);
  });
}
