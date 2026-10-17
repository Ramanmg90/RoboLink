import 'package:flutter/foundation.dart';

/// Connection settings of one device. A device with [isDemo] never touches
/// the network.
@immutable
class DeviceConfig {
  const DeviceConfig({
    required this.id,
    required this.name,
    this.host = '',
    this.port = 80,
    this.statusPath = '/api/status',
    this.relayPath = '/api/relay',
    this.token = '',
    this.isDemo = false,
  });

  static const defaultName = 'چراغ اتاق';

  factory DeviceConfig.demo() =>
      const DeviceConfig(id: 'demo', name: defaultName, isDemo: true);

  final String id;
  final String name;
  final String host;
  final int port;
  final String statusPath;
  final String relayPath;
  final String token;
  final bool isDemo;

  /// Builds an absolute URI. [host] may be an IP, a hostname, or a full
  /// `http://host:port` string; an explicit port in [host] wins over [port].
  Uri uri(String path) {
    final raw = host.trim();
    final u = Uri.parse(raw.contains('://') ? raw : 'http://$raw');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri(
      scheme: u.scheme,
      host: u.host,
      port: u.hasPort ? u.port : port,
      path: p,
    );
  }

  /// Returns a Persian error message, or null when [value] is acceptable.
  static String? validateHost(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return 'آدرس IP یا نام میزبان را وارد کنید.';
    if (raw.contains(RegExp(r'\s'))) return 'آدرس نباید فاصله داشته باشد.';
    try {
      final u = Uri.parse(raw.contains('://') ? raw : 'http://$raw');
      if (u.host.isEmpty || (u.scheme != 'http' && u.scheme != 'https')) {
        return 'آدرس واردشده معتبر نیست.';
      }
    } on FormatException {
      return 'آدرس واردشده معتبر نیست.';
    }
    return null;
  }

  static String? validatePort(String value) {
    final p = int.tryParse(value.trim());
    if (p == null || p < 1 || p > 65535) return 'پورت باید بین ۱ تا ۶۵۵۳۵ باشد.';
    return null;
  }

  DeviceConfig copyWith({
    String? name,
    String? host,
    int? port,
    String? statusPath,
    String? relayPath,
    String? token,
    bool? isDemo,
  }) {
    return DeviceConfig(
      id: id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      statusPath: statusPath ?? this.statusPath,
      relayPath: relayPath ?? this.relayPath,
      token: token ?? this.token,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'statusPath': statusPath,
        'relayPath': relayPath,
        'token': token,
        'isDemo': isDemo,
      };

  factory DeviceConfig.fromJson(Map<String, dynamic> json) => DeviceConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        host: (json['host'] as String?) ?? '',
        port: (json['port'] as int?) ?? 80,
        statusPath: (json['statusPath'] as String?) ?? '/api/status',
        relayPath: (json['relayPath'] as String?) ?? '/api/relay',
        token: (json['token'] as String?) ?? '',
        isDemo: (json['isDemo'] as bool?) ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is DeviceConfig &&
      other.id == id &&
      other.name == name &&
      other.host == host &&
      other.port == port &&
      other.statusPath == statusPath &&
      other.relayPath == relayPath &&
      other.token == token &&
      other.isDemo == isDemo;

  @override
  int get hashCode =>
      Object.hash(id, name, host, port, statusPath, relayPath, token, isDemo);
}
