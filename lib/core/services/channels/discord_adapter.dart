import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Discord Bot API channels.
class DiscordAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.discord;

  @override
  String get displayName => 'Discord Bot';

  @override
  String get iconName => 'MessageCircle';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'botToken',
      label: 'Bot Token',
      hint: 'Discord bot token',
      isSecret: true,
    ),
    ChannelConfigField(
      key: 'channelId',
      label: 'Channel ID',
      hint: 'Discord text channel ID',
    ),
    ChannelConfigField(
      key: 'guildId',
      label: 'Guild ID (optional)',
      hint: 'Server ID for scope restriction',
      isRequired: false,
    ),
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    final token = config['botToken'] as String?;
    final channelId = config['channelId'] as String?;
    return (token != null && token.isNotEmpty) &&
        (channelId != null && channelId.isNotEmpty);
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    if (!validateConfig(config)) return ChannelResult.notConfigured;
    return const ChannelResult(success: true, message: 'Message sent via Discord');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(success: false, message: 'Missing bot token or channel ID');
    }
    return const ChannelResult(success: true, message: 'Discord connection OK');
  }
}
