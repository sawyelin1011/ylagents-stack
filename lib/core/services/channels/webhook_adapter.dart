import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for REST webhook channels.
///
/// Sends HTTP POST/PUT requests to a configured webhook URL.
/// Supports custom JSON templates, HMAC signing, and various content types.
class WebhookAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.webhook;

  @override
  String get displayName => 'Webhook';

  @override
  String get iconName => 'Webhook';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'webhookUrl',
      label: 'Webhook URL',
      hint: 'https://hooks.example.com/...',
      inputType: ChannelFieldInputType.url,
    ),
    ChannelConfigField(
      key: 'method',
      label: 'HTTP Method',
      hint: 'POST or PUT',
      defaultValue: 'POST',
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'contentType',
      label: 'Content Type',
      hint: 'application/json (default)',
      defaultValue: 'application/json',
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'secretToken',
      label: 'Secret Token (optional)',
      hint: 'For HMAC-SHA256 signature',
      isSecret: true,
      isRequired: false,
    ),
    ChannelConfigField(
      key: 'customTemplate',
      label: 'Custom JSON Template (optional)',
      hint: '{"text": "{{message}}"}',
      isRequired: false,
      inputType: ChannelFieldInputType.multiline,
    ),
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    final url = config['webhookUrl'] as String?;
    return url != null && url.isNotEmpty;
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    if (!validateConfig(config)) return ChannelResult.notConfigured;

    final url = config['webhookUrl'] as String;
    final method = (config['method'] as String?)?.toUpperCase() ?? 'POST';
    final contentType =
        (config['contentType'] as String?) ?? 'application/json';
    final secretToken = config['secretToken'] as String?;
    final customTemplate = config['customTemplate'] as String?;

    // Build the payload
    String body;
    Map<String, String> headers = {'Content-Type': contentType};

    if (customTemplate != null && customTemplate.isNotEmpty) {
      // Apply template with variable substitution
      body = _applyTemplate(customTemplate, text, agentName: agentName);
    } else {
      // Default JSON payload
      final payload = <String, dynamic>{
        'text': text,
        'agent': agentName ?? 'Kelivo',
        'timestamp': DateTime.now().toIso8601String(),
      };
      body = jsonEncode(payload);
    }

    // Apply HMAC signing if secret token is provided
    if (secretToken != null && secretToken.isNotEmpty) {
      final hmacSha256 = Hmac(sha256, utf8.encode(secretToken));
      final digest = hmacSha256.convert(utf8.encode(body));
      headers['X-Signature-256'] = digest.toString();
      headers['X-Signature-256-Hex'] = digest.toString();
    }

    headers['X-Agent-Name'] = agentName ?? 'Kelivo';
    headers['X-Event-Source'] = 'kelivo';

    try {
      http.Response response;

      if (method == 'PUT') {
        response = await http.put(Uri.parse(url), headers: headers, body: body);
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ChannelResult(
          success: true,
          message: 'Webhook triggered (HTTP ${response.statusCode})',
        );
      }

      // Try to extract error from response body
      String? errorMsg;
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        errorMsg = data['error']?.toString() ?? data['message']?.toString();
      } catch (_) {}

      return ChannelResult(
        success: false,
        message: errorMsg ?? 'Webhook failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return ChannelResult(
        success: false,
        message: 'Webhook request failed: $e',
      );
    }
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(
        success: false,
        message: 'Missing webhook URL',
      );
    }

    final url = config['webhookUrl'] as String;
    final secretToken = config['secretToken'] as String?;

    // Send a lightweight test ping
    final payload = jsonEncode({
      'ping': true,
      'timestamp': DateTime.now().toIso8601String(),
      'source': 'kelivo',
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Ping': 'true',
      'X-Event-Source': 'kelivo',
    };

    if (secretToken != null && secretToken.isNotEmpty) {
      final hmacSha256 = Hmac(sha256, utf8.encode(secretToken));
      final digest = hmacSha256.convert(utf8.encode(payload));
      headers['X-Signature-256'] = digest.toString();
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ChannelResult(
          success: true,
          message: 'Webhook endpoint reachable',
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

  /// Apply template with variable substitution.
  /// Supports: {{message}}, {{agentName}}, {{timestamp}}, {{random}}
  String _applyTemplate(String template, String message, {String? agentName}) {
    var result = template;
    result = result.replaceAll('{{message}}', message);
    result = result.replaceAll('{{agentName}}', agentName ?? 'Kelivo');
    result = result.replaceAll(
      '{{timestamp}}',
      DateTime.now().toIso8601String(),
    );

    // Replace {{random}} with a random integer
    final random = Random();
    result = result.replaceAll(
      '{{random}}',
      random.nextInt(1000000).toString(),
    );

    return result;
  }
}
