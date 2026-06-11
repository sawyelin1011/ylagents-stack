import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/sync_device.dart';

void main() {
  group('SyncDevice', () {
    test('constructor defaults', () {
      final device = SyncDevice(
        id: 'dev1',
        name: 'My Laptop',
        platform: 'macos',
      );
      expect(device.id, 'dev1');
      expect(device.name, 'My Laptop');
      expect(device.platform, 'macos');
      expect(device.isCurrentDevice, false);
      expect(device.authToken, '');
      expect(device.lastSyncAt, isNotNull);
      expect(device.registeredAt, isNotNull);
    });

    test('constructor with all fields', () {
      final now = DateTime(2026, 6, 11);
      final device = SyncDevice(
        id: 'dev1',
        name: 'My Laptop',
        platform: 'macos',
        isCurrentDevice: true,
        authToken: 'jwt_token_123',
        lastSyncAt: now,
        registeredAt: now,
      );
      expect(device.isCurrentDevice, true);
      expect(device.authToken, 'jwt_token_123');
      expect(device.lastSyncAt, now);
      expect(device.registeredAt, now);
    });

    test('copyWith preserves unchanged fields', () {
      final device = SyncDevice(
        id: 'dev1',
        name: 'My Laptop',
        platform: 'macos',
      );
      final copy = device.copyWith(name: 'New Name');
      expect(copy.id, 'dev1');
      expect(copy.name, 'New Name');
      expect(copy.platform, 'macos');
    });

    test('toJson/fromJson round-trip with all fields', () {
      final now = DateTime(2026, 6, 11, 10, 30);
      final device = SyncDevice(
        id: 'dev1',
        name: 'My Laptop',
        platform: 'macos',
        isCurrentDevice: true,
        authToken: 'token_abc',
        lastSyncAt: now,
        registeredAt: now,
      );
      final json = device.toJson();
      final restored = SyncDevice.fromJson(json);
      expect(restored.id, device.id);
      expect(restored.name, device.name);
      expect(restored.platform, device.platform);
      expect(restored.isCurrentDevice, device.isCurrentDevice);
      expect(restored.authToken, device.authToken);
      expect(
        restored.lastSyncAt.millisecondsSinceEpoch,
        device.lastSyncAt.millisecondsSinceEpoch,
      );
      expect(
        restored.registeredAt.millisecondsSinceEpoch,
        device.registeredAt.millisecondsSinceEpoch,
      );
    });

    test('toJson omits empty authToken', () {
      final device = SyncDevice(
        id: 'dev1',
        name: 'Test',
        platform: 'windows',
      );
      final json = device.toJson();
      expect(json.containsKey('authToken'), false);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{'id': 'dev1'};
      final device = SyncDevice.fromJson(json);
      expect(device.id, 'dev1');
      expect(device.name, 'Unknown Device');
      expect(device.platform, 'unknown');
      expect(device.isCurrentDevice, false);
      expect(device.authToken, '');
    });

    test('encodeList/decodeList round-trip', () {
      final devices = [
        SyncDevice(id: 'dev1', name: 'A', platform: 'macos'),
        SyncDevice(id: 'dev2', name: 'B', platform: 'windows'),
      ];
      final encoded = SyncDevice.encodeList(devices);
      final decoded = SyncDevice.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'dev1');
      expect(decoded[1].id, 'dev2');
    });

    test('decodeList handles invalid JSON', () {
      final decoded = SyncDevice.decodeList('not json');
      expect(decoded, isEmpty);
    });
  });
}