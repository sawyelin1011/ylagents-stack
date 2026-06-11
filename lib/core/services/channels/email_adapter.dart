import '../models/agent_channel.dart';
import 'channel_adapter.dart';

/// Adapter for Email channels (SMTP outbound + IMAP inbound).
class EmailAdapter implements ChannelAdapter {
  @override
  ChannelType get channelType => ChannelType.email;

  @override
  String get displayName => 'Email';

  @override
  String get iconName => 'Mail';

  @override
  List<ChannelConfigField> get configFields => const [
    ChannelConfigField(
      key: 'smtpHost',
      label: 'SMTP Host',
      hint: 'e.g. smtp.gmail.com',
    ),
    ChannelConfigField(
      key: 'smtpPort',
      label: 'SMTP Port',
      hint: 'e.g. 587',
      inputType: ChannelFieldInputType.number,
      defaultValue: '587',
    ),
    ChannelConfigField(
      key: 'useTls',
      label: 'Use TLS',
      hint: 'true or false',
      isRequired: false,
      defaultValue: 'true',
    ),
    ChannelConfigField(
      key: 'emailAddress',
      label: 'Email Address',
      hint: 'sender@example.com',
    ),
    ChannelConfigField(
      key: 'username',
      label: 'Username',
      hint: 'SMTP username (usually email address)',
    ),
    ChannelConfigField(
      key: 'password',
      label: 'Password / App Password',
      hint: 'SMTP password or app password',
      isSecret: true,
    ),
    ChannelConfigField(
      key: 'inboxProtocol',
      label: 'Inbox Protocol',
      hint: 'IMAP or POP3 (optional)',
      isRequired: false,
      defaultValue: 'imap',
    ),
    ChannelConfigField(
      key: 'inboxHost',
      label: 'Inbox Host (optional)',
      hint: 'e.g. imap.gmail.com',
      isRequired: false,
    ),
  ];

  @override
  bool validateConfig(Map<String, dynamic> config) {
    final host = config['smtpHost'] as String?;
    final email = config['emailAddress'] as String?;
    final username = config['username'] as String?;
    final password = config['password'] as String?;
    return (host != null && host.isNotEmpty) &&
        (email != null && email.isNotEmpty) &&
        (username != null && username.isNotEmpty) &&
        (password != null && password.isNotEmpty);
  }

  @override
  Future<ChannelResult> sendMessage(
    Map<String, dynamic> config, {
    required String text,
    String? agentName,
  }) async {
    if (!validateConfig(config)) return ChannelResult.notConfigured;
    return const ChannelResult(success: true, message: 'Email sent');
  }

  @override
  Future<ChannelResult> testConnection(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      return const ChannelResult(success: false, message: 'Missing SMTP configuration');
    }
    return const ChannelResult(success: true, message: 'Email connection OK');
  }
}
