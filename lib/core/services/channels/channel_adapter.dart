import '../../models/agent_channel.dart';

/// Result of a channel send operation.
class ChannelResult {
  final bool success;
  final String? message;

  const ChannelResult({required this.success, this.message});

  static const ok = ChannelResult(success: true);
  static const notConfigured = ChannelResult(
    success: false,
    message: 'Channel not configured',
  );
}

/// Abstract interface for all channel adapters.
///
/// Each adapter implements the protocol-specific logic for connecting
/// to and communicating through an external service.
abstract class ChannelAdapter {
  /// The type of channel this adapter handles.
  ChannelType get channelType;

  /// Human-readable label for this adapter (e.g. "Telegram Bot").
  String get displayName;

  /// Icon name for this adapter (maps to lucide icon names).
  String get iconName;

  /// Validate whether the given config contains all required fields.
  bool validateConfig(Map<String, dynamic> config);

  /// Placeholder: send a message through this channel.
  /// In production, this would call the external service API.
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  });

  /// Placeholder: test the connection with the given config.
  Future<ChannelResult> testConnection(Map<String, dynamic> config);

  /// Return a list of config field definitions for the UI.
  List<ChannelConfigField> get configFields;
}

/// Describes a single config field for the channel settings UI.
class ChannelConfigField {
  final String key;
  final String label;
  final String hint;
  final bool isSecret;
  final bool isRequired;
  final String? defaultValue;
  final ChannelFieldInputType inputType;

  const ChannelConfigField({
    required this.key,
    required this.label,
    this.hint = '',
    this.isSecret = false,
    this.isRequired = true,
    this.defaultValue,
    this.inputType = ChannelFieldInputType.text,
  });
}

/// Keyboard type for config fields.
enum ChannelFieldInputType { text, multiline, number, url }
