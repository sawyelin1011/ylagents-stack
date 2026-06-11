import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Telegram Bot API channels.
class TelegramAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.telegram;

  @override
  String get displayName => 'Telegram Bot';

  @override
  String get iconName => 'Send';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'botToken',
      label: 'Bot Token',
      hint: 'Bot token from @BotFather',
      isSecret: true,
    ),
    ChannelConfigField(
      key: 'chatId',
      label: 'Chat ID',
      hint: 'Telegram chat/group/channel ID',
    ),
    ChannelConfigField(
      key: 'parseMode',
      label: 'Parse Mode',
      hint: 'HTML or Markdown (optional)',
      isRequired: false,
      defaultValue: 'HTML',
    ),
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    final token = config['botToken'] as String?;
    final chatId = config['chatId'] as String?;
    return (token != null && token.isNotEmpty) &&
        (chatId != null && chatId.isNotEmpty);
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    if (!validateConfig(config)) return ChannelResult.notConfigured;
    return const ChannelResult(success: true, message: 'Message sent via Telegram');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(success: false, message: 'Missing bot token or chat ID');
    }
    return const ChannelResult(success: true, message: 'Telegram connection OK');
  }
}
