import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/execution_trace.dart';

void main() {
  group('ExecutionStatus', () {
    test('values contain all expected statuses', () {
      expect(ExecutionStatus.values, [
        ExecutionStatus.planning,
        ExecutionStatus.delegating,
        ExecutionStatus.executing,
        ExecutionStatus.reviewing,
        ExecutionStatus.completed,
        ExecutionStatus.failed,
      ]);
    });

    test('toJson returns correct string', () {
      expect(ExecutionStatus.planning.toJson(), 'planning');
      expect(ExecutionStatus.delegating.toJson(), 'delegating');
      expect(ExecutionStatus.executing.toJson(), 'executing');
      expect(ExecutionStatus.reviewing.toJson(), 'reviewing');
      expect(ExecutionStatus.completed.toJson(), 'completed');
      expect(ExecutionStatus.failed.toJson(), 'failed');
    });

    test('fromJson parses correctly', () {
      expect(ExecutionStatus.fromJson('planning'), ExecutionStatus.planning);
      expect(ExecutionStatus.fromJson('delegating'), ExecutionStatus.delegating);
      expect(ExecutionStatus.fromJson('executing'), ExecutionStatus.executing);
      expect(ExecutionStatus.fromJson('reviewing'), ExecutionStatus.reviewing);
      expect(ExecutionStatus.fromJson('completed'), ExecutionStatus.completed);
      expect(ExecutionStatus.fromJson('failed'), ExecutionStatus.failed);
    });

    test('fromJson defaults to failed for unknown values', () {
      expect(ExecutionStatus.fromJson('unknown'), ExecutionStatus.failed);
    });
  });

  group('StepType', () {
    test('values contain all expected types', () {
      expect(StepType.values, [
        StepType.plan,
        StepType.delegate,
        StepType.execute,
        StepType.review,
      ]);
    });

    test('toJson/fromJson round-trip', () {
      for (final type in StepType.values) {
        expect(StepType.fromJson(type.toJson()), type);
      }
    });

    test('fromJson defaults to plan for unknown values', () {
      expect(StepType.fromJson('unknown'), StepType.plan);
    });
  });

  group('StepStatus', () {
    test('values contain all expected statuses', () {
      expect(StepStatus.values, [
        StepStatus.pending,
        StepStatus.inProgress,
        StepStatus.completed,
        StepStatus.failed,
      ]);
    });

    test('toJson/fromJson round-trip', () {
      for (final status in StepStatus.values) {
        expect(StepStatus.fromJson(status.toJson()), status);
      }
    });

    test('fromJson defaults to pending for unknown values', () {
      expect(StepStatus.fromJson('unknown'), StepStatus.pending);
    });
  });

  group('ExecutionStep', () {
    test('constructor sets default status to pending', () {
      final step = ExecutionStep(
        id: 'step-1',
        type: StepType.plan,
        description: 'Test step',
      );
      expect(step.status, StepStatus.pending);
      expect(step.agentId, isNull);
      expect(step.taskId, isNull);
      expect(step.result, isNull);
      expect(step.startedAt, isNull);
      expect(step.completedAt, isNull);
    });

    test('toJson omits nullable fields when null', () {
      final step = ExecutionStep(
        id: 'step-1',
        type: StepType.plan,
        status: StepStatus.completed,
        description: 'Test step',
        completedAt: DateTime(2026, 6, 11),
      );
      final json = step.toJson();
      expect(json['id'], 'step-1');
      expect(json['type'], 'plan');
      expect(json['status'], 'completed');
      expect(json['description'], 'Test step');
      expect(json.containsKey('agentId'), false);
      expect(json.containsKey('taskId'), false);
      expect(json.containsKey('result'), false);
      expect(json.containsKey('startedAt'), false);
      expect(json['completedAt'], isNotNull);
    });

    test('toJson includes non-null optional fields', () {
      final step = ExecutionStep(
        id: 'step-2',
        type: StepType.execute,
        status: StepStatus.completed,
        description: 'Write tests',
        agentId: 'agent-1',
        taskId: 'task-1',
        result: 'All tests pass',
        startedAt: DateTime(2026, 6, 11, 10, 0),
        completedAt: DateTime(2026, 6, 11, 10, 30),
      );
      final json = step.toJson();
      expect(json['agentId'], 'agent-1');
      expect(json['taskId'], 'task-1');
      expect(json['result'], 'All tests pass');
      expect(json['startedAt'], isNotNull);
      expect(json['completedAt'], isNotNull);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'step-3',
        'type': 'delegate',
        'status': 'inProgress',
        'description': 'Delegate code review',
        'agentId': 'agent-2',
        'taskId': 'task-2',
        'result': 'In progress',
        'startedAt': '2026-06-11T10:00:00.000',
        'completedAt': '2026-06-11T10:30:00.000',
      };
      final step = ExecutionStep.fromJson(json);
      expect(step.id, 'step-3');
      expect(step.type, StepType.delegate);
      expect(step.status, StepStatus.inProgress);
      expect(step.description, 'Delegate code review');
      expect(step.agentId, 'agent-2');
      expect(step.taskId, 'task-2');
      expect(step.result, 'In progress');
      expect(step.startedAt, DateTime(2026, 6, 11, 10, 0));
      expect(step.completedAt, DateTime(2026, 6, 11, 10, 30));
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final step = ExecutionStep.fromJson(json);
      expect(step.id, '');
      expect(step.type, StepType.plan);
      expect(step.status, StepStatus.pending);
      expect(step.description, '');
      expect(step.agentId, isNull);
      expect(step.taskId, isNull);
      expect(step.result, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final step = ExecutionStep(
        id: 'step-1',
        type: StepType.plan,
        status: StepStatus.completed,
        description: 'Original',
        agentId: 'agent-1',
      );
      final copy = step.copyWith(description: 'Updated');
      expect(copy.id, 'step-1');
      expect(copy.type, StepType.plan);
      expect(copy.status, StepStatus.completed);
      expect(copy.description, 'Updated');
      expect(copy.agentId, 'agent-1');
    });

    test('copyWith clear flags work correctly', () {
      final step = ExecutionStep(
        id: 'step-1',
        type: StepType.plan,
        status: StepStatus.completed,
        description: 'Test',
        agentId: 'agent-1',
        result: 'done',
      );
      final copy = step.copyWith(
        clearAgentId: true,
        clearResult: true,
      );
      expect(copy.agentId, isNull);
      expect(copy.result, isNull);
    });
  });

  group('ExecutionTrace', () {
    final now = DateTime(2026, 6, 11, 12, 0, 0);

    test('constructor defaults', () {
      final trace = ExecutionTrace(
        id: 'trace-1',
        workspaceId: 'ws-1',
        leadAgentId: 'agent-lead-1',
        userRequest: 'Build a website',
      );
      expect(trace.status, ExecutionStatus.planning);
      expect(trace.steps, isEmpty);
      expect(trace.finalResponse, isNull);
      expect(trace.createdAt, isNotNull);
      expect(trace.updatedAt, isNotNull);
    });

    test('toJson/fromJson round-trip with all fields', () {
      final trace = ExecutionTrace(
        id: 'trace-1',
        workspaceId: 'ws-1',
        leadAgentId: 'agent-lead-1',
        userRequest: 'Build a website',
        status: ExecutionStatus.completed,
        steps: [
          ExecutionStep(
            id: 'step-1',
            type: StepType.plan,
            status: StepStatus.completed,
            description: 'Design',
          ),
          ExecutionStep(
            id: 'step-2',
            type: StepType.execute,
            status: StepStatus.completed,
            description: 'Implement',
            agentId: 'agent-worker-1',
            taskId: 'task-1',
          ),
        ],
        finalResponse: 'Website built successfully',
        createdAt: now,
        updatedAt: now,
      );
      final json = trace.toJson();
      final decoded = ExecutionTrace.fromJson(json);
      expect(decoded.id, 'trace-1');
      expect(decoded.workspaceId, 'ws-1');
      expect(decoded.leadAgentId, 'agent-lead-1');
      expect(decoded.userRequest, 'Build a website');
      expect(decoded.status, ExecutionStatus.completed);
      expect(decoded.steps.length, 2);
      expect(decoded.steps[0].id, 'step-1');
      expect(decoded.steps[1].agentId, 'agent-worker-1');
      expect(decoded.steps[1].taskId, 'task-1');
      expect(decoded.finalResponse, 'Website built successfully');
    });

    test('toJson omits finalResponse when null', () {
      final trace = ExecutionTrace(
        id: 'trace-1',
        workspaceId: 'ws-1',
        leadAgentId: 'agent-lead-1',
        userRequest: 'Test',
      );
      final json = trace.toJson();
      expect(json.containsKey('finalResponse'), false);
    });

    test('fromJson handles minimal JSON', () {
      final json = {
        'id': 'trace-1',
        'workspaceId': 'ws-1',
        'leadAgentId': 'agent-lead-1',
        'userRequest': 'Test',
        'status': 'planning',
        'steps': [],
        'createdAt': '2026-06-11T12:00:00.000',
        'updatedAt': '2026-06-11T12:00:00.000',
      };
      final trace = ExecutionTrace.fromJson(json);
      expect(trace.id, 'trace-1');
      expect(trace.steps, isEmpty);
      expect(trace.finalResponse, isNull);
    });

    test('copyWith preserves and overrides fields', () {
      final trace = ExecutionTrace(
        id: 'trace-1',
        workspaceId: 'ws-1',
        leadAgentId: 'agent-lead-1',
        userRequest: 'Original',
        status: ExecutionStatus.planning,
      );
      final copy = trace.copyWith(
        status: ExecutionStatus.completed,
        finalResponse: 'Done',
      );
      expect(copy.id, 'trace-1');
      expect(copy.workspaceId, 'ws-1');
      expect(copy.status, ExecutionStatus.completed);
      expect(copy.finalResponse, 'Done');
    });

    test('copyWith clearFinalResponse sets to null', () {
      final trace = ExecutionTrace(
        id: 'trace-1',
        workspaceId: 'ws-1',
        leadAgentId: 'agent-lead-1',
        userRequest: 'Test',
        finalResponse: 'Some result',
      );
      final copy = trace.copyWith(clearFinalResponse: true);
      expect(copy.finalResponse, isNull);
    });

    test('encodeList/decodeList round-trip', () {
      final traces = [
        ExecutionTrace(
          id: 'trace-1',
          workspaceId: 'ws-1',
          leadAgentId: 'agent-lead-1',
          userRequest: 'Request 1',
          status: ExecutionStatus.completed,
        ),
        ExecutionTrace(
          id: 'trace-2',
          workspaceId: 'ws-1',
          leadAgentId: 'agent-lead-1',
          userRequest: 'Request 2',
          status: ExecutionStatus.failed,
        ),
      ];
      final encoded = ExecutionTrace.encodeList(traces);
      final decoded = ExecutionTrace.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'trace-1');
      expect(decoded[0].userRequest, 'Request 1');
      expect(decoded[1].id, 'trace-2');
      expect(decoded[1].status, ExecutionStatus.failed);
    });

    test('decodeList handles invalid JSON gracefully', () {
      final decoded = ExecutionTrace.decodeList('');
      expect(decoded, isEmpty);
    });

    test('decodeList handles malformed JSON gracefully', () {
      final decoded = ExecutionTrace.decodeList('not json');
      expect(decoded, isEmpty);
    });
  });
}