import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/agent.dart';
import '../../models/agent_team.dart';
import '../../models/execution_trace.dart';
import '../../models/task.dart';
import 'worker_agent_service.dart';

/// Coordinates work between a Lead Agent and a team of Workers.
///
/// The Manager Agent sits between Lead and Workers:
///   Lead → Manager → Worker 1, Worker 2, ... → Manager → Lead
///
/// Responsibilities:
/// - Route tasks from Lead to appropriate Workers
/// - Monitor worker progress and collect results
/// - Report consolidated results back to the Lead Agent
class ManagerAgentService {
  final _uuid = const Uuid();
  final WorkerAgentService _workerService;

  ManagerAgentService({WorkerAgentService? workerService})
      : _workerService = workerService ?? WorkerAgentService();

  /// Execute a team's tasks through the Manager → Workers pipeline.
  ///
  /// [team] — the AgentTeam with lead and member IDs.
  /// [workerAgents] — Agent objects for team members (resolved from IDs).
  /// [tasks] — list of task assignments from the Lead Agent.
  /// [context] — original user request / execution context.
  /// [callLlm] — function to call an agent's LLM.
  /// [onWorkerProgress] — callback per completed worker task.
  Future<ManagerResult> orchestrate({
    required AgentTeam team,
    required List<Agent> workerAgents,
    required List<(String description, String? assigneeId)> tasks,
    required String context,
    required Future<String> Function({
      required String agentId,
      required String systemPrompt,
      required String userMessage,
    }) callLlm,
    void Function(int completed, int total)? onWorkerProgress,
  }) async {
    final managerSteps = <ExecutionStep>[];
    final workerResults = <String, String>{};

    // Log manager coordination
    managerSteps.add(ExecutionStep(
      id: _uuid.v4(),
      type: StepType.delegate,
      status: StepStatus.completed,
      description: 'Manager routes ${tasks.length} tasks to team',
      completedAt: DateTime.now(),
    ));

    // Execute each task through workers
    final workerTaskList = <({
      String agentId,
      String agentName,
      String description
    })>[];

    for (final (desc, assigneeId) in tasks) {
      if (assigneeId == null) continue;
      final worker = workerAgents.where((a) => a.id == assigneeId).firstOrNull;
      if (worker == null) continue;
      workerTaskList.add((
        agentId: worker.id,
        agentName: worker.name,
        description: desc,
      ));
    }

    final results = await _workerService.executeTasks(
      tasks: workerTaskList,
      context: context,
      callLlm: callLlm,
      onProgress: onWorkerProgress,
    );

    for (final result in results) {
      workerResults[result.agentId] = result.output;
      managerSteps.add(ExecutionStep(
        id: _uuid.v4(),
        type: StepType.execute,
        status: result.success ? StepStatus.completed : StepStatus.failed,
        description: 'Worker: ${result.agentName}',
        agentId: result.agentId,
        result:
            result.output.length > 200
                ? '${result.output.substring(0, 200)}...'
                : result.output,
        completedAt: DateTime.now(),
      ));
    }

    return ManagerResult(
      workerResults: workerResults,
      managerSteps: managerSteps,
      success: results.every((r) => r.success),
    );
  }
}

/// Result from a Manager Agent's orchestration.
class ManagerResult {
  final Map<String, String> workerResults;
  final List<ExecutionStep> managerSteps;
  final bool success;

  const ManagerResult({
    required this.workerResults,
    required this.managerSteps,
    required this.success,
  });
}