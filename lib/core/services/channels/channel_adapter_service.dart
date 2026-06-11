import '../models/agent_channel.dart';
import 'channel_adapter.dart';
import 'telegram_adapter.dart';
import 'discord_adapter.dart';
import 'slack_adapter.dart';
import 'email_adapter.dart';
import 'webhook_adapter.dart';
import 'web_widget_adapter.dart';

/// Registry of all built-in channel adapters.
///
/// Provides lookup by [ChannelType] and a list of all available adapters.
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

  /// Test a channel connection.
  static Future<ChannelResult> testChannel(AgentChannel channel) async {
    final adapter = _adapters[channel.type];
    if (adapter == null) {
      return ChannelResult(success: false, message: 'No adapter for ${channel.type}');
    }
    return adapter.testConnection(channel.config);
  }
}