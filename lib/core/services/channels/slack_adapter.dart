import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Slack Bot API channels.
///
/// Sends messages via the Slack Web API (chat.postMessage):
/// https://api.slack.com/methods/chat.postMessage
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
    ChannelConfigField(
      key: 'username',
      label: 'Bot Display Name (optional)',
      hint: 'Custom bot name shown in Slack',
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
    final username = config['username'] as String?;

    final blocks = <Map<String, dynamic>>[
      if (agentName != null)
        {
          'type': 'header',
          'text': {'type': 'plain_text', 'text': agentName},
        },
      {
        'type': 'section',
        'text': {'type': 'mrkdwn', 'text': text},
      },
    ];

    final body = <String, dynamic>{
      'channel': channelId,
      'text': agentName != null ? '[$agentName] $text' : text,
      'blocks': blocks,
    };

    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }

    try {
      final response = await http.post(
        Uri.parse('https://slack.com/api/chat.postMessage'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return const ChannelResult(
            success: true,
            message: 'Message sent via Slack',
          );
        }
        return ChannelResult(
          success: false,
          message: 'Slack API error: ${data['error'] ?? 'unknown'}',
        );
      }

      return ChannelResult(
        success: false,
        message: 'Slack API error: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Slack connection failed: $e',
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

    // Test by calling auth.test
    try {
      final response = await http.post(
        Uri.parse('https://slack.com/api/auth.test'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          final botName = data['user'] ?? 'Bot';
          final teamName = data['team'] ?? '';
          return ChannelResult(
            success: true,
            message:
                'Slack bot "$botName" connected${teamName.isNotEmpty ? ' to $teamName' : ''}',
          );
        }
        return ChannelResult(
          success: false,
          message: 'Slack auth failed: ${data['error'] ?? 'unknown'}',
        );
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
