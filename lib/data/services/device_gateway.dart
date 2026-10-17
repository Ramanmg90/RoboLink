import '../models/device_status.dart';
import '../models/relay_state.dart';

/// Abstraction over the communication with one device. Implementations throw
/// [AppException] subclasses; they never return unvalidated data.
abstract class DeviceGateway {
  /// Reads and validates the device status.
  Future<DeviceStatus> fetchStatus();

  /// Sends a relay command and returns the relay state reported by the
  /// device in its response. [target] must be ON or OFF.
  Future<RelayState> setRelay(RelayState target);

  void dispose();
}
