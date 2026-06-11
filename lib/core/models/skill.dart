import 'dart:convert';

/// A reusable capability package that can be installed in a workspace.
///
/// Skills bundle prompts, workflows, configurations, and tool references
/// into a portable unit. Examples: Research, Code Review, Customer Support.
class Skill {
  final String id;
  final String name;
  final String description;
  final String version;
  final String? author;
  final List<String> tags;
  final SkillInstallSource source;
  final String? sourceUrl;
  final SkillContent content;
  final DateTime installedAt;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    this.version = '1.0.0',
    this.author,
    this.tags = const [],
    this.source = SkillInstallSource.local,
    this.sourceUrl,
    required this.content,
    DateTime? installedAt,
  }) : installedAt = installedAt ?? DateTime.now();

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? author,
    List<String>? tags,
    SkillInstallSource? source,
    String? sourceUrl,
    SkillContent? content,
    DateTime? installedAt,
    bool clearAuthor = false,
    bool clearSourceUrl = false,
    bool clearTags = false,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      author: clearAuthor ? null : (author ?? this.author),
      tags: clearTags ? const [] : (tags ?? this.tags),
      source: source ?? this.source,
      sourceUrl: clearSourceUrl ? null : (sourceUrl ?? this.sourceUrl),
      content: content ?? this.content,
      installedAt: installedAt ?? this.installedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'version': version,
    if (author != null) 'author': author,
    if (tags.isNotEmpty) 'tags': tags,
    'source': source.toJson(),
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
    'content': content.toJson(),
    'installedAt': installedAt.millisecondsSinceEpoch,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    version: (json['version'] as String?) ?? '1.0.0',
    author: json['author'] as String?,
    tags: (json['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    source: SkillInstallSource.fromJson(
      (json['source'] as String?) ?? 'local',
    ),
    sourceUrl: json['sourceUrl'] as String?,
    content: json['content'] != null
        ? SkillContent.fromJson(json['content'] as Map<String, dynamic>)
        : SkillContent.empty(),
    installedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['installedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  static String encodeList(List<Skill> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Skill> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [for (final e in arr) Skill.fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return const <Skill>[];
    }
  }
}

/// How a skill was installed.
enum SkillInstallSource {
  local,
  marketplace,
  git;

  String toJson() => name;
  static SkillInstallSource fromJson(String value) {
    return SkillInstallSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillInstallSource.local,
    );
  }
}

/// The content bundle inside a skill — prompts, workflows, config, tool refs.
class SkillContent {
  final List<SkillPrompt> prompts;
  final List<SkillWorkflow> workflows;
  final Map<String, dynamic> config;
  final List<String> requiredMcpTools;
  final List<String> knowledgeLinks;

  const SkillContent({
    this.prompts = const [],
    this.workflows = const [],
    this.config = const {},
    this.requiredMcpTools = const [],
    this.knowledgeLinks = const [],
  });

  const SkillContent.empty()
      : prompts = const [],
        workflows = const [],
        config = const {},
        requiredMcpTools = const [],
        knowledgeLinks = const [];

  bool get isEmpty =>
      prompts.isEmpty &&
      workflows.isEmpty &&
      config.isEmpty &&
      requiredMcpTools.isEmpty &&
      knowledgeLinks.isEmpty;

  Map<String, dynamic> toJson() => {
    if (prompts.isNotEmpty)
      'prompts': prompts.map((p) => p.toJson()).toList(),
    if (workflows.isNotEmpty)
      'workflows': workflows.map((w) => w.toJson()).toList(),
    if (config.isNotEmpty) 'config': config,
    if (requiredMcpTools.isNotEmpty) 'requiredMcpTools': requiredMcpTools,
    if (knowledgeLinks.isNotEmpty) 'knowledgeLinks': knowledgeLinks,
  };

  factory SkillContent.fromJson(Map<String, dynamic> json) => SkillContent(
    prompts: (json['prompts'] as List<dynamic>?)
            ?.map((e) => SkillPrompt.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    workflows: (json['workflows'] as List<dynamic>?)
            ?.map((e) => SkillWorkflow.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
    requiredMcpTools:
        (json['requiredMcpTools'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
    knowledgeLinks:
        (json['knowledgeLinks'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
  );
}

/// A reusable prompt template within a skill.
class SkillPrompt {
  final String id;
  final String name;
  final String text;
  final String? role;

  const SkillPrompt({
    required this.id,
    required this.name,
    required this.text,
    this.role,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'text': text,
    if (role != null) 'role': role,
  };

  factory SkillPrompt.fromJson(Map<String, dynamic> json) => SkillPrompt(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    text: (json['text'] as String?) ?? '',
    role: json['role'] as String?,
  );
}

/// A reusable workflow definition within a skill.
class SkillWorkflow {
  final String id;
  final String name;
  final String description;
  final List<String> steps;

  const SkillWorkflow({
    required this.id,
    required this.name,
    this.description = '',
    this.steps = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description.isNotEmpty) 'description': description,
    if (steps.isNotEmpty) 'steps': steps,
  };

  factory SkillWorkflow.fromJson(Map<String, dynamic> json) => SkillWorkflow(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
  );
}