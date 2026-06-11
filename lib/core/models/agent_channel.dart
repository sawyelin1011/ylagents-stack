import 'dart:convert';

/// The type of external channel an agent can connect to.
enum ChannelType {
  telegram,
  discord,
  slack,
  email,
  webhook,
  webWidget;

  static ChannelType fromJson(String value) {
    return ChannelType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChannelType.telegram,
    );
  }

  String toJson() => name;
}

/// Configuration for a channel binding an agent to an external service.
///
/// Each channel stores its type-specific config as a JSON-encoded string
/// so the model stays flexible without tight coupling to adapter internals.
class AgentChannel {
  final String id;
  final String name;
  final String agentId;
  final String workspaceId;
  final ChannelType type;

  /// Type-specific configuration as a JSON string.
  /// e.g. Telegram: {"botToken":"xxx","chatId":"xxx"}
  /// e.g. Email: {"smtpHost":"...","smtpPort":587,"username":"...","password":"...","inboxProtocol":"imap"}
  final String configJson;

  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentChannel({
    required this.id,
    required this.name,
    required this.agentId,
    required this.workspaceId,
    required this.type,
    this.configJson = '{}',
    this.enabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Parsed config as a mutable map for convenience.
  Map<String, dynamic> get config {
    try {
      return jsonDecode(configJson) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  AgentChannel copyWith({
    String? id,
    String? name,
    String? agentId,
    String? workspaceId,
    ChannelType? type,
    String? configJson,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearName = false,
    bool clearConfig = false,
  }) {
    return AgentChannel(
      id: id ?? this.id,
      name: clearName ? '' : (name ?? this.name),
      agentId: agentId ?? this.agentId,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      configJson: clearConfig ? '{}' : (configJson ?? this.configJson),
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'agentId': agentId,
    'workspaceId': workspaceId,
    'type': type.toJson(),
    if (configJson != '{}') 'configJson': configJson,
    'enabled': enabled,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory AgentChannel.fromJson(Map<String, dynamic> json) => AgentChannel(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    agentId: (json['agentId'] as String?) ?? '',
    workspaceId: (json['workspaceId'] as String?) ?? '',
    type: ChannelType.fromJson((json['type'] as String?) ?? ''),
    configJson: (json['configJson'] as String?) ?? '{}',
    enabled: (json['enabled'] as bool?) ?? true,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  static String encodeList(List<AgentChannel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<AgentChannel> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr)
          AgentChannel.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <AgentChannel>[];
    }
  }
}
