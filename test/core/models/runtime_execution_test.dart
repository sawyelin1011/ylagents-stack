import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/runtime_execution.dart';

void main() {
  group('RuntimeExecutionStatus', () {
    test('values are correct', () {
      expect(RuntimeExecutionStatus.values, [
        RuntimeExecutionStatus.pending,
        RuntimeExecutionStatus.running,
        RuntimeExecutionStatus.completed,
        RuntimeExecutionStatus.failed,
        RuntimeExecutionStatus.cancelled,
      ]);
    });

    test('fromJson returns correct enum', () {
      expect(
        RuntimeExecutionStatus.fromJson('pending'),
        RuntimeExecutionStatus.pending,
      );
      expect(
        RuntimeExecutionStatus.fromJson('running'),
        RuntimeExecutionStatus.running,
      );
      expect(
        RuntimeExecutionStatus.fromJson('completed'),
        RuntimeExecutionStatus.completed,
      );
      expect(
        RuntimeExecutionStatus.fromJson('failed'),
        RuntimeExecutionStatus.failed,
      );
      expect(
        RuntimeExecutionStatus.fromJson('cancelled'),
        RuntimeExecutionStatus.cancelled,
      );
    });

    test('fromJson returns pending for unknown', () {
      expect(
        RuntimeExecutionStatus.fromJson('unknown'),
        RuntimeExecutionStatus.pending,
      );
    });

    test('toJson/fromJson round-trip', () {
      for (final status in RuntimeExecutionStatus.values) {
        expect(RuntimeExecutionStatus.fromJson(status.toJson()), status);
      }
    });
  });

  group('RuntimeExecution', () {
    test('constructor defaults', () {
      final now = DateTime(2026, 6, 11);
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'agent1',
        agentName: 'Worker A',
        workspaceId: 'ws1',
        startedAt: now,
      );
      expect(exec.id, 'exec1');
      expect(exec.agentId, 'agent1');
      expect(exec.agentName, 'Worker A');
      expect(exec.workspaceId, 'ws1');
      expect(exec.status, RuntimeExecutionStatus.pending);
      expect(exec.taskId, '');
      expect(exec.resultSummary, '');
      expect(exec.errorMessage, '');
      expect(exec.completedAt, null);
    });

    test('constructor with all fields', () {
      final now = DateTime(2026, 6, 11);
      final later = now.add(const Duration(minutes: 5));
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'agent1',
        agentName: 'Worker A',
        workspaceId: 'ws1',
        taskId: 'task1',
        taskTitle: 'Test task',
        status: RuntimeExecutionStatus.completed,
        resultSummary: 'All good',
        errorMessage: '',
        startedAt: now,
        completedAt: later,
      );
      expect(exec.status, RuntimeExecutionStatus.completed);
      expect(exec.taskId, 'task1');
      expect(exec.taskTitle, 'Test task');
      expect(exec.resultSummary, 'All good');
      expect(exec.duration, const Duration(minutes: 5));
    });

    test('duration is null when not completed', () {
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'agent1',
        agentName: 'A',
        workspaceId: 'ws1',
        startedAt: DateTime.now(),
      );
      expect(exec.duration, isNull);
    });

    test('copyWith preserves and overrides', () {
      final now = DateTime(2026, 6, 11);
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'agent1',
        agentName: 'A',
        workspaceId: 'ws1',
        startedAt: now,
      );
      final copy = exec.copyWith(
        status: RuntimeExecutionStatus.completed,
        resultSummary: 'Done',
      );
      expect(copy.id, 'exec1');
      expect(copy.status, RuntimeExecutionStatus.completed);
      expect(copy.resultSummary, 'Done');
      expect(copy.agentName, 'A');
    });

    test('copyWith clearResult clears summary', () {
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
        startedAt: DateTime.now(),
        resultSummary: 'some result',
      );
      expect(exec.copyWith(clearResult: true).resultSummary, '');
    });

    test('copyWith clearError clears error', () {
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
        startedAt: DateTime.now(),
        errorMessage: 'some error',
      );
      expect(exec.copyWith(clearError: true).errorMessage, '');
    });

    test('toJson/fromJson round-trip with all fields', () {
      final now = DateTime(2026, 6, 11, 10, 30);
      final later = now.add(const Duration(minutes: 10));
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'agent1',
        agentName: 'Worker',
        workspaceId: 'ws1',
        taskId: 'task1',
        taskTitle: 'My Task',
        status: RuntimeExecutionStatus.completed,
        resultSummary: 'Success',
        errorMessage: '',
        startedAt: now,
        completedAt: later,
      );
      final json = exec.toJson();
      final restored = RuntimeExecution.fromJson(json);
      expect(restored.id, exec.id);
      expect(restored.agentId, exec.agentId);
      expect(restored.agentName, exec.agentName);
      expect(restored.workspaceId, exec.workspaceId);
      expect(restored.taskId, exec.taskId);
      expect(restored.taskTitle, exec.taskTitle);
      expect(restored.status, exec.status);
      expect(restored.resultSummary, exec.resultSummary);
      expect(
        restored.completedAt!.millisecondsSinceEpoch,
        exec.completedAt!.millisecondsSinceEpoch,
      );
    });

    test('toJson omits empty resultSummary and errorMessage', () {
      final exec = RuntimeExecution(
        id: 'exec1',
        agentId: 'a1',
        agentName: 'A',
        workspaceId: 'ws1',
        startedAt: DateTime.now(),
      );
      final json = exec.toJson();
      expect(json.containsKey('resultSummary'), false);
      expect(json.containsKey('errorMessage'), false);
    });

    test('fromJson handles minimal JSON', () {
      final json = <String, dynamic>{
        'id': 'exec1',
        'agentId': 'agent1',
        'agentName': 'A',
        'workspaceId': 'ws1',
        'startedAt': 1718000000000,
      };
      final exec = RuntimeExecution.fromJson(json);
      expect(exec.id, 'exec1');
      expect(exec.status, RuntimeExecutionStatus.pending);
      expect(exec.resultSummary, '');
    });

    test('encodeList/decodeList round-trip', () {
      final now = DateTime(2026, 6, 11);
      final list = [
        RuntimeExecution(
          id: 'e1',
          agentId: 'a1',
          agentName: 'A',
          workspaceId: 'ws1',
          startedAt: now,
        ),
        RuntimeExecution(
          id: 'e2',
          agentId: 'a2',
          agentName: 'B',
          workspaceId: 'ws1',
          startedAt: now,
        ),
      ];
      final encoded = RuntimeExecution.encodeList(list);
      final decoded = RuntimeExecution.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'e1');
      expect(decoded[1].id, 'e2');
    });

    test('decodeList handles invalid JSON', () {
      expect(RuntimeExecution.decodeList('not json'), isEmpty);
    });
  });
}
