import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/execution_trace.dart';

/// Manages [ExecutionTrace] persistence and lifecycle.
///
/// Stores traces in SharedPreferences under the `execution_traces_v1` key.
/// Provides workspace-scoped queries and live [ChangeNotifier] updates.
class TraceProvider extends ChangeNotifier {
  static const String _storageKey = 'execution_traces_v1';

  final List<ExecutionTrace> _traces = <ExecutionTrace>[];
  bool _loaded = false; // ignore: unused_field

  /// Unmodifiable view of all traces.
  UnmodifiableListView<ExecutionTrace> get traces =>
      UnmodifiableListView(_traces);

  TraceProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _traces.addAll(ExecutionTrace.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, ExecutionTrace.encodeList(_traces));
  }

  /// Get traces for a workspace, sorted newest-first.
  List<ExecutionTrace> getTracesForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_traces);
    final result = _traces
        .where((t) => t.workspaceId == workspaceId)
        .toList(growable: false);
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Get the most recent trace for a lead agent in a workspace.
  ExecutionTrace? getLatestTraceForAgent(String? workspaceId, String agentId) {
    final agentTraces = _traces.where(
      (t) =>
          (workspaceId == null || t.workspaceId == workspaceId) &&
          t.leadAgentId == agentId,
    );
    if (agentTraces.isEmpty) return null;
    return agentTraces.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
  }

  /// Get a single trace by ID.
  ExecutionTrace? getById(String id) {
    final idx = _traces.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    return _traces[idx];
  }

  /// Create a new execution trace.
  Future<void> createTrace(ExecutionTrace trace) async {
    _traces.add(trace);
    await _persist();
    notifyListeners();
  }

  /// Replace a trace with updated values.
  Future<void> updateTrace(String id, ExecutionTrace updates) async {
    final index = _traces.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _traces[index] = updates;
    await _persist();
    notifyListeners();
  }

  /// Append a step to an existing trace.
  Future<void> addStep(String traceId, ExecutionStep step) async {
    final index = _traces.indexWhere((t) => t.id == traceId);
    if (index == -1) return;
    final trace = _traces[index];
    _traces[index] = trace.copyWith(
      steps: [...trace.steps, step],
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Update a specific step within a trace.
  Future<void> updateStep(
    String traceId,
    String stepId,
    ExecutionStep updatedStep,
  ) async {
    final traceIndex = _traces.indexWhere((t) => t.id == traceId);
    if (traceIndex == -1) return;
    final trace = _traces[traceIndex];
    final stepIndex = trace.steps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) return;
    final updatedSteps = List<ExecutionStep>.of(trace.steps);
    updatedSteps[stepIndex] = updatedStep;
    _traces[traceIndex] = trace.copyWith(
      steps: updatedSteps,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Update trace status and optionally set finalResponse.
  Future<void> completeTrace(
    String id, {
    ExecutionStatus? status,
    String? finalResponse,
  }) async {
    final index = _traces.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final trace = _traces[index];
    _traces[index] = trace.copyWith(
      status: status ?? trace.status,
      finalResponse: finalResponse,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Delete a trace by ID.
  Future<void> deleteTrace(String id) async {
    _traces.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  /// Delete all traces for a workspace.
  Future<void> deleteTracesForWorkspace(String workspaceId) async {
    _traces.removeWhere((t) => t.workspaceId == workspaceId);
    await _persist();
    notifyListeners();
  }
}
