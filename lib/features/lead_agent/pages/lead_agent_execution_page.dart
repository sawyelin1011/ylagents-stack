import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/execution_trace.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/trace_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/services/lead_agent_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';

/// Lead Agent execution page — user enters a goal and watches the agent
/// plan, delegate, and review.
class LeadAgentExecutionPage extends StatefulWidget {
  final Agent agent;

  const LeadAgentExecutionPage({super.key, required this.agent});

  @override
  State<LeadAgentExecutionPage> createState() => _LeadAgentExecutionPageState();
}

class _LeadAgentExecutionPageState extends State<LeadAgentExecutionPage> {
  final _requestController = TextEditingController();
  bool _isExecuting = false;
  ExecutionTrace? _currentTrace;
  String? _currentResult;

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _execute() async {
    final request = _requestController.text.trim();
    if (request.isEmpty) return;

    final wsProvider = context.read<WorkspaceProvider>();
    final workspaceId = wsProvider.currentWorkspace?.id;
    if (workspaceId == null) return;

    setState(() {
      _isExecuting = true;
      _currentTrace = null;
      _currentResult = null;
    });

    final service = LeadAgentService(
      agentProvider: context.read<AgentProvider>(),
      assistantProvider: context.read<AssistantProvider>(),
      settingsProvider: context.read<SettingsProvider>(),
      taskProvider: context.read<TaskProvider>(),
      traceProvider: context.read<TraceProvider>(),
    );

    final l10n = AppLocalizations.of(context);

    final result = await service.execute(
      userRequest: request,
      workspaceId: workspaceId,
      leadAgentId: widget.agent.id,
      onProgress: (trace) {
        if (mounted) {
          setState(() {
            _currentTrace = trace;
          });
        }
      },
      l10n: l10n,
    );

    if (mounted) {
      setState(() {
        _isExecuting = false;
        _currentTrace = result.trace;
        if (result.success && result.finalResponse != null) {
          _currentResult = result.finalResponse;
        } else if (!result.success) {
          _currentResult = 'Error: ${result.errorMessage}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.Crown, size: 18, color: cs.tertiary),
            const SizedBox(width: 8),
            Text(widget.agent.name),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input area
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.leadAgentInputTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: AppFontWeights.semibold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _requestController,
                      decoration: InputDecoration(
                        hintText: l10n.leadAgentInputHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 3,
                      enabled: !_isExecuting,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        icon: _isExecuting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(lucide.Lucide.Play, size: 16),
                        label: Text(
                          _isExecuting
                              ? l10n.leadAgentExecuting
                              : l10n.leadAgentExecuteButton,
                        ),
                        onPressed:
                            _isExecuting ? null : _execute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Execution progress area
            Expanded(
              child: _currentTrace != null
                  ? _buildExecutionView(l10n, cs)
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lucide.Lucide.Crown,
                            size: 48,
                            color: cs.onSurface.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.leadAgentEmpty,
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.4),
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

  Widget _buildExecutionView(AppLocalizations l10n, ColorScheme cs) {
    final trace = _currentTrace!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          _StatusBanner(trace: trace, cs: cs, l10n: l10n),
          const SizedBox(height: 16),

          // Steps timeline
          if (trace.steps.isNotEmpty) ...[
            Text(
              l10n.leadAgentSteps,
              style: TextStyle(
                fontSize: 14,
                fontWeight: AppFontWeights.semibold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...trace.steps.map((step) => _StepCard(
              step: step,
              cs: cs,
              l10n: l10n,
            )),
          ],
          const SizedBox(height: 16),

          // Final result
          if (trace.finalResponse != null && trace.finalResponse!.isNotEmpty)
            _ResultCard(
              response: trace.finalResponse!,
              cs: cs,
              l10n: l10n,
            ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final ExecutionTrace trace;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _StatusBanner({
    required this.trace,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String label) = switch (trace.status) {
      ExecutionStatus.planning => (
        lucide.Lucide.Clipboard,
        cs.primary,
        l10n.leadAgentStatusPlanning,
      ),
      ExecutionStatus.delegating => (
        lucide.Lucide.GitFork,
        cs.primary,
        l10n.leadAgentStatusDelegating,
      ),
      ExecutionStatus.executing => (
        lucide.Lucide.Loader,
        cs.secondary,
        l10n.leadAgentStatusExecuting,
      ),
      ExecutionStatus.reviewing => (
        lucide.Lucide.ClipboardCheck,
        cs.tertiary,
        l10n.leadAgentStatusReviewing,
      ),
      ExecutionStatus.completed => (
        lucide.Lucide.CheckCircle,
        Colors.green,
        l10n.leadAgentStatusCompleted,
      ),
      ExecutionStatus.failed => (
        lucide.Lucide.XCircle,
        cs.error,
        l10n.leadAgentStatusFailed,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: AppFontWeights.semibold,
                    color: color,
                  ),
                ),
                if (trace.status != ExecutionStatus.completed &&
                    trace.status != ExecutionStatus.failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      backgroundColor: color.withValues(alpha: 0.2),
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          if (trace.status == ExecutionStatus.completed ||
              trace.status == ExecutionStatus.failed)
            Icon(icon, size: 24, color: color),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final ExecutionStep step;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _StepCard({
    required this.step,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (step.type) {
      StepType.plan => (lucide.Lucide.ClipboardPen, cs.primary),
      StepType.delegate => (lucide.Lucide.GitFork, cs.secondary),
      StepType.execute => (lucide.Lucide.Play, cs.primary),
      StepType.review => (lucide.Lucide.ClipboardCheck, cs.tertiary),
    };

    final Color statusColor = switch (step.status) {
      StepStatus.pending => cs.onSurface.withValues(alpha: 0.3),
      StepStatus.inProgress => cs.primary,
      StepStatus.completed => Colors.green,
      StepStatus.failed => cs.error,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface,
                    ),
                  ),
                  if (step.agentId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${l10n.leadAgentAssignedTo}: ${step.agentId}',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  if (step.result != null && step.result!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        step.result!.substring(
                          0,
                          step.result!.length > 120
                              ? 120
                              : step.result!.length,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              switch (step.status) {
                StepStatus.pending => lucide.Lucide.Circle,
                StepStatus.inProgress => lucide.Lucide.Loader,
                StepStatus.completed => lucide.Lucide.CheckCircle,
                StepStatus.failed => lucide.Lucide.XCircle,
              },
              size: 16,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String response;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _ResultCard({
    required this.response,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.leadAgentResult,
          style: TextStyle(
            fontSize: 14,
            fontWeight: AppFontWeights.semibold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cs.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: SelectableText(
            response,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}