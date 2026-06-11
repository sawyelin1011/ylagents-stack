import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/agent_genome.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';
import '../../agent_factory/pages/agent_factory_page.dart';
import '../../lead_agent/pages/lead_agent_execution_page.dart';
import '../../team/pages/team_page.dart';
import '../../traces/pages/traces_page.dart';

/// Agents page — lists all agents in the current workspace.
///
/// Shows genome data (identity, soul, role, goals) for agents that have
/// been promoted. Plain assistants show a "Promote to Agent" option.
class AgentsPage extends StatelessWidget {
  const AgentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final assistantProvider = context.watch<AssistantProvider>();
    final agentProvider = context.watch<AgentProvider>();
    final wsProvider = context.watch<WorkspaceProvider>();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final workspaceId = wsProvider.currentWorkspace?.id;
    final assistants = assistantProvider.assistants;

    // Filter for current workspace
    final workspaceAssistants = workspaceId != null
        ? assistants.where(
            (a) => a.workspaceId == null || a.workspaceId == workspaceId,
          )
        : assistants;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Bot, size: 24, color: cs.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.desktopNavAgentsTooltip,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(lucide.Lucide.Binary, size: 16),
                  label: Text(l10n.agentsPageTraces),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TracesPage()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(lucide.Lucide.Users, size: 16),
                  label: Text(l10n.agentsPageTeams),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const TeamPage()));
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(lucide.Lucide.Plus, size: 16),
                  label: Text(l10n.agentFactoryNewAgent),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AgentFactoryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: workspaceAssistants.isNotEmpty
                  ? ListView.builder(
                      itemCount: workspaceAssistants.length,
                      itemBuilder: (context, index) {
                        final assistant = workspaceAssistants.elementAt(index);
                        final agent = agentProvider.getById(assistant.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar column
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: cs.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  child: Text(
                                    assistant.name.isNotEmpty
                                        ? assistant.name.characters.first
                                        : '?',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: AppFontWeights.semibold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name + subtitle + genome info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name row with agent type badge
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              assistant.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight:
                                                    AppFontWeights.semibold,
                                                fontSize: 14,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                          ),
                                          if (agent != null) ...[
                                            const SizedBox(width: 8),
                                            _AgentTypeBadge(
                                              type: agent.type,
                                              colorScheme: cs,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // System prompt fallback subtitle
                                      if (agent == null)
                                        Text(
                                          assistant.systemPrompt.isNotEmpty
                                              ? assistant.systemPrompt
                                                    .split('\n')
                                                    .first
                                              : l10n.assistantSettingsNoPromptPlaceholder,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      // Genome data for agents
                                      if (agent != null) ...[
                                        if (agent.genome.identity.isNotEmpty)
                                          _GenomeChip(
                                            icon: lucide.Lucide.User,
                                            label: agent.genome.identity,
                                            colorScheme: cs,
                                          ),
                                        if (agent.genome.soul.isNotEmpty)
                                          _GenomeChip(
                                            icon: lucide.Lucide.Heart,
                                            label: agent.genome.soul,
                                            colorScheme: cs,
                                          ),
                                        if (agent.genome.role.isNotEmpty)
                                          _GenomeChip(
                                            icon: lucide.Lucide.Briefcase,
                                            label: agent.genome.role,
                                            colorScheme: cs,
                                          ),
                                        if (agent.genome.goals.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 2,
                                              children: agent.genome.goals
                                                  .map(
                                                    (g) => Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: cs
                                                            .tertiaryContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        g,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: cs
                                                              .onTertiaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        if (agent.genome.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              l10n.agentGenomeEmpty,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: cs.onSurface.withValues(
                                                  alpha: 0.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Action icons column
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (agent == null)
                                      IconButton(
                                        icon: Icon(
                                          lucide.Lucide.Sparkles,
                                          size: 16,
                                          color: cs.primary,
                                        ),
                                        tooltip: l10n.agentPromoteButton,
                                        onPressed: () {
                                          agentProvider.promoteToAgent(
                                            assistant.id,
                                          );
                                        },
                                        visualDensity: VisualDensity.compact,
                                      )
                                    else ...[
                                      if (agent.type == AgentType.lead)
                                        IconButton(
                                          icon: Icon(
                                            lucide.Lucide.Play,
                                            size: 16,
                                            color: cs.tertiary,
                                          ),
                                          tooltip: l10n.leadAgentRunButton,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    LeadAgentExecutionPage(
                                                      agent: agent,
                                                    ),
                                              ),
                                            );
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      IconButton(
                                        icon: Icon(
                                          agent.enabled
                                              ? lucide.Lucide.CheckCircle
                                              : lucide.Lucide.XCircle,
                                          size: 16,
                                          color: agent.enabled
                                              ? cs.primary
                                              : cs.onSurface.withValues(
                                                  alpha: 0.4,
                                                ),
                                        ),
                                        tooltip: agent.enabled
                                            ? l10n.agentEnableLabel
                                            : l10n.agentDisableLabel,
                                        onPressed: () {
                                          agentProvider.toggleEnabled(
                                            assistant.id,
                                          );
                                        },
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          lucide.Lucide.Settings,
                                          size: 16,
                                          color: cs.onSurface.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        tooltip: l10n.agentDetailsViewTitle,
                                        onPressed: () {
                                          _showAgentDetails(
                                            context,
                                            agent,
                                            agentProvider,
                                            l10n,
                                            cs,
                                          );
                                        },
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lucide.Lucide.Bot,
                            size: 48,
                            color: cs.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.agentsPageEmpty,
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentDetails(
    BuildContext context,
    Agent agent,
    AgentProvider agentProvider,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Local mutable copies for the dialog
        String identity = agent.genome.identity;
        String soul = agent.genome.soul;
        String role = agent.genome.role;
        List<String> goals = List<String>.of(agent.genome.goals);
        String backstory = agent.genome.backstory;
        final goalController = TextEditingController();
        AgentType selectedType = agent.type;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${agent.name} — ${l10n.agentGenomeTitle}'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Agent type dropdown
                      DropdownButtonFormField<AgentType>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: l10n.agentGenomeTypeLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: AgentType.standard,
                            child: Text(l10n.agentTypeStandard),
                          ),
                          DropdownMenuItem(
                            value: AgentType.lead,
                            child: Text(l10n.agentTypeLead),
                          ),
                          DropdownMenuItem(
                            value: AgentType.worker,
                            child: Text(l10n.agentTypeWorker),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedType = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: l10n.agentGenomeIdentityLabel,
                          hintText: l10n.agentGenomeIdentityHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: identity),
                        onChanged: (v) => identity = v,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: l10n.agentGenomeSoulLabel,
                          hintText: l10n.agentGenomeSoulHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: soul),
                        onChanged: (v) => soul = v,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: l10n.agentGenomeRoleLabel,
                          hintText: l10n.agentGenomeRoleHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: role),
                        onChanged: (v) => role = v,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      // Goals list
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.agentGenomeGoalsLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...goals.asMap().entries.map(
                            (entry) => Chip(
                              label: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setDialogState(() {
                                  goals.removeAt(entry.key);
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: goalController,
                              decoration: InputDecoration(
                                hintText: l10n.agentGenomeAddGoalHint,
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              onSubmitted: (v) {
                                final trimmed = goalController.text.trim();
                                if (trimmed.isNotEmpty) {
                                  setDialogState(() {
                                    goals.add(trimmed);
                                    goalController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: l10n.agentGenomeBackstoryLabel,
                          hintText: l10n.agentGenomeBackstoryHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: backstory),
                        onChanged: (v) => backstory = v,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.workspaceSelectorCancel),
                ),
                TextButton(
                  onPressed: () {
                    agentProvider.demoteFromAgent(agent.id);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    l10n.agentDemoteButton,
                    style: TextStyle(color: cs.error),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    agentProvider.updateType(agent.id, selectedType);
                    agentProvider.updateGenome(
                      agent.id,
                      AgentGenome(
                        identity: identity,
                        soul: soul,
                        role: role,
                        goals: goals,
                        backstory: backstory,
                      ),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.agentGenomeSaveAction),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A small chip showing the agent type (Standard / Lead / Worker).
class _AgentTypeBadge extends StatelessWidget {
  final AgentType type;
  final ColorScheme colorScheme;

  const _AgentTypeBadge({required this.type, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (Color bg, Color fg, IconData icon, String label) = switch (type) {
      AgentType.lead => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        lucide.Lucide.Crown,
        l10n.agentTypeLead,
      ),
      AgentType.worker => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        lucide.Lucide.HardHat,
        l10n.agentTypeWorker,
      ),
      AgentType.standard => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        lucide.Lucide.Bot,
        l10n.agentTypeStandard,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: AppFontWeights.semibold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small genome info chip showing an icon + label.
class _GenomeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _GenomeChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
