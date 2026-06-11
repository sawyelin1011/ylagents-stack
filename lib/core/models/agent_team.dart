import 'dart:convert';

/// A team of agents within a workspace.
///
/// A team consists of one Lead Agent and one or more Worker Agents.
/// The Lead Agent plans, delegates, and reviews; Worker Agents execute.
/// Manager Agents (future) can supervise multiple teams.
class AgentTeam {
  final String id;
  final String name;
  final String? description;
  final String workspaceId;

  /// The Lead Agent that orchestrates this team.
  final String leadAgentId;

  /// IDs of Worker Agents that execute tasks.
  final List<String> memberAgentIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentTeam({
    required this.id,
    required this.name,
    this.description,
    required this.workspaceId,
    required this.leadAgentId,
    this.memberAgentIds = const <String>[],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AgentTeam copyWith({
    String? id,
    String? name,
    String? description,
    String? workspaceId,
    String? leadAgentId,
    List<String>? memberAgentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearMemberIds = false,
  }) {
    return AgentTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          clearDescription ? null : (description ?? this.description),
      workspaceId: workspaceId ?? this.workspaceId,
      leadAgentId: leadAgentId ?? this.leadAgentId,
      memberAgentIds:
          clearMemberIds ? const [] : (memberAgentIds ?? this.memberAgentIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'workspaceId': workspaceId,
    'leadAgentId': leadAgentId,
    if (memberAgentIds.isNotEmpty) 'memberAgentIds': memberAgentIds,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory AgentTeam.fromJson(Map<String, dynamic> json) => AgentTeam(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    description: json['description'] as String?,
    workspaceId: json['workspaceId'] as String,
    leadAgentId: json['leadAgentId'] as String,
    memberAgentIds:
        (json['memberAgentIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  static String encodeList(List<AgentTeam> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<AgentTeam> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr)
          AgentTeam.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <AgentTeam>[];
    }
  }
}