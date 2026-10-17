enum HistoryType {
  commandSent,
  commandConfirmed,
  commandFailed,
  connectionEstablished,
  connectionLost,
  settingsChanged,
}

/// One app-side event. Only events the running app actually observed are
/// recorded.
class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
    this.deviceName,
  });

  final String id;
  final HistoryType type;
  final String message;
  final DateTime time;
  final String? deviceName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'message': message,
        'time': time.toIso8601String(),
        'deviceName': deviceName,
      };

  factory HistoryEvent.fromJson(Map<String, dynamic> json) => HistoryEvent(
        id: json['id'] as String,
        type: HistoryType.values.byName(json['type'] as String),
        message: json['message'] as String,
        time: DateTime.parse(json['time'] as String),
        deviceName: json['deviceName'] as String?,
      );
}
