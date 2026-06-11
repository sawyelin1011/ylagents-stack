import 'dart:convert';
import 'workspace_settings.dart';

/// Workspace types in YLAgents.
///
/// [personal] — Personal AI workspace (default)
/// [project] — Project-specific workspace (software, research, etc.)
/// [client] — Client-specific environment
enum WorkspaceType {
  personal,
  project,
  client;

  String toJson() => name;
  static WorkspaceType fromJson(String value) {
    return WorkspaceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkspaceType.personal,
    );
  }
}

/// A workspace is the primary organizational entity in YLAgents.
///
/// Everything belongs to a workspace: tasks, agents, knowledge, chats, MCP profiles.
class Workspace {
  final String id;
  final String name;
  final WorkspaceType type;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Workspace-level settings (default model, MCP bindings, etc.).
  /// Null means no overrides — use global defaults.
  final WorkspaceSettings? settings;

  const Workspace({
    required this.id,
    required this.name,
    this.type = WorkspaceType.personal,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.settings,
  });

  Workspace copyWith({
    String? id,
    String? name,
    WorkspaceType? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    WorkspaceSettings? settings,
    bool clearDescription = false,
    bool clearSettings = false,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: clearDescription ? '' : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: clearSettings ? null : (settings ?? this.settings),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toJson(),
    'description': description,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    if (settings != null) 'settings': settings!.toJson(),
  };

  static Workspace fromJson(Map<String, dynamic> json) => Workspace(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? 'Untitled',
    type: WorkspaceType.fromJson(json['type'] as String? ?? 'personal'),
    description: (json['description'] as String?) ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ?? 0,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num?)?.toInt() ?? 0,
    ),
    settings: json['settings'] != null
        ? WorkspaceSettings.fromJson(json['settings'] as Map<String, dynamic>)
        : null,
  );

  static String encodeList(List<Workspace> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Workspace> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr) Workspace.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <Workspace>[];
    }
  }
}
