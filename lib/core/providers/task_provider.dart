import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

/// Manages the lifecycle of Tasks.
///
/// Tasks are persisted to SharedPreferences under the `tasks_v1` key.
/// Each task belongs to a workspace (via [Task.workspaceId]) and can be
/// assigned to an agent (via [Task.assigneeAgentId]).
class TaskProvider extends ChangeNotifier {
  static const String _tasksKey = 'tasks_v1';

  final List<Task> _tasks = <Task>[];
  bool _loaded = false;

  /// Unmodifiable view of all tasks.
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  /// Whether the provider has finished loading from disk.
  bool get loaded => _loaded;

  /// Number of tasks.
  int get taskCount => _tasks.length;

  TaskProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw != null && raw.isNotEmpty) {
      _tasks.addAll(Task.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, Task.encodeList(_tasks));
  }

  /// Get a task by ID.
  Task? getById(String id) {
    final idx = _tasks.indexWhere((a) => a.id == id);
    if (idx == -1) return null;
    return _tasks[idx];
  }

  /// Get all tasks for a workspace.
  List<Task> getTasksForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_tasks);
    return _tasks
        .where((t) => t.workspaceId == null || t.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get tasks for a workspace filtered by status.
  List<Task> getTasksForWorkspaceByStatus(
    String? workspaceId,
    TaskStatus status,
  ) {
    return getTasksForWorkspace(
      workspaceId,
    ).where((t) => t.status == status).toList(growable: false);
  }

  /// Get tasks assigned to a specific agent.
  List<Task> getTasksForAgent(String agentId) {
    return _tasks
        .where((t) => t.assigneeAgentId == agentId)
        .toList(growable: false);
  }

  /// Create a new task.
  Future<Task> createTask({
    required String title,
    String description = '',
    String? workspaceId,
    TaskStatus status = TaskStatus.backlog,
    TaskPriority priority = TaskPriority.none,
    String? assigneeAgentId,
    String? conversationId,
    DateTime? dueDate,
    List<String> tags = const <String>[],
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      workspaceId: workspaceId,
      status: status,
      priority: priority,
      assigneeAgentId: assigneeAgentId,
      conversationId: conversationId,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      sortOrder: _tasks.length,
    );
    _tasks.add(task);
    await _persist();
    notifyListeners();
    return task;
  }

  /// Update an existing task.
  Future<void> updateTask(Task updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    _tasks[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _persist();
    notifyListeners();
  }

  /// Update just the status (shortcut for drag-and-drop).
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Update just the priority (shortcut).
  Future<void> updateTaskPriority(String taskId, TaskPriority priority) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(
      priority: priority,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Assign a task to an agent.
  Future<void> assignTask(String taskId, String agentId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(
      assigneeAgentId: agentId,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Unassign a task.
  Future<void> unassignTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(
      clearAssignee: true,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Delete a task.
  Future<bool> deleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    _tasks.removeAt(idx);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Reorder tasks within a specific status column.
  Future<void> reorderTasks({
    required String taskId,
    required TaskStatus newStatus,
    required int newIndex,
  }) async {
    final task = getById(taskId);
    if (task == null) return;

    // Remove from current position
    _tasks.removeWhere((t) => t.id == taskId);

    // Update status
    final updated = task.copyWith(
      status: newStatus,
      sortOrder: newIndex,
      updatedAt: DateTime.now(),
    );

    // Insert at new position
    if (newIndex >= _tasks.length) {
      _tasks.add(updated);
    } else {
      _tasks.insert(newIndex, updated);
    }

    // Renumber sortOrder for all tasks in the target status
    _renumberSortOrders(newStatus);

    await _persist();
    notifyListeners();
  }

  /// Renumber sortOrder for all tasks in a given status column.
  void _renumberSortOrders(TaskStatus status) {
    int order = 0;
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].status == status) {
        _tasks[i] = _tasks[i].copyWith(sortOrder: order++);
      }
    }
  }

  /// Get counts per status for a workspace.
  Map<TaskStatus, int> getStatusCounts(String? workspaceId) {
    final tasks = getTasksForWorkspace(workspaceId);
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = tasks.where((t) => t.status == status).length;
    }
    return counts;
  }

  /// Delete all tasks for a workspace (e.g. when deleting workspace).
  Future<void> deleteTasksForWorkspace(String workspaceId) async {
    _tasks.removeWhere((t) => t.workspaceId == workspaceId);
    await _persist();
    notifyListeners();
  }
}
