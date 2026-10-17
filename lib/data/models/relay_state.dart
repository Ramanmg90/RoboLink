enum RelayState {
  on,
  off,
  unknown;

  /// Parses an API value. Returns null when the value is not exactly ON/OFF.
  static RelayState? tryParse(Object? value) {
    if (value is! String) return null;
    switch (value.trim().toUpperCase()) {
      case 'ON':
        return RelayState.on;
      case 'OFF':
        return RelayState.off;
      default:
        return null;
    }
  }

  /// Value sent to the firmware. UNKNOWN can never be sent as a command.
  String get apiValue {
    switch (this) {
      case RelayState.on:
        return 'ON';
      case RelayState.off:
        return 'OFF';
      case RelayState.unknown:
        throw StateError('UNKNOWN is not a valid relay command');
    }
  }
}
