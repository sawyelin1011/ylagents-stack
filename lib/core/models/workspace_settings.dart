/// Per-workspace settings that override global defaults.
///
/// Each workspace can configure its own:
///   - default assistant
///   - default model provider/model
///   - MCP server bindings
///   - enabled local tools
///
/// Null fields mean "use global default" from [SettingsProvider].
class WorkspaceSettings {
  /// The default assistant ID to use when this workspace is active.
  final String? defaultAssistantId;

  /// Default model provider for this workspace.
  final String? defaultModelProvider;

  /// Default model ID for this workspace.
  final String? defaultModelId;

  /// MCP server IDs enabled for this workspace.
  final List<String> mcpServerIds;

  /// Local tool IDs enabled for this workspace.
  final List<String> localToolIds;

  const WorkspaceSettings({
    this.defaultAssistantId,
    this.defaultModelProvider,
    this.defaultModelId,
    this.mcpServerIds = const <String>[],
    this.localToolIds = const <String>[],
  });

  WorkspaceSettings copyWith({
    String? defaultAssistantId,
    String? defaultModelProvider,
    String? defaultModelId,
    List<String>? mcpServerIds,
    List<String>? localToolIds,
    bool clearDefaultAssistantId = false,
    bool clearDefaultModelProvider = false,
    bool clearDefaultModelId = false,
  }) {
    return WorkspaceSettings(
      defaultAssistantId: clearDefaultAssistantId
          ? null
          : (defaultAssistantId ?? this.defaultAssistantId),
      defaultModelProvider: clearDefaultModelProvider
          ? null
          : (defaultModelProvider ?? this.defaultModelProvider),
      defaultModelId: clearDefaultModelId
          ? null
          : (defaultModelId ?? this.defaultModelId),
      mcpServerIds: mcpServerIds ?? this.mcpServerIds,
      localToolIds: localToolIds ?? this.localToolIds,
    );
  }

  Map<String, dynamic> toJson() => {
    if (defaultAssistantId != null) 'defaultAssistantId': defaultAssistantId,
    if (defaultModelProvider != null)
      'defaultModelProvider': defaultModelProvider,
    if (defaultModelId != null) 'defaultModelId': defaultModelId,
    if (mcpServerIds.isNotEmpty) 'mcpServerIds': mcpServerIds,
    if (localToolIds.isNotEmpty) 'localToolIds': localToolIds,
  };

  static WorkspaceSettings fromJson(Map<String, dynamic> json) =>
      WorkspaceSettings(
        defaultAssistantId: json['defaultAssistantId'] as String?,
        defaultModelProvider: json['defaultModelProvider'] as String?,
        defaultModelId: json['defaultModelId'] as String?,
        mcpServerIds:
            (json['mcpServerIds'] as List?)?.cast<String>() ?? const <String>[],
        localToolIds:
            (json['localToolIds'] as List?)?.cast<String>() ?? const <String>[],
      );

  static const WorkspaceSettings empty = WorkspaceSettings();
}
