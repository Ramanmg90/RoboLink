import '../../core/widgets/power_button.dart';
import '../../data/models/connection_status.dart';
import '../../data/models/device_config.dart';
import '../../data/models/relay_state.dart';

class DeviceState {
  const DeviceState({
    this.config,
    this.connection = ConnectionStatus.unknown,
    this.relay = RelayState.unknown,
    this.commandPending = false,
    this.pendingTarget,
    this.errorMessage,
    this.connectionError,
    this.lastSuccessAt,
    this.firmwareVersion,
    this.deviceId,
  });

  final DeviceConfig? config;
  final ConnectionStatus connection;
  final RelayState relay;
  final bool commandPending;
  final RelayState? pendingTarget;

  /// Set when the last command failed.
  final String? errorMessage;

  /// Set when the device could not be reached at the last check.
  final String? connectionError;
  final DateTime? lastSuccessAt;
  final String? firmwareVersion;
  final String? deviceId;

  bool get hasDevice => config != null;
  bool get isDemo => config?.isDemo ?? false;

  PowerVisual get visual {
    if (commandPending) return PowerVisual.pending;
    if (errorMessage != null) return PowerVisual.error;
    switch (relay) {
      case RelayState.on:
        return PowerVisual.on;
      case RelayState.off:
        return PowerVisual.off;
      case RelayState.unknown:
        return PowerVisual.unknown;
    }
  }

  DeviceState copyWith({
    ConnectionStatus? connection,
    RelayState? relay,
    bool? commandPending,
    RelayState? pendingTarget,
    bool clearPending = false,
    String? errorMessage,
    bool clearError = false,
    String? connectionError,
    bool clearConnectionError = false,
    DateTime? lastSuccessAt,
    String? firmwareVersion,
    String? deviceId,
  }) {
    return DeviceState(
      config: config,
      connection: connection ?? this.connection,
      relay: relay ?? this.relay,
      commandPending: commandPending ?? this.commandPending,
      pendingTarget: clearPending ? null : (pendingTarget ?? this.pendingTarget),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      connectionError: clearConnectionError
          ? null
          : (connectionError ?? this.connectionError),
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

class CommandOutcome {
  const CommandOutcome(this.ok, this.message, {this.ignored = false});
  final bool ok;
  final String message;

  /// True when nothing was sent (duplicate tap while pending, no device, ...).
  final bool ignored;

  static const noop = CommandOutcome(false, '', ignored: true);
}
