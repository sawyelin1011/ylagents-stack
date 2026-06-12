import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/agent_team.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/team_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Team management page — create, view, edit agent teams.
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final wsProvider = context.watch<WorkspaceProvider>();
    final teamProvider = context.watch<TeamProvider>();
    final agentProvider = context.watch<AgentProvider>();
    final workspaceId = wsProvider.currentWorkspace?.id;

    final teams = workspaceId != null
        ? teamProvider.getTeamsForWorkspace(workspaceId)
        : teamProvider.teams;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.users, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.teamPageTitle),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              icon: const Icon(lucide.Lucide.plus, size: 16),
              label: Text(l10n.teamPageCreateTeam),
              onPressed: () => _showCreateDialog(context, l10n, cs),
            ),
          ),
        ],
      ),
      body: teams.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    lucide.Lucide.users,
                    size: 56,
                    color: cs.onSurface.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.teamPageEmpty,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: const Icon(lucide.Lucide.plus, size: 16),
                    label: Text(l10n.teamPageCreateTeam),
                    onPressed: () => _showCreateDialog(context, l10n, cs),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final leadAgent = agentProvider.getById(team.leadAgentId);
                final members = team.memberAgentIds
                    .map((id) => agentProvider.getById(id))
                    .whereType<Agent>()
                    .toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              lucide.Lucide.users,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                team.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: AppFontWeights.semibold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        l10n.teamPageDeleteConfirmTitle,
                                      ),
                                      content: Text(
                                        l10n.teamPageDeleteConfirmContent,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l10n.teamPageCancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(
                                            l10n.teamPageDelete,
                                            style: TextStyle(color: cs.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && mounted) {
                                    // ignore: use_build_context_synchronously
                                    await context
                                        .read<TeamProvider>()
                                        .deleteTeam(team.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        lucide.Lucide.trash,
                                        size: 16,
                                        color: cs.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.teamPageDelete,
                                        style: TextStyle(color: cs.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (team.description != null &&
                            team.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              team.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Lead agent
                        _AgentRow(
                          icon: lucide.Lucide.crown,
                          label: l10n.teamPageLeadAgent,
                          agentName: leadAgent?.name ?? team.leadAgentId,
                          color: cs.tertiary,
                          cs: cs,
                        ),
                        const SizedBox(height: 6),
                        // Worker agents
                        ...members.map(
                          (agent) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _AgentRow(
                              icon: lucide.Lucide.hardHat,
                              label: '',
                              agentName: agent.name,
                              color: cs.primary,
                              cs: cs,
                            ),
                          ),
                        ),
                        if (members.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              l10n.teamPageNoMembers,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Manage members button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(lucide.Lucide.userPlus, size: 14),
                            label: Text(l10n.teamPageManageMembers),
                            onPressed: () => _showManageMembersDialog(
                              context,
                              team,
                              agentProvider,
                              l10n,
                              cs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedLeadId;
    final wsProvider = context.read<WorkspaceProvider>();
    final agentProvider = context.read<AgentProvider>();
    final workspaceId = wsProvider.currentWorkspace?.id;
    final leadAgents = workspaceId != null
        ? agentProvider
              .getAgentsForWorkspace(workspaceId)
              .where((a) => a.type == AgentType.lead && a.enabled)
              .toList()
        : <Agent>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.teamPageCreateTeam),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.teamPageTeamName,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.teamPageTeamDescription,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                if (leadAgents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.teamPageNoLeadAgents,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: selectedLeadId,
                    decoration: InputDecoration(
                      labelText: l10n.teamPageSelectLead,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: leadAgents
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() => selectedLeadId = v);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.teamPageCancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || selectedLeadId == null) {
                  return;
                }
                final uuid = const Uuid();
                final team = AgentTeam(
                  id: uuid.v4(),
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  workspaceId: workspaceId ?? '',
                  leadAgentId: selectedLeadId!,
                );
                await context.read<TeamProvider>().createTeam(team);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.teamPageCreate),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageMembersDialog(
    BuildContext context,
    AgentTeam team,
    AgentProvider agentProvider,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final availableWorkers = agentProvider.agents
        .where(
          (a) =>
              a.type == AgentType.worker &&
              a.enabled &&
              !team.memberAgentIds.contains(a.id),
        )
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.teamPageManageMembers} — ${team.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current members
              Text(
                l10n.teamPageMembers,
                style: TextStyle(
                  fontWeight: AppFontWeights.semibold,
                  fontSize: 13,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...team.memberAgentIds.map((id) {
                final agent = agentProvider.getById(id);
                return ListTile(
                  dense: true,
                  leading: Icon(
                    lucide.Lucide.hardHat,
                    size: 16,
                    color: cs.primary,
                  ),
                  title: Text(
                    agent?.name ?? id,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: Icon(lucide.Lucide.x, size: 14, color: cs.error),
                    onPressed: () async {
                      await context.read<TeamProvider>().removeMember(
                        team.id,
                        id,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        _showManageMembersDialog(
                          ctx,
                          team.copyWith(
                            memberAgentIds: team.memberAgentIds
                                .where((a) => a != id)
                                .toList(),
                          ),
                          agentProvider,
                          l10n,
                          cs,
                        );
                      }
                    },
                  ),
                );
              }),
              if (team.memberAgentIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.teamPageNoMembers,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const Divider(),
              // Add worker
              Text(
                l10n.teamPageAddWorker,
                style: TextStyle(
                  fontWeight: AppFontWeights.semibold,
                  fontSize: 13,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (availableWorkers.isEmpty)
                Text(
                  l10n.teamPageNoAvailableWorkers,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...availableWorkers.map(
                  (agent) => ListTile(
                    dense: true,
                    leading: Icon(
                      lucide.Lucide.userPlus,
                      size: 16,
                      color: cs.primary,
                    ),
                    title: Text(
                      agent.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        lucide.Lucide.plus,
                        size: 14,
                        color: cs.primary,
                      ),
                      onPressed: () async {
                        await context.read<TeamProvider>().addMember(
                          team.id,
                          agent.id,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _showManageMembersDialog(
                            ctx,
                            team.copyWith(
                              memberAgentIds: [...team.memberAgentIds, agent.id],
                            ),
                            agentProvider,
                            l10n,
                            cs,
                          );
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.teamPageClose),
          ),
        ],
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String agentName;
  final Color color;
  final ColorScheme cs;

  const _AgentRow({
    required this.icon,
    required this.label,
    required this.agentName,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            agentName,
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}
