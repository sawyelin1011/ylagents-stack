import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/sync_record.dart';

void main() {
  group('SyncStatus', () {
    test('values are correct', () {
      expect(SyncStatus.values, [
        SyncStatus.idle,
        SyncStatus.syncing,
        SyncStatus.success,
        SyncStatus.failed,
        SyncStatus.paused,
      ]);
    });

    test('fromJson returns correct enum', () {
      expect(SyncStatus.fromJson('idle'), SyncStatus.idle);
      expect(SyncStatus.fromJson('syncing'), SyncStatus.syncing);
      expect(SyncStatus.fromJson('success'), SyncStatus.success);
      expect(SyncStatus.fromJson('failed'), SyncStatus.failed);
      expect(SyncStatus.fromJson('paused'), SyncStatus.paused);
    });

    test('fromJson returns idle for unknown', () {
      expect(SyncStatus.fromJson('unknown'), SyncStatus.idle);
    });

    test('toJson/fromJson round-trip', () {
      for (final status in SyncStatus.values) {
        expect(SyncStatus.fromJson(status.toJson()), status);
      }
    });
  });

  group('SyncRecord', () {
    test('constructor defaults', () {
      final record = SyncRecord(id: 'rec1', deviceId: 'dev1');
      expect(record.id, 'rec1');
      expect(record.deviceId, 'dev1');
      expect(record.workspaceId, '');
      expect(record.status, SyncStatus.idle);
      expect(record.itemsPushed, 0);
      expect(record.itemsPulled, 0);
      expect(record.conflictsResolved, 0);
      expect(record.errorMessage, '');
      expect(record.startedAt, isNotNull);
      expect(record.completedAt, isNotNull);
    });

    test('constructor with all fields', () {
      final now = DateTime(2026, 6, 11);
      final record = SyncRecord(
        id: 'rec1',
        deviceId: 'dev1',
        workspaceId: 'ws1',
        status: SyncStatus.success,
        itemsPushed: 10,
        itemsPulled: 5,
        conflictsResolved: 2,
        errorMessage: '',
        startedAt: now,
        completedAt: now,
      );
      expect(record.status, SyncStatus.success);
      expect(record.itemsPushed, 10);
      expect(record.itemsPulled, 5);
      expect(record.conflictsResolved, 2);
      expect(record.duration, Duration.zero);
    });

    test('copyWith preserves and overrides', () {
      final record = SyncRecord(id: 'rec1', deviceId: 'dev1');
      final copy = record.copyWith(
        status: SyncStatus.success,
        itemsPushed: 5,
      );
      expect(copy.id, 'rec1');
      expect(copy.deviceId, 'dev1');
      expect(copy.status, SyncStatus.success);
      expect(copy.itemsPushed, 5);
      expect(copy.itemsPulled, 0);
    });

    test('copyWith clearError clears message', () {
      final record = SyncRecord(
        id: 'rec1',
        deviceId: 'dev1',
        errorMessage: 'some error',
      );
      final cleared = record.copyWith(clearError: true);
      expect(cleared.errorMessage, '');
    });

    test('toJson/fromJson round-trip with all fields', () {
      final now = DateTime(2026, 6, 11, 10, 30, 0);
      final record = SyncRecord(
        id: 'rec1',
        deviceId: 'dev1',
        workspaceId: 'ws1',
        status: SyncStatus.success,
        itemsPushed: 10,
        itemsPulled: 5,
        conflictsResolved: 2,
        errorMessage: '',
        startedAt: now,
        completedAt: now,
      );
      final json = record.toJson();
      final restored = SyncRecord.fromJson(json);
      expect(restored.id, record.id);
      expect(restored.deviceId, record.deviceId);
      expect(restored.workspaceId, record.workspaceId);
      expect(restored.status, record.status);
      expect(restored.itemsPushed, record.itemsPushed);
      expect(restored.itemsPulled, record.itemsPulled);
      expect(restored.conflictsResolved, record.conflictsResolved);
      expect(
        restored.startedAt.millisecondsSinceEpoch,
        record.startedAt.millisecondsSinceEpoch,
      );
      expect(
        restored.completedAt.millisecondsSinceEpoch,
        record.completedAt.millisecondsSinceEpoch,
      );
    });

    test('toJson omits empty errorMessage', () {
      final record = SyncRecord(id: 'rec1', deviceId: 'dev1');
      final json = record.toJson();
      expect(json.containsKey('errorMessage'), false);
    });

    test('toJson includes errorMessage when non-empty', () {
      final record = SyncRecord(
        id: 'rec1',
        deviceId: 'dev1',
        errorMessage: 'connection failed',
      );
      final json = record.toJson();
      expect(json['errorMessage'], 'connection failed');
    });

    test('fromJson handles minimal JSON', () {
      final json = <String, dynamic>{
        'id': 'rec1',
        'deviceId': 'dev1',
      };
      final record = SyncRecord.fromJson(json);
      expect(record.id, 'rec1');
      expect(record.status, SyncStatus.idle);
      expect(record.itemsPushed, 0);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{'id': 'rec1'};
      final record = SyncRecord.fromJson(json);
      expect(record.id, 'rec1');
      expect(record.deviceId, '');
      expect(record.status, SyncStatus.idle);
    });

    test('encodeList/decodeList round-trip', () {
      final records = [
        SyncRecord(id: 'rec1', deviceId: 'dev1'),
        SyncRecord(id: 'rec2', deviceId: 'dev2'),
      ];
      final encoded = SyncRecord.encodeList(records);
      final decoded = SyncRecord.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'rec1');
      expect(decoded[1].id, 'rec2');
    });

    test('decodeList handles invalid JSON', () {
      expect(SyncRecord.decodeList('not json'), isEmpty);
    });

    test('duration is positive', () {
      final record = SyncRecord(
        id: 'rec1',
        deviceId: 'dev1',
        startedAt: DateTime(2026, 6, 11, 10, 0, 0),
        completedAt: DateTime(2026, 6, 11, 10, 5, 30),
      );
      expect(record.duration.inSeconds, 330);
    });
  });
}