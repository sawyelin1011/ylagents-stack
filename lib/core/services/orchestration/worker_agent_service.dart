import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/agent.dart';
import '../../models/execution_trace.dart';
import '../../models/task.dart';

/// Result from a single worker's execution.
class WorkerExecutionResult {
  final String agentId;
  final String agentName;
  final String output;
  final bool success;
  final String? errorMessage;

  const WorkerExecutionResult({
    required this.agentId,
    required this.agentName,
    required this.output,
    required this.success,
    this.errorMessage,
  });
}

/// Executes tasks assigned to Worker Agents.
///
/// Each worker runs independently against its configured LLM.
/// Workers do NOT communicate with each other — all results
/// flow back through the Lead or Manager agent.
class WorkerAgentService {
  final _uuid = const Uuid();

  /// Execute a single task using a worker agent's LLM.
  ///
  /// [agentId] — the worker agent to use (must be AgentType.worker).
  /// [taskDescription] — the task to execute.
  /// [context] — additional context (e.g. original user request, team goal).
  /// [callLlm] — function that calls an agent's LLM and returns text.
  Future<WorkerExecutionResult> executeTask({
    required String agentId,
    required String agentName,
    required String taskDescription,
    required String context,
    required Future<String> Function({
      required String agentId,
      required String systemPrompt,
      required String userMessage,
    }) callLlm,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(agentName, context);
      final output = await callLlm(
        agentId: agentId,
        systemPrompt: systemPrompt,
        userMessage: taskDescription,
      );
      return WorkerExecutionResult(
        agentId: agentId,
        agentName: agentName,
        output: output,
        success: true,
      );
    } catch (e) {
      return WorkerExecutionResult(
        agentId: agentId,
        agentName: agentName,
        output: '',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Execute multiple tasks in sequence, collecting results.
  Future<List<WorkerExecutionResult>> executeTasks({
    required List<({String agentId, String agentName, String description})> tasks,
    required String context,
    required Future<String> Function({
      required String agentId,
      required String systemPrompt,
      required String userMessage,
    }) callLlm,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <WorkerExecutionResult>[];
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final result = await executeTask(
        agentId: task.agentId,
        agentName: task.agentName,
        taskDescription: task.description,
        context: context,
        callLlm: callLlm,
      );
      results.add(result);
      onProgress?.call(i + 1, tasks.length);
    }
    return results;
  }

  String _buildSystemPrompt(String agentName, String context) {
    return 'You are $agentName, a specialized Worker Agent.\n\n'
        'Context: $context\n\n'
        'Complete the assigned task efficiently and thoroughly. '
        'Return only your work output — no meta-commentary about being an AI.';
  }
}