import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/models/workspace.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';

/// A dropdown button that shows the current workspace and allows switching.
///
/// Also provides quick access to create new workspaces.
class WorkspaceSelector extends StatelessWidget {
  const WorkspaceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final wsProvider = context.watch<WorkspaceProvider>();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final current = wsProvider.currentWorkspace;

    return GestureDetector(
      onTap: () => _showWorkspaceMenu(context, wsProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _iconForType(current?.type ?? WorkspaceType.personal),
              size: 16,
              color: cs.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                current?.name ?? l10n.workspaceProviderDefaultWorkspaceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: AppFontWeights.semibold,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              lucide.Lucide.chevronDown,
              size: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkspaceMenu(BuildContext context, WorkspaceProvider wsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<Workspace>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 4,
        offset.dx + 240,
        offset.dy + renderBox.size.height + 4 + 300,
      ),
      constraints: const BoxConstraints(maxWidth: 240, maxHeight: 360),
      items: [
        ...wsProvider.workspaces.map(
          (ws) => PopupMenuItem<Workspace>(
            value: ws,
            child: Row(
              children: [
                Icon(
                  _iconForType(ws.type),
                  size: 16,
                  color: ws.id == wsProvider.currentWorkspaceId
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ws.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: ws.id == wsProvider.currentWorkspaceId
                          ? AppFontWeights.semibold
                          : AppFontWeights.regular,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (ws.id == wsProvider.currentWorkspaceId)
                  Icon(lucide.Lucide.check, size: 14, color: cs.primary),
              ],
            ),
            onTap: () {
              wsProvider.setCurrentWorkspace(ws.id);
            },
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(lucide.Lucide.plus, size: 16, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                l10n.workspaceSelectorNewWorkspace,
                style: TextStyle(fontSize: 14, color: cs.primary),
              ),
            ],
          ),
          onTap: () => _showCreateWorkspaceDialog(context, wsProvider, l10n),
        ),
      ],
    );
  }

  void _showCreateWorkspaceDialog(
    BuildContext context,
    WorkspaceProvider wsProvider,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    WorkspaceType selectedType = WorkspaceType.personal;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.workspaceSelectorNewWorkspace),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.workspaceSelectorNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WorkspaceType>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: l10n.workspaceSelectorTypeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: WorkspaceType.personal,
                        child: Text(l10n.workspaceTypePersonal),
                      ),
                      DropdownMenuItem(
                        value: WorkspaceType.project,
                        child: Text(l10n.workspaceTypeProject),
                      ),
                      DropdownMenuItem(
                        value: WorkspaceType.client,
                        child: Text(l10n.workspaceTypeClient),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedType = v);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.workspaceSelectorCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    wsProvider.createWorkspace(name: name, type: selectedType);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(l10n.workspaceSelectorCreate),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _iconForType(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return lucide.Lucide.user;
      case WorkspaceType.project:
        return lucide.Lucide.boxes;
      case WorkspaceType.client:
        return lucide.Lucide.briefcase;
    }
  }
}
