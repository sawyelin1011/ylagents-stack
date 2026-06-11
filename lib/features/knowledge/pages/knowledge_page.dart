import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';

/// Knowledge page — shows knowledge sources for the current workspace.
///
/// Knowledge integration with World Books, files, and URLs will be built
/// in later phases. This page provides the landing structure.
class KnowledgePage extends StatelessWidget {
  const KnowledgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final wsProvider = context.watch<WorkspaceProvider>();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final workspace = wsProvider.currentWorkspace;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.bookOpen, size: 24, color: cs.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.desktopNavKnowledgeTooltip,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            if (workspace != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.desktopNavKnowledgeTooltip} — ${workspace.name}',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      lucide.Lucide.bookOpen,
                      size: 48,
                      color: cs.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.knowledgePageEmpty,
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
}
