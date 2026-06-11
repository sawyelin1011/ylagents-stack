import 'channel_adapter.dart';
import 'telegram_adapter.dart';
import 'discord_adapter.dart';
import 'slack_adapter.dart';
import 'email_adapter.dart';
import 'webhook_adapter.dart';
import 'web_widget_adapter.dart';
import '../../models/agent_channel.dart';

/// Registry of all available channel adapters.
///
/// Provides lookup by [ChannelType] and a list of all adapters
/// for UI display (e.g. showing available channel types when creating).
class ChannelRegistry {
  static final List<ChannelAdapter> _adapters = [
    TelegramAdapter(),
    DiscordAdapter(),
    SlackAdapter(),
    EmailAdapter(),
    WebhookAdapter(),
    WebWidgetAdapter(),
  ];

  /// All registered adapters.
  static List<ChannelAdapter> get all => List.unmodifiable(_adapters);

  /// Get an adapter by channel type.
  static ChannelAdapter? getAdapter(ChannelType type) {
    final idx = _adapters.indexWhere((a) => a.channelType == type);
    if (idx == -1) return null;
    return _adapters[idx];
  }

  /// Get display-friendly label for a channel type.
  static String displayNameFor(ChannelType type) {
    return getAdapter(type)?.displayName ?? type.name;
  }

  /// Get icon name for a channel type.
  static String iconNameFor(ChannelType type) {
    return getAdapter(type)?.iconName ?? 'Plug';
  }
}
