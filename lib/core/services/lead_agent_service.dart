import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../models/agent.dart';
import '../models/execution_trace.dart';
import '../models/task.dart';
import '../providers/agent_provider.dart';
import '../providers/assistant_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/trace_provider.dart';
import 'api/chat_api_service.dart';

/// Result of a lead agent execution.
class LeadAgentResult {
  final bool success;
  final String? finalResponse;
  final String? errorMessage;
  final ExecutionTrace trace;

  const LeadAgentResult({
    required this.success,
    this.finalResponse,
    this.errorMessage,
    required this.trace,
  });
}

/// Orchestrates the Lead Agent execution flow:
/// Plan → Delegate → Execute → Review.
///
/// Does NOT modify the existing chat pipeline. Operates as a standalone
/// service that creates tasks, assigns agents, collects results, and
/// returns a consolidated response.
class LeadAgentService {
  final AgentProvider agentProvider;
  final AssistantProvider assistantProvider;
  final SettingsProvider settingsProvider;
  final TaskProvider taskProvider;
  final TraceProvider traceProvider;

  LeadAgentService({
    required this.agentProvider,
    required this.assistantProvider,
    required this.settingsProvider,
    required this.taskProvider,
    required this.traceProvider,
  });

  final _uuid = const Uuid();

  /// Execute a lead agent's full plan → delegate → execute → review cycle.
  ///
  /// [userRequest] is the user's original goal.
  /// [workspaceId] scopes the execution to a workspace.
  /// [leadAgentId] identifies the lead agent to use.
  /// [onProgress] is called for each step update (for UI feedback).
  Future<LeadAgentResult> execute({
    required String userRequest,
    required String workspaceId,
    required String leadAgentId,
    void Function(ExecutionTrace trace)? onProgress,
    AppLocalizations? l10n,
  }) async {
    var trace = ExecutionTrace(
      id: _uuid.v4(),
      workspaceId: workspaceId,
      leadAgentId: leadAgentId,
      userRequest: userRequest,
    );

    try {
      // 1. Plan
      await traceProvider.createTrace(trace);
      onProgress?.call(trace);
      final planSteps = await _plan(userRequest, leadAgentId, workspaceId);
      trace = trace.copyWith(
        steps: [...trace.steps, ...planSteps],
        status: ExecutionStatus.delegating,
        updatedAt: DateTime.now(),
      );
      await _updateTrace(trace);
      onProgress?.call(trace);

      // 2. Delegate — find available workers
      final workers = _getAvailableWorkers(workspaceId, leadAgentId);
      final subTasks = await _delegate(
        userRequest,
        planSteps,
        workers,
        workspaceId,
      );
      for (final task in subTasks) {
        await taskProvider.createTask(task);
        trace = trace.copyWith(
          steps: [
            ...trace.steps,
            ExecutionStep(
              id: _uuid.v4(),
              type: StepType.delegate,
              status: StepStatus.completed,
              description:
                  l10n?.leadAgentDelegatedTo(task.title) ??
                  'Delegated: ${task.title}',
              agentId: task.assigneeAgentId,
              taskId: task.id,
              completedAt: DateTime.now(),
            ),
          ],
          updatedAt: DateTime.now(),
        );
      }
      await _updateTrace(trace.copyWith(status: ExecutionStatus.executing));
      onProgress?.call(trace);

      // 3. Execute — run each worker task and collect results
      final workerResults = <String, String>{};
      for (final task in subTasks) {
        if (task.assigneeAgentId == null) continue;
        final workerResult = await _executeTask(task, leadAgentId, userRequest);
        workerResults[task.id] = workerResult;
        await taskProvider.updateTaskStatus(task.id, TaskStatus.completed);
        final stepIndex =
            trace.steps.length - (subTasks.length - subTasks.indexOf(task));
        // Update the corresponding execution step
        trace = trace.copyWith(
          steps: trace.steps.map((s) {
            if (s.taskId == task.id) {
              return s.copyWith(
                status: StepStatus.completed,
                result: workerResult.substring(
                  0,
                  workerResult.length > 200 ? 200 : workerResult.length,
                ),
                completedAt: DateTime.now(),
              );
            }
            return s;
          }).toList(),
          updatedAt: DateTime.now(),
        );
        await _updateTrace(trace);
        onProgress?.call(trace);
      }

      // 4. Review — consolidate all worker results
      await _updateTrace(trace.copyWith(status: ExecutionStatus.reviewing));
      onProgress?.call(trace);
      final finalResponse = await _review(
        userRequest,
        planSteps,
        workerResults,
        leadAgentId,
      );

      // 5. Complete
      trace = trace.copyWith(
        status: ExecutionStatus.completed,
        finalResponse: finalResponse,
        updatedAt: DateTime.now(),
      );
      await _updateTrace(trace);
      onProgress?.call(trace);

      return LeadAgentResult(
        success: true,
        finalResponse: finalResponse,
        trace: trace,
      );
    } catch (e) {
      trace = trace.copyWith(
        status: ExecutionStatus.failed,
        updatedAt: DateTime.now(),
      );
      await _updateTrace(trace);
      onProgress?.call(trace);
      return LeadAgentResult(
        success: false,
        errorMessage: e.toString(),
        trace: trace,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Planning: Use the lead agent's LLM to break the request into sub-tasks
  // ---------------------------------------------------------------------------

  Future<List<ExecutionStep>> _plan(
    String userRequest,
    String leadAgentId,
    String workspaceId,
  ) async {
    final plan = await _callLlm(
      agentId: leadAgentId,
      systemPrompt: _planSystemPrompt,
      userMessage: userRequest,
    );

    // Parse the plan into steps — we expect a markdown list or JSON array
    final steps = <ExecutionStep>[];
    final lines = plan.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // Match list items: - Task description or 1. Task description
      final taskText = _extractTaskDescription(trimmed);
      if (taskText != null) {
        steps.add(
          ExecutionStep(
            id: _uuid.v4(),
            type: StepType.plan,
            status: StepStatus.completed,
            description: taskText,
            completedAt: DateTime.now(),
          ),
        );
      }
    }

    if (steps.isEmpty) {
      // Fallback: create a single "execute plan" step
      steps.add(
        ExecutionStep(
          id: _uuid.v4(),
          type: StepType.plan,
          status: StepStatus.completed,
          description: userRequest.substring(
            0,
            userRequest.length > 100 ? 100 : userRequest.length,
          ),
          completedAt: DateTime.now(),
        ),
      );
    }

    return steps;
  }

  String? _extractTaskDescription(String line) {
    // Matches markdown list items: - text, * text, 1. text, - [ ] text
    final patterns = [
      RegExp(r'^[-*\d]+\.?\s*(?:\[.\]\s*)?(.+)$'),
      RegExp(r'^\d+[.)]\s*(.+)$'),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(line);
      if (match != null) {
        final text = match.group(1)?.trim();
        if (text != null && text.isNotEmpty) return text;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Delegation: Create Task objects and assign to workers
  // ---------------------------------------------------------------------------

  Future<List<Task>> _delegate(
    String userRequest,
    List<ExecutionStep> planSteps,
    List<Agent> workers,
    String workspaceId,
  ) async {
    final tasks = <Task>[];
    for (int i = 0; i < planSteps.length; i++) {
      final step = planSteps[i];
      final assigneeId = i < workers.length ? workers[i].id : null;
      tasks.add(
        Task(
          id: _uuid.v4(),
          title: step.description.substring(
            0,
            step.description.length > 80 ? 80 : step.description.length,
          ),
          description:
              'Original request: $userRequest\n\nTask: ${step.description}',
          workspaceId: workspaceId,
          status: TaskStatus.todo,
          assigneeAgentId: assigneeId,
          sortOrder: i,
        ),
      );
    }
    return tasks;
  }

  // ---------------------------------------------------------------------------
  // Execution: Call a worker agent's LLM to complete a task
  // ---------------------------------------------------------------------------

  Future<String> _executeTask(
    Task task,
    String leadAgentId,
    String userRequest,
  ) async {
    final agentId = task.assigneeAgentId;
    if (agentId == null) return 'No agent assigned';

    return _callLlm(
      agentId: agentId,
      systemPrompt: _buildWorkerPrompt(agentId, userRequest),
      userMessage: task.description,
    );
  }

  // ---------------------------------------------------------------------------
  // Review: Consolidate all worker results
  // ---------------------------------------------------------------------------

  Future<String> _review(
    String userRequest,
    List<ExecutionStep> planSteps,
    Map<String, String> workerResults,
    String leadAgentId,
  ) async {
    final resultsText = workerResults.entries
        .map((e) {
          final taskIndex = planSteps.indexWhere((s) => s.id == e.key);
          final taskDesc = taskIndex >= 0
              ? planSteps[taskIndex].description
              : 'Task';
          return '## $taskDesc\n\n${e.value}';
        })
        .join('\n\n---\n\n');

    final reviewPrompt =
        '''
User's original request: $userRequest

Worker results:
$resultsText

Please review and consolidate the above results into a comprehensive final response.
Synthesize the information, resolve any contradictions, and present a clear answer.
''';

    return _callLlm(
      agentId: leadAgentId,
      systemPrompt: _reviewSystemPrompt,
      userMessage: reviewPrompt,
    );
  }

  // ---------------------------------------------------------------------------
  // LLM Integration
  // ---------------------------------------------------------------------------

  /// Call an agent's LLM and return the full text response.
  Future<String> _callLlm({
    required String agentId,
    required String systemPrompt,
    required String userMessage,
  }) async {
    // Get the assistant for this agent
    final agent = agentProvider.getById(agentId);
    final assistant = assistantProvider.getById(agentId);
    if (assistant == null) return 'Assistant not found';

    final providerKey =
        assistant.chatModelProvider ?? settingsProvider.currentModelProvider;
    final modelId = assistant.chatModelId ?? settingsProvider.currentModelId;
    if (providerKey == null || modelId == null) {
      return 'Model not configured for this agent';
    }

    final config = settingsProvider.getProviderConfig(providerKey);
    final messages = <Map<String, dynamic>>[
      if (systemPrompt.isNotEmpty) {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final completer = Completer<String>();
      final buffer = StringBuffer();

      final stream = ChatApiService.sendMessageStream(
        config: config,
        modelId: modelId,
        messages: messages,
        stream: false,
        requestId: 'lead-agent-${_uuid.v4()}',
      );

      stream.listen(
        (chunk) {
          if (chunk.content.isNotEmpty) {
            buffer.write(chunk.content);
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(
              buffer.isNotEmpty ? buffer.toString() : 'Error: $e',
            );
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(
              buffer.isNotEmpty ? buffer.toString() : '(empty response)',
            );
          }
        },
        cancelOnError: false,
      );

      return completer.future;
    } catch (e) {
      return 'LLM call failed: $e';
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<Agent> _getAvailableWorkers(String workspaceId, String excludeAgentId) {
    final allAgents = agentProvider.getAgentsForWorkspace(workspaceId);
    return allAgents
        .where(
          (a) =>
              a.type == AgentType.worker && a.enabled && a.id != excludeAgentId,
        )
        .toList();
  }

  String _buildWorkerPrompt(String agentId, String userRequest) {
    final agent = agentProvider.getById(agentId);
    if (agent == null || agent.genome.isEmpty) {
      return 'You are a specialized AI worker. Complete the assigned task efficiently.';
    }
    final g = agent.genome;
    return [
      if (g.identity.isNotEmpty) 'You are ${g.identity}.',
      if (g.soul.isNotEmpty) g.soul,
      if (g.role.isNotEmpty) 'Your role: ${g.role}.',
      if (g.goals.isNotEmpty) 'Your goals: ${g.goals.join(', ')}.',
      '',
      'The user\'s original request was: $userRequest',
      'Complete the assigned task below as part of a larger workflow.',
    ].join('\n');
  }

  Future<void> _updateTrace(ExecutionTrace trace) async {
    await traceProvider.updateTrace(trace.id, trace);
  }

  // ---------------------------------------------------------------------------
  // System prompts for the lead agent
  // ---------------------------------------------------------------------------

  static const String _planSystemPrompt = '''
You are a Lead Agent responsible for breaking down complex user requests into clear,
actionable sub-tasks.

Analyze the user's request and list the sub-tasks needed to complete it.
Format each task as a markdown list item starting with "- ".
Each task should be specific and actionable.
Aim for 2-5 sub-tasks for most requests. Do not create too many sub-tasks.
''';

  static const String _reviewSystemPrompt = '''
You are a Lead Agent reviewing work completed by your team of specialized worker agents.

Synthesize the results into a coherent final response.
- Integrate information from all workers
- Resolve any contradictions
- Present a clear, well-structured answer
- Write as if you are directly responding to the user
- Credit specific workers when their contributions are notable
''';
}
