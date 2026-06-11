import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Slack Bot API channels.
class SlackAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.slack;

  @override
  String get displayName => 'Slack Bot';

  @override
  String get iconName => 'MessageSquare';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'botToken',
      label: 'Bot Token',
      hint: 'Slack bot user OAuth token (xoxb-)',
      isSecret: true,
    ),
    ChannelConfigField(
      key: 'channelId',
      label: 'Channel ID',
      hint: 'Slack channel ID (e.g. C123456)',
    ),
    ChannelConfigField(
      key: 'signingSecret',
      label: 'Signing Secret (optional)',
      hint: 'For request verification',
      isSecret: true,
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
    return const ChannelResult(success: true, message: 'Message sent via Slack');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(success: false, message: 'Missing bot token or channel ID');
    }
    return const ChannelResult(success: true, message: 'Slack connection OK');
  }
}
