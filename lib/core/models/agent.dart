import 'dart:convert';
import 'agent_genome.dart';

/// Agent types in the YLAgents workforce system.
///
/// [standard] — General-purpose agent for chat and simple tasks
/// [lead] — Lead agent: plans, delegates, reviews work from worker agents
/// [worker] — Worker agent: executes tasks assigned by a lead agent
enum AgentType {
  standard,
  lead,
  worker;

  String toJson() => name;
  static AgentType fromJson(String value) {
    return AgentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AgentType.standard,
    );
  }
}

/// An Agent wraps an Assistant with genome-level identity data.
///
/// In YLAgents, every [Assistant] can be promoted to an Agent by adding
/// genome data. The agent shares the same [id] as its underlying Assistant,
/// and the genome is stored separately from the Assistant's chat/tool config.
///
/// This allows the existing chat system to continue working with Assistants
/// while the agent system layers Identity, Soul, Role, Goals on top.
class Agent {
  /// The ID of the underlying [Assistant]. Must match exactly.
  final String id;

  /// The display name (mirrored from Assistant for quick access).
  final String name;

  /// The agent type in the workforce hierarchy.
  final AgentType type;

  /// The agent's genome — identity, soul, role, goals.
  final AgentGenome genome;

  /// Whether this agent is enabled/active.
  final bool enabled;

  const Agent({
    required this.id,
    required this.name,
    this.type = AgentType.standard,
    this.genome = AgentGenome.empty,
    this.enabled = true,
  });

  Agent copyWith({
    String? id,
    String? name,
    AgentType? type,
    AgentGenome? genome,
    bool? enabled,
    bool clearGenome = false,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      genome: clearGenome ? AgentGenome.empty : (genome ?? this.genome),
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toJson(),
    'genome': genome.toJson(),
    'enabled': enabled,
  };

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    type: AgentType.fromJson((json['type'] as String?) ?? 'standard'),
    genome: json['genome'] != null
        ? AgentGenome.fromJson(json['genome'] as Map<String, dynamic>)
        : AgentGenome.empty,
    enabled: json['enabled'] as bool? ?? true,
  );

  static String encodeList(List<Agent> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Agent> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [for (final e in arr) Agent.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return const <Agent>[];
    }
  }
}
