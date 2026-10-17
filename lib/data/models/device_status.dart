import '../../core/errors/app_exception.dart';
import 'relay_state.dart';

/// Response of `GET /api/status`, validated.
class DeviceStatus {
  const DeviceStatus({
    required this.deviceId,
    required this.online,
    required this.relay,
    required this.firmwareVersion,
  });

  final String deviceId;
  final bool online;
  final RelayState relay;
  final String firmwareVersion;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    final id = json['deviceId'];
    final online = json['online'];
    final relay = RelayState.tryParse(json['relay']);
    final fw = json['firmwareVersion'];
    if (id is! String || id.isEmpty || online is! bool || relay == null || fw is! String) {
      throw const MalformedResponseException();
    }
    return DeviceStatus(
      deviceId: id,
      online: online,
      relay: relay,
      firmwareVersion: fw,
    );
  }
}
