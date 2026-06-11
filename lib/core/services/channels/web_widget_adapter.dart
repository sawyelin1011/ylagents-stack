import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for embeddable web widget channels.
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
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    return true;
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    return const ChannelResult(success: true, message: 'Web widget message processed');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    return const ChannelResult(success: true, message: 'Web widget is ready');
  }
}
