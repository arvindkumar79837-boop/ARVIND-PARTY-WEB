import 'package:flutter_test/flutter_test.dart';
import 'package:arvind_party_web/core/constants/env_config.dart';

void main() {
  test('EnvConfig should have apiBaseUrl with server IP', () {
    expect(EnvConfig.apiBaseUrl, contains('5000'));
  });

  test('EnvConfig should have socketUrl with server IP', () {
    expect(EnvConfig.socketUrl, contains('5000'));
  });

  test('EnvConfig should have default appName', () {
    expect(EnvConfig.appName, 'Arvind Party Admin');
  });

  test('EnvConfig should have default appVersion', () {
    expect(EnvConfig.appVersion, '1.0.0');
  });

  test('EnvConfig should have default pageSize', () {
    expect(EnvConfig.pageSize, 20);
  });

  test('EnvConfig should have default requestTimeout', () {
    expect(EnvConfig.requestTimeoutSeconds, 30);
  });

  group('firebaseConfig', () {
    test('should have all required keys', () {
      expect(EnvConfig.firebaseConfig.containsKey('apiKey'), true);
      expect(EnvConfig.firebaseConfig.containsKey('authDomain'), true);
      expect(EnvConfig.firebaseConfig.containsKey('projectId'), true);
      expect(EnvConfig.firebaseConfig.containsKey('storageBucket'), true);
      expect(EnvConfig.firebaseConfig.containsKey('messagingSenderId'), true);
      expect(EnvConfig.firebaseConfig.containsKey('appId'), true);
      expect(EnvConfig.firebaseConfig.containsKey('measurementId'), true);
    });

    test('should have non-empty apiKey', () {
      expect(EnvConfig.firebaseConfig['apiKey'].toString().isNotEmpty, true);
    });
  });

  test('EnvConfig should have liveKitUrl with default', () {
    expect(EnvConfig.liveKitUrl, isNotEmpty);
  });

  test('EnvConfig should have razorpayKeyId', () {
    expect(EnvConfig.razorpayKeyId, isNotEmpty);
  });
}
