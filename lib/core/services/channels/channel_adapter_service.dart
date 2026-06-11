import '../../models/agent_channel.dart';
import 'channel_adapter.dart';
import 'telegram_adapter.dart';
import 'discord_adapter.dart';
import 'slack_adapter.dart';
import 'email_adapter.dart';
import 'webhook_adapter.dart';
import 'web_widget_adapter.dart';

/// Registry of all built-in channel adapters.
///
/// Provides lookup by [ChannelType], a list of all available adapters,
/// and methods to send messages and test connections with real API calls.
class ChannelAdapterService {
  static final Map<ChannelType, ChannelAdapter> _adapters =
      <ChannelType, ChannelAdapter>{
        ChannelType.telegram: TelegramAdapter(),
        ChannelType.discord: DiscordAdapter(),
        ChannelType.slack: SlackAdapter(),
        ChannelType.email: EmailAdapter(),
        ChannelType.webhook: WebhookAdapter(),
        ChannelType.webWidget: WebWidgetAdapter(),
      };

  /// All registered adapters.
  static List<ChannelAdapter> get all => _adapters.values.toList();

  /// Get the adapter for a specific channel type.
  static ChannelAdapter? getAdapter(ChannelType type) => _adapters[type];

  /// Send a message through a channel using its adapter.
  ///
  /// Calls the real external API (Telegram Bot API, Discord REST API,
  /// Slack Web API, SMTP, webhook HTTP POST, or widget backend).
  static Future<ChannelResult> sendMessage(
    AgentChannel channel, {
    required String text,
    String? agentName,
  }) async {
    final adapter = _adapters[channel.type];
    if (adapter == null) {
      return ChannelResult(
        success: false,
        message: 'No adapter for ${channel.type}',
      );
    }
    if (!channel.enabled) {
      return ChannelResult(success: false, message: 'Channel is disabled');
    }
    return adapter.sendMessage(
      channel.config,
      text: text,
      agentName: agentName,
    );
  }

  /// Test a channel connection by actually calling the external API.
  static Future<ChannelResult> testChannel(AgentChannel channel) async {
    final adapter = _adapters[channel.type];
    if (adapter == null) {
      return ChannelResult(
        success: false,
        message: 'No adapter for ${channel.type}',
      );
    }
    return adapter.testConnection(channel.config);
  }

  /// Validate channel configuration without making API calls.
  static bool validateConfig(AgentChannel channel) {
    final adapter = _adapters[channel.type];
    if (adapter == null) return false;
    return adapter.validateConfig(channel.config);
  }
}
