import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';
import '../models/device_config.dart';
import '../models/device_status.dart';
import '../models/relay_state.dart';
import 'device_gateway.dart';

/// Talks to the ESP8266 firmware over local HTTP:
///   GET  {statusPath}  -> {"deviceId","online","relay","firmwareVersion"}
///   POST {relayPath}   <- {"state":"ON"|"OFF"}  -> {"success":true,"relay":"ON"}
class HttpDeviceGateway implements DeviceGateway {
  HttpDeviceGateway({
    required this.config,
    required this.timeout,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final DeviceConfig config;
  final Duration timeout;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (config.token.isNotEmpty) 'Authorization': 'Bearer ${config.token}',
      };

  @override
  Future<DeviceStatus> fetchStatus() async {
    final res = await _send(
      () => _client.get(config.uri(config.statusPath), headers: _headers),
    );
    return DeviceStatus.fromJson(_decodeObject(res));
  }

  @override
  Future<RelayState> setRelay(RelayState target) async {
    final body = jsonEncode({'state': target.apiValue});
    final res = await _send(
      () => _client.post(
        config.uri(config.relayPath),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: body,
      ),
    );
    final json = _decodeObject(res);
    if (json['success'] != true) {
      final err = json['error'];
      throw DeviceRejectedException(
        err is String && err.isNotEmpty
            ? 'دستگاه فرمان را رد کرد: $err'
            : 'دستگاه فرمان را نپذیرفت.',
      );
    }
    final relay = RelayState.tryParse(json['relay']);
    if (relay == null) throw const MalformedResponseException();
    return relay;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call().timeout(timeout);
    } on TimeoutException {
      throw const DeviceTimeoutException();
    } on SocketException {
      throw const DeviceUnreachableException();
    } on http.ClientException {
      throw const DeviceUnreachableException();
    } on FormatException {
      throw const DeviceUnreachableException('آدرس دستگاه نامعتبر است.');
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw const UnauthorizedException();
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw DeviceRejectedException('دستگاه با کد ${res.statusCode} پاسخ داد.');
    }
    return res;
  }

  Map<String, dynamic> _decodeObject(http.Response res) {
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // fall through
    }
    throw const MalformedResponseException();
  }

  @override
  void dispose() => _client.close();
}
