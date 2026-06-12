import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/runtime_execution.dart';
import '../services/scheduler_service.dart';
import '../services/lead_agent_service.dart';

/// The host's lifecycle status.
enum RuntimeHostStatus {
  stopped,
  running,
  error;

  static RuntimeHostStatus fromJson(String value) {
    return RuntimeHostStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RuntimeHostStatus.stopped,
    );
  }

  String toJson() => name;
}

/// Manages the runtime host: tracks server uptime, active/past executions,
/// and integrates with [SchedulerService] for scheduled runs.
///
/// Persists execution history to SharedPreferences under `runtime_executions_v1`.
/// Uses [LeadAgentService] for actual agent execution instead of simulation.
class RuntimeProvider extends ChangeNotifier {
  static const String _executionsKey = 'runtime_executions_v1';
  static const String _statusKey = 'runtime_host_status_v1';

  final Uuid _uuid = const Uuid();
  RuntimeHostStatus _hostStatus = RuntimeHostStatus.stopped;
  final List<RuntimeExecution> _executions = <RuntimeExecution>[];
  bool _loaded = false; // ignore: unused_field
  DateTime? _hostStartedAt;

  SchedulerService? _scheduler;
  LeadAgentService? _leadAgentService;

  RuntimeHostStatus get hostStatus => _hostStatus;
  List<RuntimeExecution> get executions => List.unmodifiable(_executions);
  bool get isLoaded => _loaded;
  DateTime? get hostStartedAt => _hostStartedAt;

  /// Total uptime since the host was last started.
  Duration? get uptime {
    if (_hostStartedAt == null) return null;
    return DateTime.now().difference(_hostStartedAt!);
  }

  /// The most recent execution, if any.
  RuntimeExecution? get lastExecution =>
      _executions.isNotEmpty ? _executions.last : null;

  /// Number of successful executions.
  int get successCount => _executions
      .where((e) => e.status == RuntimeExecutionStatus.completed)
      .length;

  /// Number of failed executions.
  int get failedCount => _executions
      .where((e) => e.status == RuntimeExecutionStatus.failed)
      .length;

  /// Executions currently in progress.
  List<RuntimeExecution> get activeExecutions => _executions
      .where((e) => e.status == RuntimeExecutionStatus.running)
      .toList();

  RuntimeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final execRaw = prefs.getString(_executionsKey);
    if (execRaw != null && execRaw.isNotEmpty) {
      _executions.addAll(RuntimeExecution.decodeList(execRaw));
    }
    final statusRaw = prefs.getString(_statusKey);
    if (statusRaw != null && statusRaw.isNotEmpty) {
      try {
        _hostStatus = RuntimeHostStatus.fromJson(statusRaw);
        if (_hostStatus == RuntimeHostStatus.running) {
          _hostStartedAt = DateTime.now();
        }
      } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistExecutions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _executionsKey,
      RuntimeExecution.encodeList(_executions),
    );
  }

  Future<void> _persistHostStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, _hostStatus.toJson());
  }

  /// Link to a [SchedulerService] so the runtime can manage scheduler lifecycle.
  void attachScheduler(SchedulerService scheduler) {
    _scheduler = scheduler;
  }

  /// Link to a [LeadAgentService] for actual agent execution.
  void attachLeadAgentService(LeadAgentService service) {
    _leadAgentService = service;
  }

  /// Start the runtime host.
  Future<void> startHost() async {
    _hostStatus = RuntimeHostStatus.running;
    _hostStartedAt = DateTime.now();
    _scheduler?.start();
    await _persistHostStatus();
    notifyListeners();
  }

  /// Stop the runtime host.
  Future<void> stopHost() async {
    _hostStatus = RuntimeHostStatus.stopped;
    _hostStartedAt = null;
    _scheduler?.stop();
    await _persistHostStatus();
    notifyListeners();
  }

  /// Record a new execution.
  Future<RuntimeExecution> startExecution({
    required String agentId,
    required String agentName,
    required String workspaceId,
    String taskId = '',
    String taskTitle = '',
  }) async {
    final execution = RuntimeExecution(
      id: _uuid.v4(),
      agentId: agentId,
      agentName: agentName,
      workspaceId: workspaceId,
      taskId: taskId,
      taskTitle: taskTitle,
      status: RuntimeExecutionStatus.running,
      startedAt: DateTime.now(),
    );
    _executions.add(execution);
    await _persistExecutions();
    notifyListeners();
    return execution;
  }

  /// Complete an execution with results.
  Future<void> completeExecution(
    String executionId, {
    String resultSummary = '',
  }) async {
    final idx = _executions.indexWhere((e) => e.id == executionId);
    if (idx == -1) return;
    _executions[idx] = _executions[idx].copyWith(
      status: RuntimeExecutionStatus.completed,
      resultSummary: resultSummary,
      completedAt: DateTime.now(),
    );
    await _persistExecutions();
    notifyListeners();
  }

  /// Mark an execution as failed.
  Future<void> failExecution(
    String executionId, {
    String errorMessage = '',
  }) async {
    final idx = _executions.indexWhere((e) => e.id == executionId);
    if (idx == -1) return;
    _executions[idx] = _executions[idx].copyWith(
      status: RuntimeExecutionStatus.failed,
      errorMessage: errorMessage,
      completedAt: DateTime.now(),
    );
    await _persistExecutions();
    notifyListeners();
  }

  /// Cancel a running execution.
  Future<void> cancelExecution(String executionId) async {
    final idx = _executions.indexWhere((e) => e.id == executionId);
    if (idx == -1) return;
    _executions[idx] = _executions[idx].copyWith(
      status: RuntimeExecutionStatus.cancelled,
      completedAt: DateTime.now(),
    );
    await _persistExecutions();
    notifyListeners();
  }

  /// Execute a lead agent in the runtime with real LLM calls.
  ///
  /// Uses [LeadAgentService] to run the full plan → delegate → execute → review
  /// pipeline. Replaces the old placeholder simulateExecution().
  Future<RuntimeExecution> executeAgent({
    required String userRequest,
    required String agentId,
    required String agentName,
    required String workspaceId,
    void Function(String summary)? onProgress,
  }) async {
    final exec = await startExecution(
      agentId: agentId,
      agentName: agentName,
      workspaceId: workspaceId,
      taskTitle: userRequest.length > 80
          ? '${userRequest.substring(0, 80)}...'
          : userRequest,
    );

    if (_leadAgentService == null) {
      await failExecution(
        exec.id,
        errorMessage: 'LeadAgentService not attached',
      );
      return exec;
    }

    try {
      final result = await _leadAgentService!.execute(
        userRequest: userRequest,
        workspaceId: workspaceId,
        leadAgentId: agentId,
        onProgress: (trace) {
          final summary = trace.status.name;
          onProgress?.call(summary);
        },
      );

      if (result.success) {
        await completeExecution(
          exec.id,
          resultSummary: result.finalResponse ?? '(no response)',
        );
      } else {
        await failExecution(
          exec.id,
          errorMessage: result.errorMessage ?? 'Unknown error',
        );
      }
    } catch (e) {
      await failExecution(exec.id, errorMessage: e.toString());
    }

    return exec;
  }

  /// Get executions for a workspace.
  List<RuntimeExecution> getExecutionsForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_executions);
    return _executions
        .where((e) => e.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get executions for a specific agent.
  List<RuntimeExecution> getExecutionsForAgent(String agentId) {
    return _executions
        .where((e) => e.agentId == agentId)
        .toList(growable: false);
  }

  /// Clear all execution history.
  Future<void> clearHistory() async {
    _executions.clear();
    await _persistExecutions();
    notifyListeners();
  }

  /// Prune execution history older than the given date.
  Future<void> pruneHistoryOlderThan(DateTime cutoff) async {
    _executions.removeWhere(
      (e) =>
          e.startedAt.isBefore(cutoff) &&
          e.status != RuntimeExecutionStatus.running,
    );
    await _persistExecutions();
    notifyListeners();
  }
}
