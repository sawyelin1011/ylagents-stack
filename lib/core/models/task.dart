import 'dart:convert';

/// The lifecycle status of a task.
enum TaskStatus {
  backlog,
  todo,
  inProgress,
  review,
  completed,
  cancelled;

  String toJson() => name;
  static TaskStatus fromJson(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.backlog,
    );
  }
}

/// Priority level for a task.
enum TaskPriority {
  none,
  low,
  medium,
  high,
  urgent;

  String toJson() => name;
  static TaskPriority fromJson(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.none,
    );
  }
}

/// A task in the YLAgents Task System.
///
/// Tasks can be assigned to agents, linked to conversations,
/// and organized by status, priority, and tags.
class Task {
  final String id;
  final String title;
  final String description;
  final String? workspaceId;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeAgentId;
  final String? conversationId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int sortOrder;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.workspaceId,
    this.status = TaskStatus.backlog,
    this.priority = TaskPriority.none,
    this.assigneeAgentId,
    this.conversationId,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const <String>[],
    this.sortOrder = 0,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? workspaceId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeAgentId,
    String? conversationId,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? sortOrder,
    bool clearAssignee = false,
    bool clearConversation = false,
    bool clearDueDate = false,
    bool clearDescription = false,
    bool clearTags = false,
    bool clearWorkspaceId = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? '' : (description ?? this.description),
      workspaceId: clearWorkspaceId ? null : (workspaceId ?? this.workspaceId),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeAgentId: clearAssignee
          ? null
          : (assigneeAgentId ?? this.assigneeAgentId),
      conversationId: clearConversation
          ? null
          : (conversationId ?? this.conversationId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: clearTags ? const <String>[] : (tags ?? this.tags),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description.isNotEmpty) 'description': description,
    if (workspaceId != null) 'workspaceId': workspaceId,
    'status': status.toJson(),
    'priority': priority.toJson(),
    if (assigneeAgentId != null) 'assigneeAgentId': assigneeAgentId,
    if (conversationId != null) 'conversationId': conversationId,
    if (dueDate != null) 'dueDate': dueDate!.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    if (tags.isNotEmpty) 'tags': tags,
    'sortOrder': sortOrder,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: (json['title'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    workspaceId: json['workspaceId'] as String?,
    status: TaskStatus.fromJson((json['status'] as String?) ?? 'backlog'),
    priority: TaskPriority.fromJson((json['priority'] as String?) ?? 'none'),
    assigneeAgentId: json['assigneeAgentId'] as String?,
    conversationId: json['conversationId'] as String?,
    dueDate: json['dueDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['dueDate'] as num).toInt())
        : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const <String>[],
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  );

  static String encodeList(List<Task> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Task> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [for (final e in arr) Task.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return const <Task>[];
    }
  }
}
