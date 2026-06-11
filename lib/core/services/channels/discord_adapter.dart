import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Discord Bot API channels.
///
/// Sends messages via the Discord REST API:
/// https://discord.com/developers/docs/resources/channel#create-message
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
    ChannelConfigField(
      key: 'botName',
      label: 'Bot Username (optional)',
      hint: 'Override bot display name',
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

    final token = config['botToken'] as String;
    final channelId = config['channelId'] as String;

    // Discord has a 2000 character limit per message
    final content = agentName != null ? '**${_escape(agentName)}**\n$text' : text;
    final truncated = content.length > 1990 ? '${content.substring(0, 1990)}...' : content;

    final uri = Uri.parse(
      'https://discord.com/api/v10/channels/$channelId/messages',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bot $token',
        },
        body: jsonEncode({
          'content': truncated,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ChannelResult(
          success: true,
          message: 'Message sent via Discord',
        );
      }

      final errorBody = _parseDiscordError(response.body);
      return ChannelResult(
        success: false,
        message: errorBody ?? 'Discord API error: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Discord connection failed: $e',
      );
    }
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(
        success: false,
        message: 'Missing bot token or channel ID',
      );
    }

    final token = config['botToken'] as String;

    // Test by getting current bot user info
    final uri = Uri.parse('https://discord.com/api/v10/users/@me');
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bot $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final username = data['username'] ?? 'Unknown';
        return ChannelResult(
          success: true,
          message: 'Discord bot "$username" connected OK',
        );
      }

      return ChannelResult(
        success: false,
        message: 'Discord API error: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Connection failed: $e',
      );
    }
  }

  String? _parseDiscordError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Escape Discord markdown special characters in agent name
  String _escape(String text) {
    return text
        .replaceAll('_', '\\_')
        .replaceAll('*', '\\*')
        .replaceAll('~', '\\~')
        .replaceAll('`', '\\`');
  }
}