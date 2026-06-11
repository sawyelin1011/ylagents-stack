import 'agent.dart';
import 'agent_genome.dart';

/// A pre-defined template for creating agents quickly.
///
/// Templates provide default values for [AgentType], identity fields,
/// goals, and a description/purpose statement.
///
/// Built-in templates (General Assistant, Code Helper, Writer, Researcher)
/// ship with the app. Users can also save custom templates in the future.
class AgentTemplate {
  /// Unique identifier for this template.
  final String id;

  /// Display name shown in the template picker.
  final String name;

  /// Short description of what this template is for.
  final String description;

  /// Icon identifier (maps to lucide icon names).
  final String iconName;

  /// The agent type this template creates.
  final AgentType agentType;

  /// Pre-filled genome data.
  final AgentGenome genome;

  /// Suggested system prompt instructions (used when promoting).
  final String suggestedSystemPrompt;

  const AgentTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'Bot',
    this.agentType = AgentType.standard,
    this.genome = AgentGenome.empty,
    this.suggestedSystemPrompt = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconName': iconName,
    'agentType': agentType.toJson(),
    'genome': genome.toJson(),
    if (suggestedSystemPrompt.isNotEmpty)
      'suggestedSystemPrompt': suggestedSystemPrompt,
  };

  factory AgentTemplate.fromJson(Map<String, dynamic> json) => AgentTemplate(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    iconName: (json['iconName'] as String?) ?? 'Bot',
    agentType:
        AgentType.fromJson((json['agentType'] as String?) ?? 'standard'),
    genome: json['genome'] != null
        ? AgentGenome.fromJson(json['genome'] as Map<String, dynamic>)
        : AgentGenome.empty,
    suggestedSystemPrompt:
        (json['suggestedSystemPrompt'] as String?) ?? '',
  );
}