import 'dart:convert';

/// The execution state of a runtime task or agent.
enum RuntimeExecutionStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  static RuntimeExecutionStatus fromJson(String value) {
    return RuntimeExecutionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RuntimeExecutionStatus.pending,
    );
  }

  String toJson() => name;
}

/// A single runtime execution record.
///
/// Tracks background execution of an agent task: which agent ran,
/// when it ran, how long it took, and the result.
class RuntimeExecution {
  final String id;
  final String agentId;
  final String agentName;
  final String workspaceId;
  final String taskId;
  final String taskTitle;
  final RuntimeExecutionStatus status;
  final String resultSummary;
  final String errorMessage;
  final DateTime startedAt;
  final DateTime? completedAt;

  const RuntimeExecution({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.workspaceId,
    this.taskId = '',
    this.taskTitle = '',
    this.status = RuntimeExecutionStatus.pending,
    this.resultSummary = '',
    this.errorMessage = '',
    required this.startedAt,
    this.completedAt,
  });

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  RuntimeExecution copyWith({
    String? id,
    String? agentId,
    String? agentName,
    String? workspaceId,
    String? taskId,
    String? taskTitle,
    RuntimeExecutionStatus? status,
    String? resultSummary,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return RuntimeExecution(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      workspaceId: workspaceId ?? this.workspaceId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      status: status ?? this.status,
      resultSummary:
          clearResult ? '' : (resultSummary ?? this.resultSummary),
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agentId': agentId,
    'agentName': agentName,
    'workspaceId': workspaceId,
    'taskId': taskId,
    'taskTitle': taskTitle,
    'status': status.toJson(),
    if (resultSummary.isNotEmpty) 'resultSummary': resultSummary,
    if (errorMessage.isNotEmpty) 'errorMessage': errorMessage,
    'startedAt': startedAt.millisecondsSinceEpoch,
    if (completedAt != null)
      'completedAt': completedAt!.millisecondsSinceEpoch,
  };

  factory RuntimeExecution.fromJson(Map<String, dynamic> json) =>
      RuntimeExecution(
        id: json['id'] as String,
        agentId: (json['agentId'] as String?) ?? '',
        agentName: (json['agentName'] as String?) ?? '',
        workspaceId: (json['workspaceId'] as String?) ?? '',
        taskId: (json['taskId'] as String?) ?? '',
        taskTitle: (json['taskTitle'] as String?) ?? '',
        status: RuntimeExecutionStatus.fromJson(
          (json['status'] as String?) ?? '',
        ),
        resultSummary: (json['resultSummary'] as String?) ?? '',
        errorMessage: (json['errorMessage'] as String?) ?? '',
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['startedAt'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch,
        ),
        completedAt: json['completedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
              (json['completedAt'] as num).toInt(),
            )
            : null,
      );

  static String encodeList(List<RuntimeExecution> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<RuntimeExecution> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr)
          RuntimeExecution.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <RuntimeExecution>[];
    }
  }
}