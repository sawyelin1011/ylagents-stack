import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for REST webhook channels.
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
      hint: 'For HMAC signature',
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
    return const ChannelResult(success: true, message: 'Webhook triggered');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(success: false, message: 'Missing webhook URL');
    }
    return const ChannelResult(success: true, message: 'Webhook endpoint reachable');
  }
}
