/// Data model reserved for the scheduling feature (not implemented in
/// version 1). It is intentionally not wired to any UI or persistence yet.
class ScheduleRule {
  const ScheduleRule({
    required this.id,
    required this.deviceId,
    required this.weekdays,
    required this.hour,
    required this.minute,
    required this.turnOn,
    this.enabled = true,
  });

  final String id;
  final String deviceId;

  /// 1 = Monday ... 7 = Sunday (DateTime.weekday).
  final Set<int> weekdays;
  final int hour;
  final int minute;
  final bool turnOn;
  final bool enabled;

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'weekdays': weekdays.toList()..sort(),
        'hour': hour,
        'minute': minute,
        'turnOn': turnOn,
        'enabled': enabled,
      };
}
