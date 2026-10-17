import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_config.dart';
import 'demo_device_gateway.dart';
import 'device_gateway.dart';
import 'http_device_gateway.dart';

typedef GatewayFactory = DeviceGateway Function(
    DeviceConfig config, Duration timeout);

final demoSimulatorProvider = Provider<DemoSimulator>((ref) {
  final sim = DemoSimulator();
  ref.onDispose(sim.dispose);
  return sim;
});

/// Chooses the demo gateway for demo devices (no network at all) and the HTTP
/// gateway for real devices. Tests override this provider.
final gatewayFactoryProvider = Provider<GatewayFactory>((ref) {
  final sim = ref.watch(demoSimulatorProvider);
  return (config, timeout) => config.isDemo
      ? DemoDeviceGateway(sim)
      : HttpDeviceGateway(config: config, timeout: timeout);
});
