import 'dart:convert';

/// Tracks a lead agent's execution lifecycle.
///
/// An [ExecutionTrace] captures the full plan → delegate → review flow
/// so users can see progress, inspect results, and debug failures.
class ExecutionTrace {
  final String id;
  final String workspaceId;
  final String leadAgentId;

  /// The user's original request that triggered this execution.
  final String userRequest;

  /// Current overall status.
  final ExecutionStatus status;

  /// Ordered list of execution steps.
  final List<ExecutionStep> steps;

  /// Final consolidated response after review (null until completed).
  final String? finalResponse;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ExecutionTrace({
    required this.id,
    required this.workspaceId,
    required this.leadAgentId,
    required this.userRequest,
    this.status = ExecutionStatus.planning,
    this.steps = const [],
    this.finalResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ExecutionTrace copyWith({
    String? id,
    String? workspaceId,
    String? leadAgentId,
    String? userRequest,
    ExecutionStatus? status,
    List<ExecutionStep>? steps,
    String? finalResponse,
    bool clearFinalResponse = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExecutionTrace(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      leadAgentId: leadAgentId ?? this.leadAgentId,
      userRequest: userRequest ?? this.userRequest,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      finalResponse:
          clearFinalResponse ? null : (finalResponse ?? this.finalResponse),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workspaceId': workspaceId,
    'leadAgentId': leadAgentId,
    'userRequest': userRequest,
    'status': status.toJson(),
    'steps': steps.map((s) => s.toJson()).toList(),
    if (finalResponse != null) 'finalResponse': finalResponse,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ExecutionTrace.fromJson(Map<String, dynamic> json) {
    return ExecutionTrace(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      leadAgentId: json['leadAgentId'] as String,
      userRequest: json['userRequest'] as String,
      status: ExecutionStatus.fromJson(
        (json['status'] as String?) ?? 'planning',
      ),
      steps: (json['steps'] as List<dynamic>?)
              ?.map(
                (e) => ExecutionStep.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      finalResponse: json['finalResponse'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static String encodeList(List<ExecutionTrace> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ExecutionTrace> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr)
          ExecutionTrace.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }
}

/// Overall execution status for an [ExecutionTrace].
enum ExecutionStatus {
  planning,
  delegating,
  executing,
  reviewing,
  completed,
  failed;

  String toJson() => name;

  static ExecutionStatus fromJson(String value) {
    return ExecutionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExecutionStatus.failed,
    );
  }
}

/// A single step within an execution trace.
class ExecutionStep {
  final String id;
  final StepType type;
  final StepStatus status;
  final String description;

  /// The agent that handled this step (null during planning/review).
  final String? agentId;

  /// The task ID if this step created a task.
  final String? taskId;

  /// Output or error message from this step.
  final String? result;

  final DateTime? startedAt;
  final DateTime? completedAt;

  const ExecutionStep({
    required this.id,
    required this.type,
    this.status = StepStatus.pending,
    required this.description,
    this.agentId,
    this.taskId,
    this.result,
    this.startedAt,
    this.completedAt,
  });

  ExecutionStep copyWith({
    String? id,
    StepType? type,
    StepStatus? status,
    String? description,
    String? agentId,
    bool clearAgentId = false,
    String? taskId,
    bool clearTaskId = false,
    String? result,
    bool clearResult = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ExecutionStep(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      agentId: clearAgentId ? null : (agentId ?? this.agentId),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      result: clearResult ? null : (result ?? this.result),
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'status': status.toJson(),
    'description': description,
    if (agentId != null) 'agentId': agentId,
    if (taskId != null) 'taskId': taskId,
    if (result != null) 'result': result,
    if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };

  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    return ExecutionStep(
      id: json['id'] as String,
      type: StepType.fromJson((json['type'] as String?) ?? 'plan'),
      status:
          StepStatus.fromJson((json['status'] as String?) ?? 'pending'),
      description: (json['description'] as String?) ?? '',
      agentId: json['agentId'] as String?,
      taskId: json['taskId'] as String?,
      result: json['result'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}

/// The type of an execution step.
enum StepType {
  plan,
  delegate,
  execute,
  review;

  String toJson() => name;

  static StepType fromJson(String value) {
    return StepType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StepType.plan,
    );
  }
}

/// Status of an individual execution step.
enum StepStatus {
  pending,
  inProgress,
  completed,
  failed;

  String toJson() => name;

  static StepStatus fromJson(String value) {
    return StepStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StepStatus.pending,
    );
  }
}