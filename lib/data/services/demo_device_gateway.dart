import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../models/device_status.dart';
import '../models/relay_state.dart';
import 'device_gateway.dart';

/// Simulated device state shared by the demo gateway and the demo panel.
class DemoSimulator extends ChangeNotifier {
  RelayState _relay = RelayState.off;
  bool _offline = false;
  bool _failNext = false;

  /// Artificial latency so loading states are visible.
  Duration latency = const Duration(milliseconds: 700);

  RelayState get relay => _relay;
  bool get offline => _offline;
  bool get failNext => _failNext;

  void setRelay(RelayState value) {
    _relay = value;
    notifyListeners();
  }

  void setOffline(bool value) {
    _offline = value;
    notifyListeners();
  }

  void setFailNext(bool value) {
    _failNext = value;
    notifyListeners();
  }
}

/// Never touches the network.
class DemoDeviceGateway implements DeviceGateway {
  DemoDeviceGateway(this._sim);
  final DemoSimulator _sim;

  @override
  Future<DeviceStatus> fetchStatus() async {
    await Future<void>.delayed(_sim.latency);
    if (_sim.offline) throw const DeviceTimeoutException();
    return DeviceStatus(
      deviceId: 'demo-001',
      online: true,
      relay: _sim.relay,
      firmwareVersion: 'demo',
    );
  }

  @override
  Future<RelayState> setRelay(RelayState target) async {
    await Future<void>.delayed(_sim.latency);
    if (_sim.offline) throw const DeviceTimeoutException();
    if (_sim.failNext) {
      _sim.setFailNext(false);
      throw const DeviceRejectedException('خطای شبیه‌سازی‌شده: دستگاه فرمان را نپذیرفت.');
    }
    _sim.setRelay(target);
    return target;
  }

  @override
  void dispose() {}
}
