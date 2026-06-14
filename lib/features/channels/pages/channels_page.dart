import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/agent_channel.dart';
import '../../../core/providers/channel_provider.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/services/channels/channel_adapter.dart';
import '../../../core/services/channels/channel_registry.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Channels management page — configure external channel integrations.
class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final channelProvider = context.watch<ChannelProvider>();
    final workspaceProvider = context.watch<WorkspaceProvider>();
    final workspaceId = workspaceProvider.currentWorkspace?.id;
    final channels = workspaceId != null
        ? channelProvider.getChannelsForWorkspace(workspaceId)
        : <AgentChannel>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.cable, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.channelsPageTitle),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              icon: const Icon(lucide.Lucide.plus, size: 14),
              label: Text(l10n.channelsPageAddChannel),
              onPressed: () => _showCreateDialog(context, l10n, cs),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: channels.isEmpty
          ? _buildEmptyState(l10n, cs)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: channels.length,
              itemBuilder: (context, index) =>
                  _ChannelCard(channel: channels[index]),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            lucide.Lucide.cable,
            size: 56,
            color: cs.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.channelsPageEmpty,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.4),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.channelsPageEmptyHint,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final adapters = ChannelRegistry.all;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.channelsPageSelectType),
        content: SizedBox(
          width: 360,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: adapters.length,
            itemBuilder: (context, index) {
              final adapter = adapters[index];
              return ListTile(
                leading: _channelTypeIcon(adapter.channelType, cs),
                title: Text(adapter.displayName),
                subtitle: Text(
                  _channelTypeDesc(adapter.channelType, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showConfigDialog(context, l10n, cs, adapter.channelType);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.channelsPageCancel),
          ),
        ],
      ),
    );
  }

  void _showConfigDialog(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
    ChannelType type,
  ) {
    final adapter = ChannelRegistry.getAdapter(type);
    if (adapter == null) return;

    final nameController = TextEditingController();
    final configControllers = <String, TextEditingController>{};

    for (final field in adapter.configFields) {
      configControllers[field.key] = TextEditingController(
        text: field.defaultValue ?? '',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text('${l10n.channelsPageConfigure} ${adapter.displayName}'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.channelsPageNameLabel,
                        hintText: l10n.channelsPageNameHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...adapter.configFields.map((field) {
                      final ctrl = configControllers[field.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: ctrl,
                          obscureText: field.isSecret,
                          maxLines:
                              field.inputType == ChannelFieldInputType.multiline
                              ? 4
                              : 1,
                          keyboardType: _flutterKeyboardType(field.inputType),
                          decoration: InputDecoration(
                            labelText: field.label,
                            hintText: field.hint,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.channelsPageCancel),
              ),
              TextButton(
                onPressed: () async {
                  final config = <String, dynamic>{};
                  for (final field in adapter.configFields) {
                    final val = configControllers[field.key]?.text ?? '';
                    if (val.isNotEmpty) config[field.key] = val;
                  }
                  final testResult = await adapter.testConnection(config);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          testResult.success
                              ? '${adapter.displayName}: ${testResult.message}'
                              : '${l10n.channelsPageTestFailed}: ${testResult.message}',
                        ),
                      ),
                    );
                  }
                },
                child: Text(l10n.channelsPageTest),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final wsProvider = context.read<WorkspaceProvider>();
                  final wsId = wsProvider.currentWorkspace?.id ?? '';
                  final agentProvider = context.read<AgentProvider>();
                  final agents = agentProvider.getAgentsForWorkspace(wsId);

                  final config = <String, dynamic>{};
                  for (final field in adapter.configFields) {
                    final val = configControllers[field.key]?.text ?? '';
                    if (val.isNotEmpty) config[field.key] = val;
                  }

                  String? selectedAgentId;
                  if (agents.length == 1) {
                    selectedAgentId = agents.first.id;
                  }

                  if (selectedAgentId == null && agents.length > 1) {
                    selectedAgentId = await showDialog<String>(
                      context: ctx,
                      builder: (ac) => SimpleDialog(
                        title: Text(l10n.channelsPageBindAgent),
                        children: agents.map((a) {
                          return SimpleDialogOption(
                            onPressed: () => Navigator.pop(ac, a.id),
                            child: Text(a.name),
                          );
                        }).toList(),
                      ),
                    );
                    if (selectedAgentId == null) return;
                  }

                  final channel = AgentChannel(
                    id: '${DateTime.now().millisecondsSinceEpoch}_${type.name}',
                    name: name,
                    agentId: selectedAgentId ?? '',
                    workspaceId: wsId,
                    type: type,
                    configJson: _encodeConfig(config),
                  );
                  // ignore: use_build_context_synchronously
                  final created = await context
                      .read<ChannelProvider>()
                      .createChannel(channel);
                  if (ctx.mounted) {
                    if (created) {
                      Navigator.pop(ctx);
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.channelsPageDuplicate,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(l10n.channelsPageCreate),
              ),
            ],
          );
        },
      ),
    );
  }

  String _encodeConfig(Map<String, dynamic> config) {
    try {
      return const JsonEncoder.withIndent(null).convert(config);
    } catch (_) {
      return '{}';
    }
  }

  TextInputType _flutterKeyboardType(ChannelFieldInputType type) {
    switch (type) {
      case ChannelFieldInputType.number:
        return TextInputType.number;
      case ChannelFieldInputType.url:
        return TextInputType.url;
      case ChannelFieldInputType.multiline:
        return TextInputType.multiline;
      case ChannelFieldInputType.text:
        return TextInputType.text;
    }
  }

  Widget _channelTypeIcon(ChannelType type, ColorScheme cs) {
    final iconName = ChannelRegistry.iconNameFor(type);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _iconForName(iconName),
        size: 18,
        color: cs.onPrimaryContainer,
      ),
    );
  }

  String _channelTypeDesc(ChannelType type, AppLocalizations l10n) {
    switch (type) {
      case ChannelType.telegram:
        return l10n.channelsTypeTelegramDesc;
      case ChannelType.discord:
        return l10n.channelsTypeDiscordDesc;
      case ChannelType.slack:
        return l10n.channelsTypeSlackDesc;
      case ChannelType.email:
        return l10n.channelsTypeEmailDesc;
      case ChannelType.webhook:
        return l10n.channelsTypeWebhookDesc;
      case ChannelType.webWidget:
        return l10n.channelsTypeWebWidgetDesc;
    }
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'Send':
        return lucide.Lucide.send;
      case 'MessageCircle':
        return lucide.Lucide.messageCircle;
      case 'MessageSquare':
        return lucide.Lucide.messageSquare;
      case 'Mail':
        return lucide.Lucide.mail;
      case 'Webhook':
        return lucide.Lucide.webhook;
      case 'Globe':
        return lucide.Lucide.globe;
      default:
        return lucide.Lucide.plug;
    }
  }
}

/// A card showing a configured channel with status and actions.
class _ChannelCard extends StatelessWidget {
  final AgentChannel channel;

  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final adapter = ChannelRegistry.getAdapter(channel.type);
    final agentProvider = context.watch<AgentProvider>();
    final agent = agentProvider.getById(channel.agentId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: channel.enabled
                        ? cs.primaryContainer
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconForType(channel.type),
                    size: 18,
                    color: channel.enabled
                        ? cs.onPrimaryContainer
                        : cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: AppFontWeights.semibold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        adapter?.displayName ?? channel.type.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: channel.enabled
                        ? Colors.green.withValues(alpha: 0.1)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    channel.enabled
                        ? l10n.channelsStatusEnabled
                        : l10n.channelsPageDisabled,
                    style: TextStyle(
                      fontSize: 11,
                      color: channel.enabled
                          ? Colors.green
                          : cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    lucide.Lucide.moreVertical,
                    size: 16,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                  onSelected: (value) async {
                    if (value == 'toggle') {
                      await context.read<ChannelProvider>().toggleEnabled(
                        channel.id,
                      );
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.channelsPageDeleteConfirmTitle),
                          content: Text(l10n.channelsPageDeleteConfirmContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.channelsPageCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                l10n.channelsPageDelete,
                                style: TextStyle(color: cs.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await context.read<ChannelProvider>().deleteChannel(
                          channel.id,
                        );
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            channel.enabled
                                ? lucide.Lucide.toggleLeft
                                : lucide.Lucide.toggleRight,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            channel.enabled
                                ? l10n.channelsDisable
                                : l10n.channelsEnable,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(lucide.Lucide.trash, size: 14, color: cs.error),
                          const SizedBox(width: 8),
                          Text(
                            l10n.channelsPageDelete,
                            style: TextStyle(color: cs.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (agent != null)
              Row(
                children: [
                  Icon(
                    lucide.Lucide.bot,
                    size: 12,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.channelsPageBoundTo} ${agent.name}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(ChannelType type) {
    final iconName = ChannelRegistry.iconNameFor(type);
    switch (iconName) {
      case 'Send':
        return lucide.Lucide.send;
      case 'MessageCircle':
        return lucide.Lucide.messageCircle;
      case 'MessageSquare':
        return lucide.Lucide.messageSquare;
      case 'Mail':
        return lucide.Lucide.mail;
      case 'Webhook':
        return lucide.Lucide.webhook;
      case 'Globe':
        return lucide.Lucide.globe;
      default:
        return lucide.Lucide.plug;
    }
  }
}
