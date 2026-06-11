import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Telegram Bot API channels.
///
/// Sends messages via the Telegram Bot API:
/// https://core.telegram.org/bots/api#sendmessage
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
    ChannelConfigField(
      key: 'disableNotification',
      label: 'Disable Notification',
      hint: 'true or false (optional)',
      isRequired: false,
      defaultValue: 'false',
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

    final token = config['botToken'] as String;
    final chatId = config['chatId'] as String;
    final parseMode = (config['parseMode'] as String?) ?? 'HTML';
    final disableNotification =
        (config['disableNotification'] as String?) == 'true';

    final uri = Uri.parse('https://api.telegram.org/bot$token/sendMessage');
    final body = <String, dynamic>{
      'chat_id': chatId,
      'text': agentName != null ? '[$agentName]\n$text' : text,
      'parse_mode': parseMode,
      'disable_notification': disableNotification,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return const ChannelResult(
            success: true,
            message: 'Message sent via Telegram',
          );
        }
        return ChannelResult(
          success: false,
          message: 'Telegram API error: ${data['description'] ?? 'unknown'}',
        );
      }

      return ChannelResult(
        success: false,
        message: 'Telegram API error: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Telegram connection failed: $e',
      );
    }
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(
        success: false,
        message: 'Missing bot token or chat ID',
      );
    }

    final token = config['botToken'] as String;

    // Test by calling getMe API
    final uri = Uri.parse('https://api.telegram.org/bot$token/getMe');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          final bot = data['result'] as Map<String, dynamic>;
          final botName = bot['first_name'] ?? 'Unknown';
          return ChannelResult(
            success: true,
            message: 'Telegram bot "$botName" connected OK',
          );
        }
        return ChannelResult(success: false, message: 'Invalid bot token');
      }
      return ChannelResult(
        success: false,
        message: 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(success: false, message: 'Connection failed: $e');
    }
  }
}
