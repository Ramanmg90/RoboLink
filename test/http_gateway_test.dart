import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:robolink/core/errors/app_exception.dart';
import 'package:robolink/data/models/device_config.dart';
import 'package:robolink/data/models/relay_state.dart';
import 'package:robolink/data/services/http_device_gateway.dart';

HttpDeviceGateway gateway(MockClient client,
        {Duration timeout = const Duration(seconds: 1), String token = ''}) =>
    HttpDeviceGateway(
      config: DeviceConfig(
          id: '1', name: 'x', host: '192.168.1.50', token: token),
      timeout: timeout,
      client: client,
    );

http.Response json(Object body, [int code = 200]) => http.Response(
      jsonEncode(body),
      code,
      headers: {'content-type': 'application/json'},
    );

void main() {
  test('fetchStatus parses a valid response and sends the token', () async {
    late http.Request seen;
    final gw = gateway(
      MockClient((req) async {
        seen = req;
        return json({
          'deviceId': 'robolink-001',
          'online': true,
          'relay': 'ON',
          'firmwareVersion': '1.0.0',
        });
      }),
      token: 'secret',
    );
    final s = await gw.fetchStatus();
    expect(s.relay, RelayState.on);
    expect(seen.method, 'GET');
    expect(seen.url.path, '/api/status');
    expect(seen.headers['Authorization'], 'Bearer secret');
  });

  test('setRelay posts {"state":"ON"} and returns the reported state', () async {
    late http.Request seen;
    final gw = gateway(MockClient((req) async {
      seen = req;
      return json({'success': true, 'relay': 'ON'});
    }));
    final r = await gw.setRelay(RelayState.on);
    expect(r, RelayState.on);
    expect(seen.method, 'POST');
    expect(jsonDecode(seen.body), {'state': 'ON'});
  });

  test('malformed JSON -> MalformedResponseException', () async {
    final gw = gateway(MockClient((_) async => http.Response('<html>', 200)));
    expect(gw.fetchStatus(), throwsA(isA<MalformedResponseException>()));
  });

  test('wrong structure -> MalformedResponseException', () async {
    final gw = gateway(MockClient((_) async => json({'relay': 'ON'})));
    expect(gw.fetchStatus(), throwsA(isA<MalformedResponseException>()));
  });

  test('401 -> UnauthorizedException', () async {
    final gw = gateway(MockClient((_) async => json({'success': false}, 401)));
    expect(gw.fetchStatus(), throwsA(isA<UnauthorizedException>()));
  });

  test('500 -> DeviceRejectedException', () async {
    final gw = gateway(MockClient((_) async => http.Response('', 500)));
    expect(gw.fetchStatus(), throwsA(isA<DeviceRejectedException>()));
  });

  test('success:false -> DeviceRejectedException', () async {
    final gw = gateway(MockClient(
        (_) async => json({'success': false, 'error': 'bad'})));
    expect(gw.setRelay(RelayState.off), throwsA(isA<DeviceRejectedException>()));
  });

  test('success without valid relay -> MalformedResponseException', () async {
    final gw = gateway(
        MockClient((_) async => json({'success': true, 'relay': 'X'})));
    expect(gw.setRelay(RelayState.on), throwsA(isA<MalformedResponseException>()));
  });

  test('socket error -> DeviceUnreachableException', () async {
    final gw = gateway(
        MockClient((_) async => throw const SocketException('no route')));
    expect(gw.fetchStatus(), throwsA(isA<DeviceUnreachableException>()));
  });

  test('slow device -> DeviceTimeoutException', () async {
    final gw = gateway(
      MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return json({});
      }),
      timeout: const Duration(milliseconds: 50),
    );
    expect(gw.fetchStatus(), throwsA(isA<DeviceTimeoutException>()));
  });
}
