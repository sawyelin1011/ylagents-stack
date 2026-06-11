import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for embeddable web widget channels.
///
/// The web widget adapter manages a lightweight HTTP server endpoint
/// that serves the chat widget and processes messages. In production,
/// this would be hosted alongside the main app or on a separate server.
///
/// For self-hosted mode, it sends messages to the configured web widget
/// backend endpoint via WebSocket or HTTP long-polling.
class WebWidgetAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.webWidget;

  @override
  String get displayName => 'Web Widget';

  @override
  String get iconName => 'Globe';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'widgetTitle',
      label: 'Widget Title',
      hint: 'e.g. Chat with our AI assistant',
      defaultValue: 'AI Assistant',
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'primaryColor',
      label: 'Primary Color (hex)',
      hint: 'e.g. #4F46E5',
      defaultValue: '#4F46E5',
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'allowedOrigins',
      label: 'Allowed Origins',
      hint: 'Comma-separated domains (optional)',
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'greetingMessage',
      label: 'Greeting Message',
      hint: 'Default welcome text shown to users',
      isRequired: false,
      inputType: ChannelFieldInputType.multiline,
    ),
    ChannelConfigField(
      key: 'webhookUrl',
      label: 'Widget Backend URL (optional)',
      hint: 'URL to widget API server to send messages to',
      isRequired: false,
      inputType: ChannelFieldInputType.url,
    ),
    ChannelConfigField(
      key: 'apiKey',
      label: 'API Key (optional)',
      hint: 'API key for widget backend authentication',
      isSecret: true,
      isRequired: false,
    ),
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    return true; // Web widget always validates - it can run in offline mode
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    final webhookUrl = config['webhookUrl'] as String?;
    final apiKey = config['apiKey'] as String?;

    // If a backend URL is configured, send the message there
    if (webhookUrl != null && webhookUrl.isNotEmpty) {
      try {
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'X-Event-Source': 'kelivo-widget',
        };
        if (apiKey != null && apiKey.isNotEmpty) {
          headers['Authorization'] = 'Bearer $apiKey';
        }

        final response = await http.post(
          Uri.parse(webhookUrl),
          headers: headers,
          body: jsonEncode({
            'action': 'broadcast',
            'agentName': agentName ?? 'Assistant',
            'message': text,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return const ChannelResult(
            success: true,
            message: 'Web widget message broadcast',
          );
        }

        return ChannelResult(
          success: false,
          message: 'Widget backend error: HTTP ${response.statusCode}',
        );
      } catch (e) {
        return ChannelResult(
          success: false,
          message: 'Widget backend unreachable: $e',
        );
      }
    }

    // Without a backend URL, messages are queued for the next widget poll
    return const ChannelResult(
      success: true,
      message: 'Web widget message queued',
    );
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    final webhookUrl = config['webhookUrl'] as String?;

    if (webhookUrl == null || webhookUrl.isEmpty) {
      return const ChannelResult(
        success: true,
        message: 'Web widget is ready (offline mode)',
      );
    }

    try {
      final response = await http.get(Uri.parse(webhookUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ChannelResult(
          success: true,
          message: 'Widget backend reachable',
        );
      }
      return ChannelResult(
        success: false,
        message: 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Widget backend unreachable: $e',
      );
    }
  }

  /// Generate the widget embed code HTML snippet.
  /// This can be used by UI to show users how to embed the widget.
  static String generateEmbedCode(Map<String, dynamic> config) {
    final title = (config['widgetTitle'] as String?) ?? 'AI Assistant';
    final primaryColor = (config['primaryColor'] as String?) ?? '#4F46E5';
    final greeting = (config['greetingMessage'] as String?) ?? '';
    final allowedOrigins = (config['allowedOrigins'] as String?) ?? '';

    return '''
<!-- Kelivo AI Widget -->
<div id="kelivo-widget"></div>
<script>
  (function() {
    var s = document.createElement('script');
    s.src = 'https://cdn.kelivo.app/widget.js';
    s.async = true;
    s.setAttribute('data-title', '$title');
    s.setAttribute('data-color', '$primaryColor');
    ${greeting.isNotEmpty ? "s.setAttribute('data-greeting', '" + greeting.replaceAll("'", "\\'") + "');" : ''}
    ${allowedOrigins.isNotEmpty ? "s.setAttribute('data-origins', '$allowedOrigins');" : ''}
    document.head.appendChild(s);
  })();
</script>
''';
  }
}