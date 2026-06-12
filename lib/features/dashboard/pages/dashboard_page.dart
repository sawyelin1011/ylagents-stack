import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/workspace.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/services/chat/chat_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';

/// Workspace dashboard overview page.
///
/// Shows workspace name, type, agent count, conversation count, and quick actions.
/// This is the default landing page when opening YLAgents.
class DashboardPage extends StatelessWidget {
  final VoidCallback? onNewChat;
  final VoidCallback? onNewAssistant;

  const DashboardPage({super.key, this.onNewChat, this.onNewAssistant});

  @override
  Widget build(BuildContext context) {
    final assistantProvider = context.watch<AssistantProvider>();
    final chatService = context.watch<ChatService>();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final agentCount = assistantProvider.assistants.length;
    final conversations = chatService.getAllConversations();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workspace header
            _WorkspaceHeader(l10n: l10n, cs: cs),
            const SizedBox(height: 24),
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: lucide.Lucide.bot,
                    label: l10n.desktopNavAgentsTooltip,
                    value: '$agentCount',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: lucide.Lucide.messageCircle,
                    label: l10n.desktopNavChatTooltip,
                    value: '${conversations.length}',
                    color: cs.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: lucide.Lucide.checkSquare,
                    label: l10n.dashboardPageTasks,
                    value: '${context.watch<TaskProvider>().taskCount}',
                    color: cs.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick actions section
            Text(
              l10n.dashboardPageQuickActions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: AppFontWeights.semibold,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  icon: lucide.Lucide.messageCirclePlus,
                  label: l10n.dashboardPageNewChat,
                  color: cs.primary,
                  onTap: onNewChat,
                ),
                _QuickActionChip(
                  icon: lucide.Lucide.plus,
                  label: l10n.dashboardPageNewAssistant,
                  color: cs.secondary,
                  onTap: onNewAssistant,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent conversations
            Text(
              l10n.dashboardPageRecentActivity,
              style: TextStyle(
                fontSize: 16,
                fontWeight: AppFontWeights.semibold,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: conversations.isNotEmpty
                  ? ListView.separated(
                      itemCount: conversations.length > 10
                          ? 10
                          : conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            lucide.Lucide.messageCircle,
                            size: 18,
                            color: cs.primary.withValues(alpha: 0.7),
                          ),
                          title: Text(
                            conv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            _formatDate(conv.updatedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        l10n.dashboardPageNoActivity,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _WorkspaceHeader({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    final wsProvider = context.watch<WorkspaceProvider>();
    final ws = wsProvider.currentWorkspace;
    if (ws == null) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            ws.type == WorkspaceType.personal
                ? lucide.Lucide.user
                : ws.type == WorkspaceType.project
                ? lucide.Lucide.boxes
                : lucide.Lucide.briefcase,
            color: cs.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ws.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: AppFontWeights.semibold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _typeLabel(ws.type, l10n),
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _typeLabel(WorkspaceType type, AppLocalizations l10n) {
    return switch (type) {
      WorkspaceType.personal => l10n.workspaceTypePersonal,
      WorkspaceType.project => l10n.workspaceTypeProject,
      WorkspaceType.client => l10n.workspaceTypeClient,
    };
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: AppFontWeights.semibold,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}
