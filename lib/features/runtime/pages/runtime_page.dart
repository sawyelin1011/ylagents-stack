import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/runtime_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/services/scheduler_service.dart';
import '../../../core/models/runtime_execution.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Runtime host management page — host status, active executions, history, schedules.
class RuntimePage extends StatefulWidget {
  const RuntimePage({super.key});

  @override
  State<RuntimePage> createState() => _RuntimePageState();
}

class _RuntimePageState extends State<RuntimePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final runtime = context.watch<RuntimeProvider>();
    final ws = context.watch<WorkspaceProvider>();
    final workspaceId = ws.currentWorkspace?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.Server, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.runtimePageTitle),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HostStatusSection(runtime: runtime, l10n: l10n, cs: cs),
          const SizedBox(height: 16),
          _ActiveExecutionsSection(
            runtime: runtime,
            workspaceId: workspaceId,
            l10n: l10n,
            cs: cs,
          ),
          const SizedBox(height: 16),
          _ScheduleSection(workspaceId: workspaceId, l10n: l10n, cs: cs),
          const SizedBox(height: 16),
          _HistorySection(
            runtime: runtime,
            workspaceId: workspaceId,
            l10n: l10n,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

/// Host status section with start/stop controls.
class _HostStatusSection extends StatelessWidget {
  final RuntimeProvider runtime;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _HostStatusSection({
    required this.runtime,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = runtime.hostStatus == RuntimeHostStatus.running;
    final uptimeStr = runtime.uptime != null
        ? _formatDuration(runtime.uptime!)
        : '--';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Server, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.runtimePageHostSection,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning
                        ? Colors.green
                        : cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning
                      ? l10n.runtimeStatusRunning
                      : l10n.runtimeStatusStopped,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: AppFontWeights.medium,
                    color: isRunning ? Colors.green.shade700 : cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(label: l10n.runtimePageUptime, value: uptimeStr, cs: cs),
            const SizedBox(height: 4),
            _InfoRow(
              label: l10n.runtimePageSuccessCount,
              value: '${runtime.successCount}',
              cs: cs,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: l10n.runtimePageFailedCount,
              value: '${runtime.failedCount}',
              cs: cs,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isRunning)
                  FilledButton.icon(
                    icon: const Icon(lucide.Lucide.Play, size: 14),
                    label: Text(l10n.runtimePageStart),
                    onPressed: () => runtime.startHost(),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                else ...[
                  OutlinedButton.icon(
                    icon: const Icon(lucide.Lucide.StopCircle, size: 14),
                    label: Text(l10n.runtimePageStop),
                    onPressed: () => runtime.stopHost(),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: cs.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}

/// Active executions section.
class _ActiveExecutionsSection extends StatelessWidget {
  final RuntimeProvider runtime;
  final String? workspaceId;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _ActiveExecutionsSection({
    required this.runtime,
    required this.workspaceId,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final active = runtime.activeExecutions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Activity, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.runtimePageActiveSection,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semibold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${active.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (active.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    l10n.runtimePageNoActive,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else
              ...active.map(
                (exec) => _ExecutionRow(execution: exec, cs: cs, l10n: l10n),
              ),
            if (runtime.hostStatus == RuntimeHostStatus.running)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  icon: const Icon(lucide.Lucide.Play, size: 14),
                  label: const Text('Run Agent'),
                  onPressed: () => _executeAgent(context, runtime),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _executeAgent(BuildContext context, RuntimeProvider runtime) {
    final ws = context.read<WorkspaceProvider>();
    final agents = context.read<AgentProvider>();
    final workspaceId = ws.currentWorkspace?.id ?? '';
    final agentList = agents.getAgentsForWorkspace(workspaceId);
    if (agentList.isEmpty) return;
    final agent = agentList.first;
    runtime.executeAgent(
      userRequest: 'Execute a background task',
      agentId: agent.id,
      agentName: agent.name,
      workspaceId: workspaceId,
    );
  }
}

/// Schedule management section.
class _ScheduleSection extends StatelessWidget {
  final String? workspaceId;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _ScheduleSection({
    required this.workspaceId,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final scheduler = context.watch<SchedulerService>();
    final schedules = scheduler.getSchedulesForWorkspace(workspaceId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Clock, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.runtimePageScheduleSection,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semibold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${schedules.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    l10n.runtimePageNoSchedules,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else
              ...schedules.map(
                (schedule) =>
                    _ScheduleRow(schedule: schedule, cs: cs, l10n: l10n),
              ),
          ],
        ),
      ),
    );
  }
}

/// Execution history section.
class _HistorySection extends StatelessWidget {
  final RuntimeProvider runtime;
  final String? workspaceId;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _HistorySection({
    required this.runtime,
    required this.workspaceId,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final execs = runtime.getExecutionsForWorkspace(workspaceId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.History, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.runtimePageHistorySection,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semibold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${execs.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (execs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.runtimePageNoHistory,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else
              ...execs.reversed
                  .take(20)
                  .map(
                    (exec) =>
                        _ExecutionRow(execution: exec, cs: cs, l10n: l10n),
                  ),
          ],
        ),
      ),
    );
  }
}

/// A single execution row (used in both active and history sections).
class _ExecutionRow extends StatelessWidget {
  final RuntimeExecution execution;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _ExecutionRow({
    required this.execution,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusIcon = _statusIcon(execution.status);
    final statusColor = _statusColor(execution.status);
    final statusText = _statusText(execution.status, l10n);
    final durationStr = execution.duration != null
        ? _formatShort(execution.duration!)
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execution.agentName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: AppFontWeights.medium,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  execution.taskTitle.isNotEmpty
                      ? execution.taskTitle
                      : statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            durationStr,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(RuntimeExecutionStatus status) {
    switch (status) {
      case RuntimeExecutionStatus.running:
        return lucide.Lucide.Loader;
      case RuntimeExecutionStatus.completed:
        return lucide.Lucide.CheckCircle;
      case RuntimeExecutionStatus.failed:
        return lucide.Lucide.AlertCircle;
      case RuntimeExecutionStatus.cancelled:
        return lucide.Lucide.XCircle;
      case RuntimeExecutionStatus.pending:
        return lucide.Lucide.Circle;
    }
  }

  Color _statusColor(RuntimeExecutionStatus status) {
    switch (status) {
      case RuntimeExecutionStatus.running:
        return cs.primary;
      case RuntimeExecutionStatus.completed:
        return Colors.green;
      case RuntimeExecutionStatus.failed:
        return cs.error;
      case RuntimeExecutionStatus.cancelled:
        return Colors.orange;
      case RuntimeExecutionStatus.pending:
        return cs.onSurface.withValues(alpha: 0.3);
    }
  }

  String _statusText(RuntimeExecutionStatus status, AppLocalizations l10n) {
    switch (status) {
      case RuntimeExecutionStatus.running:
        return l10n.runtimeStatusRunning;
      case RuntimeExecutionStatus.completed:
        return l10n.runtimeStatusCompleted;
      case RuntimeExecutionStatus.failed:
        return l10n.runtimeStatusFailed;
      case RuntimeExecutionStatus.cancelled:
        return l10n.runtimeStatusCancelled;
      case RuntimeExecutionStatus.pending:
        return l10n.runtimeStatusPending;
    }
  }

  String _formatShort(Duration d) {
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}

/// A single schedule row.
class _ScheduleRow extends StatelessWidget {
  final ScheduledRun schedule;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _ScheduleRow({
    required this.schedule,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            schedule.enabled ? lucide.Lucide.Bell : lucide.Lucide.BellOff,
            size: 14,
            color: schedule.enabled
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.agentName,
                  style: TextStyle(fontSize: 13, color: cs.onSurface),
                ),
                Text(
                  _intervalText(schedule.interval, l10n),
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              schedule.enabled
                  ? lucide.Lucide.ToggleRight
                  : lucide.Lucide.ToggleLeft,
              size: 16,
            ),
            onPressed: () {
              context.read<SchedulerService>().toggleEnabled(schedule.id);
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _intervalText(ScheduleInterval interval, AppLocalizations l10n) {
    switch (interval) {
      case ScheduleInterval.once:
        return l10n.scheduleIntervalOnce;
      case ScheduleInterval.hourly:
        return l10n.scheduleIntervalHourly;
      case ScheduleInterval.daily:
        return l10n.scheduleIntervalDaily;
      case ScheduleInterval.weekly:
        return l10n.scheduleIntervalWeekly;
      case ScheduleInterval.monthly:
        return l10n.scheduleIntervalMonthly;
    }
  }
}

/// An info label-value row.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}
