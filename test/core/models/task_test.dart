import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/task.dart';

void main() {
  group('TaskStatus', () {
    test('values contain all expected statuses', () {
      expect(TaskStatus.values, [
        TaskStatus.backlog,
        TaskStatus.todo,
        TaskStatus.inProgress,
        TaskStatus.review,
        TaskStatus.completed,
        TaskStatus.cancelled,
      ]);
    });

    test('toJson returns correct string', () {
      expect(TaskStatus.backlog.toJson(), 'backlog');
      expect(TaskStatus.todo.toJson(), 'todo');
      expect(TaskStatus.inProgress.toJson(), 'inProgress');
      expect(TaskStatus.review.toJson(), 'review');
      expect(TaskStatus.completed.toJson(), 'completed');
      expect(TaskStatus.cancelled.toJson(), 'cancelled');
    });

    test('fromJson parses correctly', () {
      expect(TaskStatus.fromJson('backlog'), TaskStatus.backlog);
      expect(TaskStatus.fromJson('todo'), TaskStatus.todo);
      expect(TaskStatus.fromJson('inProgress'), TaskStatus.inProgress);
      expect(TaskStatus.fromJson('review'), TaskStatus.review);
      expect(TaskStatus.fromJson('completed'), TaskStatus.completed);
      expect(TaskStatus.fromJson('cancelled'), TaskStatus.cancelled);
    });

    test('fromJson defaults to backlog for unknown values', () {
      expect(TaskStatus.fromJson('unknown'), TaskStatus.backlog);
      expect(TaskStatus.fromJson(''), TaskStatus.backlog);
    });
  });

  group('TaskPriority', () {
    test('values contain all expected priorities', () {
      expect(TaskPriority.values, [
        TaskPriority.none,
        TaskPriority.low,
        TaskPriority.medium,
        TaskPriority.high,
        TaskPriority.urgent,
      ]);
    });

    test('toJson returns correct string', () {
      expect(TaskPriority.none.toJson(), 'none');
      expect(TaskPriority.low.toJson(), 'low');
      expect(TaskPriority.medium.toJson(), 'medium');
      expect(TaskPriority.high.toJson(), 'high');
      expect(TaskPriority.urgent.toJson(), 'urgent');
    });

    test('fromJson parses correctly', () {
      expect(TaskPriority.fromJson('none'), TaskPriority.none);
      expect(TaskPriority.fromJson('low'), TaskPriority.low);
      expect(TaskPriority.fromJson('medium'), TaskPriority.medium);
      expect(TaskPriority.fromJson('high'), TaskPriority.high);
      expect(TaskPriority.fromJson('urgent'), TaskPriority.urgent);
    });

    test('fromJson defaults to none for unknown values', () {
      expect(TaskPriority.fromJson('unknown'), TaskPriority.none);
      expect(TaskPriority.fromJson(''), TaskPriority.none);
    });
  });

  group('Task', () {
    final now = DateTime(2026, 6, 11, 12, 0, 0);

    test('constructor sets correct defaults', () {
      final task = Task(
        id: 't-1',
        title: 'Test Task',
        createdAt: now,
        updatedAt: now,
      );
      expect(task.description, '');
      expect(task.status, TaskStatus.backlog);
      expect(task.priority, TaskPriority.none);
      expect(task.assigneeAgentId, isNull);
      expect(task.conversationId, isNull);
      expect(task.dueDate, isNull);
      expect(task.tags, isEmpty);
      expect(task.sortOrder, 0);
    });

    test('toJson and fromJson round-trip with all fields', () {
      final task = Task(
        id: 't-1',
        title: 'Fix login bug',
        description: 'Users cannot log in with SSO',
        workspaceId: 'ws-1',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assigneeAgentId: 'agent-1',
        conversationId: 'conv-1',
        dueDate: DateTime(2026, 6, 15),
        createdAt: now,
        updatedAt: now,
        tags: ['bug', 'auth'],
        sortOrder: 2,
      );
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.workspaceId, task.workspaceId);
      expect(restored.status, task.status);
      expect(restored.priority, task.priority);
      expect(restored.assigneeAgentId, task.assigneeAgentId);
      expect(restored.conversationId, task.conversationId);
      expect(
        restored.dueDate!.millisecondsSinceEpoch,
        task.dueDate!.millisecondsSinceEpoch,
      );
      expect(
        restored.createdAt.millisecondsSinceEpoch,
        task.createdAt.millisecondsSinceEpoch,
      );
      expect(
        restored.updatedAt.millisecondsSinceEpoch,
        task.updatedAt.millisecondsSinceEpoch,
      );
      expect(restored.tags, task.tags);
      expect(restored.sortOrder, task.sortOrder);
    });

    test('toJson and fromJson round-trip minimal fields', () {
      final task = Task(
        id: 't-2',
        title: 'Quick task',
        createdAt: now,
        updatedAt: now,
      );
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored.id, 't-2');
      expect(restored.title, 'Quick task');
      expect(restored.description, '');
      expect(restored.workspaceId, isNull);
      expect(restored.tags, isEmpty);
    });

    test('toJson omits empty optional fields', () {
      final task = Task(
        id: 't-1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );
      final json = task.toJson();
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('workspaceId'), isFalse);
      expect(json.containsKey('assigneeAgentId'), isFalse);
      expect(json.containsKey('conversationId'), isFalse);
      expect(json.containsKey('dueDate'), isFalse);
      expect(json.containsKey('tags'), isFalse);
      expect(json['status'], 'backlog');
      expect(json['priority'], 'none');
    });

    test('copyWith preserves unset fields', () {
      final task = Task(
        id: 't-1',
        title: 'Original',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      );
      final copy = task.copyWith(title: 'Updated');
      expect(copy.id, 't-1');
      expect(copy.title, 'Updated');
      expect(copy.status, TaskStatus.inProgress);
      expect(copy.priority, TaskPriority.high);
    });

    test('copyWith clearAssignee clears assignee', () {
      final task = Task(
        id: 't-1',
        title: 'Test',
        assigneeAgentId: 'agent-1',
        createdAt: now,
        updatedAt: now,
      );
      final copy = task.copyWith(clearAssignee: true);
      expect(copy.assigneeAgentId, isNull);
    });

    test('copyWith clearDueDate clears due date', () {
      final task = Task(
        id: 't-1',
        title: 'Test',
        dueDate: DateTime(2026, 6, 15),
        createdAt: now,
        updatedAt: now,
      );
      final copy = task.copyWith(clearDueDate: true);
      expect(copy.dueDate, isNull);
    });

    test('copyWith clearDescription clears description', () {
      final task = Task(
        id: 't-1',
        title: 'Test',
        description: 'Some desc',
        createdAt: now,
        updatedAt: now,
      );
      final copy = task.copyWith(clearDescription: true);
      expect(copy.description, '');
    });

    test('copyWith clearTags clears tags', () {
      final task = Task(
        id: 't-1',
        title: 'Test',
        tags: ['bug'],
        createdAt: now,
        updatedAt: now,
      );
      final copy = task.copyWith(clearTags: true);
      expect(copy.tags, isEmpty);
    });

    test('encodeList and decodeList round-trip', () {
      final tasks = [
        Task(id: 't-1', title: 'Task 1', createdAt: now, updatedAt: now),
        Task(
          id: 't-2',
          title: 'Task 2',
          status: TaskStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final encoded = Task.encodeList(tasks);
      final decoded = Task.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 't-1');
      expect(decoded[0].status, TaskStatus.backlog);
      expect(decoded[1].id, 't-2');
      expect(decoded[1].status, TaskStatus.inProgress);
    });

    test('decodeList returns empty on invalid JSON', () {
      final decoded = Task.decodeList('not json');
      expect(decoded, isEmpty);
    });
  });
}
