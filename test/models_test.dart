import 'package:flutter_test/flutter_test.dart';
import 'package:robolink/core/errors/app_exception.dart';
import 'package:robolink/core/utils/jalali.dart';
import 'package:robolink/data/models/device_config.dart';
import 'package:robolink/data/models/device_status.dart';
import 'package:robolink/data/models/relay_state.dart';

void main() {
  group('RelayState', () {
    test('parses ON/OFF case-insensitively', () {
      expect(RelayState.tryParse('ON'), RelayState.on);
      expect(RelayState.tryParse(' off '), RelayState.off);
    });

    test('rejects anything else', () {
      expect(RelayState.tryParse('UNKNOWN'), isNull);
      expect(RelayState.tryParse(1), isNull);
      expect(RelayState.tryParse(null), isNull);
    });

    test('UNKNOWN can never be sent as a command', () {
      expect(() => RelayState.unknown.apiValue, throwsStateError);
    });
  });

  group('DeviceStatus.fromJson', () {
    final valid = {
      'deviceId': 'robolink-001',
      'online': true,
      'relay': 'OFF',
      'firmwareVersion': '1.0.0',
    };

    test('accepts the documented response', () {
      final s = DeviceStatus.fromJson(valid);
      expect(s.deviceId, 'robolink-001');
      expect(s.relay, RelayState.off);
      expect(s.firmwareVersion, '1.0.0');
    });

    test('rejects missing or invalid fields', () {
      expect(() => DeviceStatus.fromJson({...valid, 'relay': 'MAYBE'}),
          throwsA(isA<MalformedResponseException>()));
      expect(() => DeviceStatus.fromJson({...valid, 'online': 'yes'}),
          throwsA(isA<MalformedResponseException>()));
      expect(() => DeviceStatus.fromJson({...valid}..remove('deviceId')),
          throwsA(isA<MalformedResponseException>()));
    });
  });

  group('DeviceConfig', () {
    test('builds URIs from bare IP and default port', () {
      const c = DeviceConfig(id: '1', name: 'x', host: '192.168.1.50');
      expect(c.uri('/api/status').toString(), 'http://192.168.1.50:80/api/status');
    });

    test('explicit port in host wins', () {
      const c = DeviceConfig(id: '1', name: 'x', host: 'http://10.0.0.2:8080');
      expect(c.uri('api/relay').toString(), 'http://10.0.0.2:8080/api/relay');
    });

    test('validates host and port', () {
      expect(DeviceConfig.validateHost(''), isNotNull);
      expect(DeviceConfig.validateHost('192.168 1.5'), isNotNull);
      expect(DeviceConfig.validateHost('ftp://x'), isNotNull);
      expect(DeviceConfig.validateHost('robolink.local'), isNull);
      expect(DeviceConfig.validatePort('0'), isNotNull);
      expect(DeviceConfig.validatePort('80'), isNull);
    });

    test('json round trip', () {
      const c = DeviceConfig(
          id: '1', name: 'چراغ', host: '1.2.3.4', port: 81, token: 't');
      expect(DeviceConfig.fromJson(c.toJson()), c);
    });
  });

  test('Jalali conversion: 2024-03-20 is 1403/01/01', () {
    expect(gregorianToJalali(2024, 3, 20), [1403, 1, 1]);
  });
}
