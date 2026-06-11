import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/execution_trace.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/trace_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Execution traces history page — browse and inspect past executions.
class TracesPage extends StatefulWidget {
  const TracesPage({super.key});

  @override
  State<TracesPage> createState() => _TracesPageState();
}

class _TracesPageState extends State<TracesPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final wsProvider = context.watch<WorkspaceProvider>();
    final traceProvider = context.watch<TraceProvider>();
    final agentProvider = context.watch<AgentProvider>();
    final workspaceId = wsProvider.currentWorkspace?.id;

    final traces = workspaceId != null
        ? traceProvider.getTracesForWorkspace(workspaceId)
        : traceProvider.traces;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.Binary, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.tracesPageTitle),
          ],
        ),
      ),
      body: traces.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    lucide.Lucide.Binary,
                    size: 56,
                    color: cs.onSurface.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tracesPageEmpty,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: traces.length,
              itemBuilder: (context, index) {
                final trace = traces[index];
                final leadAgent = agentProvider.getById(trace.leadAgentId);

                final (IconData icon, Color color) = switch (trace.status) {
                  ExecutionStatus.completed => (
                    lucide.Lucide.CheckCircle,
                    Colors.green,
                  ),
                  ExecutionStatus.failed => (
                    lucide.Lucide.XCircle,
                    cs.error,
                  ),
                  _ => (
                    lucide.Lucide.Loader,
                    cs.primary,
                  ),
                };

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showTraceDetail(context, trace, l10n, cs),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trace.userRequest.length > 60
                                      ? '${trace.userRequest.substring(0, 60)}...'
                                      : trace.userRequest,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: AppFontWeights.semibold,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (leadAgent != null) ...[
                                      Icon(lucide.Lucide.Crown,
                                          size: 11,
                                          color:
                                              cs.onSurface
                                                  .withValues(alpha: 0.5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        leadAgent.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Icon(lucide.Lucide.Clock,
                                        size: 11,
                                        color:
                                            cs.onSurface.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(trace.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${trace.steps.length} ${l10n.tracesPageSteps}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            lucide.Lucide.ChevronRight,
                            size: 16,
                            color: cs.onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTraceDetail(
    BuildContext context,
    ExecutionTrace trace,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(lucide.Lucide.Binary, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.tracesPageDetailTitle,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User request
                _detailSection(l10n.tracesPageRequest, trace.userRequest, cs),
                const SizedBox(height: 16),

                // Status
                _detailSection(
                  l10n.tracesPageStatus,
                  trace.status.name,
                  cs,
                ),
                const SizedBox(height: 16),

                // Steps
                if (trace.steps.isNotEmpty) ...[
                  Text(
                    '${l10n.tracesPageSteps} (${trace.steps.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: AppFontWeights.semibold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...trace.steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cs.onSurface.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _stepIcon(step.type),
                                  size: 12,
                                  color: _stepIconColor(step.type, cs),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    step.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _statusIcon(step.status),
                                  size: 14,
                                  color: _statusColor(step.status, cs),
                                ),
                              ],
                            ),
                            if (step.result != null &&
                                step.result!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  step.result!.length > 150
                                      ? '${step.result!.substring(0, 150)}...'
                                      : step.result!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface
                                        .withValues(alpha: 0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Final response
                if (trace.finalResponse != null &&
                    trace.finalResponse!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _detailSection(
                    l10n.tracesPageResult,
                    trace.finalResponse!.length > 300
                        ? '${trace.finalResponse!.substring(0, 300)}...'
                        : trace.finalResponse!,
                    cs,
                  ),
                ],

                // Timestamps
                const SizedBox(height: 16),
                _detailSection(
                  l10n.tracesPageCreated,
                  _formatDate(trace.createdAt),
                  cs,
                ),
                _detailSection(
                  l10n.tracesPageUpdated,
                  _formatDate(trace.updatedAt),
                  cs,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tracesPageClose),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String label, String value, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: AppFontWeights.semibold,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  IconData _stepIcon(StepType type) => switch (type) {
    StepType.plan => lucide.Lucide.ClipboardPen,
    StepType.delegate => lucide.Lucide.GitFork,
    StepType.execute => lucide.Lucide.Play,
    StepType.review => lucide.Lucide.ClipboardCheck,
  };

  Color _stepIconColor(StepType type, ColorScheme cs) => switch (type) {
    StepType.plan => cs.primary,
    StepType.delegate => cs.secondary,
    StepType.execute => cs.primary,
    StepType.review => cs.tertiary,
  };

  IconData _statusIcon(StepStatus status) => switch (status) {
    StepStatus.pending => lucide.Lucide.Circle,
    StepStatus.inProgress => lucide.Lucide.Loader,
    StepStatus.completed => lucide.Lucide.CheckCircle,
    StepStatus.failed => lucide.Lucide.XCircle,
  };

  Color _statusColor(StepStatus status, ColorScheme cs) => switch (status) {
    StepStatus.pending => cs.onSurface.withValues(alpha: 0.3),
    StepStatus.inProgress => cs.primary,
    StepStatus.completed => Colors.green,
    StepStatus.failed => cs.error,
  };
}