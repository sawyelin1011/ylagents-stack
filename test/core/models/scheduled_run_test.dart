import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/services/scheduler_service.dart';

void main() {
  group('ScheduleInterval', () {
    test('values are correct', () {
      expect(ScheduleInterval.values, [
        ScheduleInterval.once,
        ScheduleInterval.hourly,
        ScheduleInterval.daily,
        ScheduleInterval.weekly,
        ScheduleInterval.monthly,
      ]);
    });

    test('fromJson returns correct enum', () {
      expect(ScheduleInterval.fromJson('once'), ScheduleInterval.once);
      expect(ScheduleInterval.fromJson('hourly'), ScheduleInterval.hourly);
      expect(ScheduleInterval.fromJson('daily'), ScheduleInterval.daily);
      expect(ScheduleInterval.fromJson('weekly'), ScheduleInterval.weekly);
      expect(ScheduleInterval.fromJson('monthly'), ScheduleInterval.monthly);
    });

    test('fromJson returns once for unknown', () {
      expect(ScheduleInterval.fromJson('unknown'), ScheduleInterval.once);
    });

    test('toJson/fromJson round-trip', () {
      for (final interval in ScheduleInterval.values) {
        expect(ScheduleInterval.fromJson(interval.toJson()), interval);
      }
    });

    test('duration returns correct values', () {
      expect(ScheduleInterval.once.duration, Duration.zero);
      expect(ScheduleInterval.hourly.duration, const Duration(hours: 1));
      expect(ScheduleInterval.daily.duration, const Duration(days: 1));
      expect(ScheduleInterval.weekly.duration, const Duration(days: 7));
      expect(ScheduleInterval.monthly.duration, const Duration(days: 30));
    });
  });

  group('ScheduledRun', () {
    test('constructor defaults', () {
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'agent1',
        agentName: 'Lead Agent',
        workspaceId: 'ws1',
      );
      expect(run.id, 'sched1');
      expect(run.agentId, 'agent1');
      expect(run.agentName, 'Lead Agent');
      expect(run.workspaceId, 'ws1');
      expect(run.interval, ScheduleInterval.daily);
      expect(run.enabled, true);
      expect(run.taskTitle, '');
      expect(run.lastRunAt, null);
      expect(run.nextRunAt, null);
    });

    test('constructor with all fields', () {
      final now = DateTime(2026, 6, 11);
      final later = now.add(const Duration(hours: 1));
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'agent1',
        agentName: 'A',
        workspaceId: 'ws1',
        taskTitle: 'Daily check',
        interval: ScheduleInterval.hourly,
        enabled: false,
        createdAt: now,
        updatedAt: now,
        lastRunAt: now,
        nextRunAt: later,
      );
      expect(run.taskTitle, 'Daily check');
      expect(run.interval, ScheduleInterval.hourly);
      expect(run.enabled, false);
      expect(run.lastRunAt, now);
      expect(run.nextRunAt, later);
    });

    test('copyWith preserves and overrides', () {
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
      );
      final copy = run.copyWith(
        interval: ScheduleInterval.hourly,
        enabled: false,
      );
      expect(copy.id, 'sched1');
      expect(copy.interval, ScheduleInterval.hourly);
      expect(copy.enabled, false);
      expect(copy.agentName, 'A');
    });

    test('copyWith clearLastRun clears lastRunAt', () {
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
        lastRunAt: DateTime(2026, 6, 11),
      );
      expect(run.copyWith(clearLastRun: true).lastRunAt, isNull);
    });

    test('copyWith clearNextRun clears nextRunAt', () {
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
        nextRunAt: DateTime(2026, 6, 12),
      );
      expect(run.copyWith(clearNextRun: true).nextRunAt, isNull);
    });

    test('toJson/fromJson round-trip with all fields', () {
      final now = DateTime(2026, 6, 11);
      final later = now.add(const Duration(hours: 2));
      final run = ScheduledRun(
        id: 'sched1',
        agentId: 'agent1',
        agentName: 'Worker',
        workspaceId: 'ws1',
        taskTitle: 'Nightly',
        interval: ScheduleInterval.daily,
        enabled: true,
        createdAt: now,
        updatedAt: now,
        lastRunAt: now,
        nextRunAt: later,
      );
      final json = run.toJson();
      final restored = ScheduledRun.fromJson(json);
      expect(restored.id, run.id);
      expect(restored.agentId, run.agentId);
      expect(restored.agentName, run.agentName);
      expect(restored.workspaceId, run.workspaceId);
      expect(restored.taskTitle, run.taskTitle);
      expect(restored.interval, run.interval);
      expect(restored.enabled, run.enabled);
      expect(
        restored.lastRunAt!.millisecondsSinceEpoch,
        run.lastRunAt!.millisecondsSinceEpoch,
      );
      expect(
        restored.nextRunAt!.millisecondsSinceEpoch,
        run.nextRunAt!.millisecondsSinceEpoch,
      );
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{
        'id': 'sched1',
        'agentId': 'a1',
        'agentName': 'A',
        'workspaceId': 'ws1',
      };
      final run = ScheduledRun.fromJson(json);
      expect(run.id, 'sched1');
      expect(run.interval, ScheduleInterval.daily);
      expect(run.enabled, true);
      expect(run.lastRunAt, null);
      expect(run.nextRunAt, null);
    });

    test('encodeList/decodeList round-trip', () {
      final list = [
        ScheduledRun(
          id: 's1',
          agentId: 'a1',
          agentName: 'A',
          workspaceId: 'ws1',
        ),
        ScheduledRun(
          id: 's2',
          agentId: 'a2',
          agentName: 'B',
          workspaceId: 'ws1',
        ),
      ];
      final encoded = ScheduledRun.encodeList(list);
      final decoded = ScheduledRun.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 's1');
      expect(decoded[1].id, 's2');
    });

    test('decodeList handles invalid JSON', () {
      expect(ScheduledRun.decodeList('not json'), isEmpty);
    });
  });
}
