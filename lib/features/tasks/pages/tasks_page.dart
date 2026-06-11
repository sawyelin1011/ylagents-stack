import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/models/task.dart';
import '../../../l10n/app_localizations.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../theme/app_font_weights.dart';

/// Tasks page — kanban-style task management.
///
/// Displays tasks in columns organized by status. Supports:
/// - Creating new tasks via dialog
/// - Dragging tasks between status columns
/// - Editing task details (title, description, priority, assignee, due date)
/// - Workspace-aware filtering
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final wsProvider = context.watch<WorkspaceProvider>();
    final assistantProvider = context.watch<AssistantProvider>();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final workspaceId = wsProvider.currentWorkspace?.id;
    final tasks = taskProvider.getTasksForWorkspace(workspaceId);
    final statusCounts = taskProvider.getStatusCounts(workspaceId);

    // Group tasks by status
    final grouped = <TaskStatus, List<Task>>{};
    for (final status in TaskStatus.values) {
      grouped[status] = tasks.where((t) => t.status == status).toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with create button
            Row(
              children: [
                Icon(lucide.Lucide.CheckSquare, size: 24, color: cs.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.desktopNavTasksTooltip,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(lucide.Lucide.Plus, size: 16),
                  label: Text(l10n.tasksPageCreateTask),
                  onPressed: () => _showCreateTaskDialog(
                    context,
                    taskProvider,
                    l10n,
                    workspaceId,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Kanban board
            Expanded(
              child: tasks.isNotEmpty
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: TaskStatus.values
                          .map(
                            (status) => _TaskColumn(
                              status: status,
                              tasks: grouped[status] ?? [],
                              count: statusCounts[status] ?? 0,
                              statusLabel: _statusLabel(status, l10n),
                              statusIcon: _statusIcon(status),
                              statusColor: _statusColor(status, cs),
                              cs: cs,
                              l10n: l10n,
                              taskProvider: taskProvider,
                              assistantProvider: assistantProvider,
                            ),
                          )
                          .toList(),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lucide.Lucide.CheckSquare,
                            size: 48,
                            color: cs.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.tasksPageEmpty,
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            icon: const Icon(lucide.Lucide.Plus, size: 16),
                            label: Text(l10n.tasksPageCreateTask),
                            onPressed: () => _showCreateTaskDialog(
                              context,
                              taskProvider,
                              l10n,
                              workspaceId,
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

  void _showCreateTaskDialog(
    BuildContext context,
    TaskProvider taskProvider,
    AppLocalizations l10n,
    String? workspaceId,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.tasksPageCreateTask),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPageTitleLabel,
                          hintText: l10n.tasksPageTitleHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPageDescriptionLabel,
                          hintText: l10n.tasksPageDescriptionHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TaskPriority>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPagePriorityLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: TaskPriority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(_priorityLabel(p, l10n)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedPriority = v);
                          }
                        },
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
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    taskProvider.createTask(
                      title: title,
                      description: descriptionController.text.trim(),
                      workspaceId: workspaceId,
                      priority: selectedPriority,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.tasksPageCreateTask),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _statusLabel(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.backlog:
        return l10n.tasksStatusBacklog;
      case TaskStatus.todo:
        return l10n.tasksStatusTodo;
      case TaskStatus.inProgress:
        return l10n.tasksStatusInProgress;
      case TaskStatus.review:
        return l10n.tasksStatusReview;
      case TaskStatus.completed:
        return l10n.tasksStatusCompleted;
      case TaskStatus.cancelled:
        return l10n.tasksStatusCancelled;
    }
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return lucide.Lucide.List;
      case TaskStatus.todo:
        return lucide.Lucide.Circle;
      case TaskStatus.inProgress:
        return lucide.Lucide.Play;
      case TaskStatus.review:
        return lucide.Lucide.Search;
      case TaskStatus.completed:
        return lucide.Lucide.CheckCircle;
      case TaskStatus.cancelled:
        return lucide.Lucide.XCircle;
    }
  }

  Color _statusColor(TaskStatus status, ColorScheme cs) {
    switch (status) {
      case TaskStatus.backlog:
        return cs.onSurface.withValues(alpha: 0.4);
      case TaskStatus.todo:
        return cs.primary;
      case TaskStatus.inProgress:
        return cs.tertiary;
      case TaskStatus.review:
        return cs.secondary;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return cs.onSurface.withValues(alpha: 0.3);
    }
  }

  static String _priorityLabel(TaskPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case TaskPriority.none:
        return l10n.tasksPriorityNone;
      case TaskPriority.low:
        return l10n.tasksPriorityLow;
      case TaskPriority.medium:
        return l10n.tasksPriorityMedium;
      case TaskPriority.high:
        return l10n.tasksPriorityHigh;
      case TaskPriority.urgent:
        return l10n.tasksPriorityUrgent;
    }
  }
}

/// A single kanban column for a task status.
class _TaskColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final int count;
  final String statusLabel;
  final IconData statusIcon;
  final Color statusColor;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final TaskProvider taskProvider;
  final AssistantProvider assistantProvider;

  const _TaskColumn({
    required this.status,
    required this.tasks,
    required this.count,
    required this.statusLabel,
    required this.statusIcon,
    required this.statusColor,
    required this.cs,
    required this.l10n,
    required this.taskProvider,
    required this.assistantProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Row(
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: AppFontWeights.semibold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Task cards
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      l10n.tasksColumnEmpty,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        cs: cs,
                        l10n: l10n,
                        taskProvider: taskProvider,
                        assistantProvider: assistantProvider,
                        statuses: TaskStatus.values,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// A single task card in a kanban column.
class _TaskCard extends StatelessWidget {
  final Task task;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final TaskProvider taskProvider;
  final AssistantProvider assistantProvider;
  final List<TaskStatus> statuses;

  const _TaskCard({
    required this.task,
    required this.cs,
    required this.l10n,
    required this.taskProvider,
    required this.assistantProvider,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    final assigneeName = task.assigneeAgentId != null
        ? assistantProvider.getById(task.assigneeAgentId!)?.name
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditTaskDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: AppFontWeights.semibold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Priority indicator
                  _PriorityBadge(priority: task.priority, cs: cs, l10n: l10n),
                ],
              ),
              // Description preview
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Footer row: assignee + due date + status menu
              Row(
                children: [
                  // Assignee
                  if (assigneeName != null)
                    _FooterChip(
                      icon: lucide.Lucide.User,
                      label: assigneeName,
                      cs: cs,
                    ),
                  if (assigneeName != null) const SizedBox(width: 8),
                  // Due date
                  if (task.dueDate != null)
                    _FooterChip(
                      icon: lucide.Lucide.Calendar,
                      label: _formatDate(task.dueDate!),
                      cs: cs,
                    ),
                  const Spacer(),
                  // Move status menu
                  PopupMenuButton<TaskStatus>(
                    icon: Icon(
                      lucide.Lucide.ChevronDown,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                    tooltip: l10n.tasksPageMoveTask,
                    onSelected: (newStatus) {
                      taskProvider.updateTaskStatus(task.id, newStatus);
                    },
                    itemBuilder: (context) => statuses
                        .where((s) => s != task.status)
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(_statusLabel(s, l10n)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    TaskStatus selectedStatus = task.status;
    TaskPriority selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.tasksPageEditTask),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPageTitleLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPageDescriptionLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TaskStatus>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPageStatusLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: TaskStatus.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statusLabel(s, l10n)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedStatus = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TaskPriority>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          labelText: l10n.tasksPagePriorityLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: TaskPriority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(TasksPage._priorityLabel(p, l10n)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedPriority = v);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    taskProvider.deleteTask(task.id);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    l10n.tasksPageDeleteTask,
                    style: TextStyle(color: cs.error),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.workspaceSelectorCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    taskProvider.updateTask(
                      task.copyWith(
                        title: title,
                        description: descriptionController.text.trim(),
                        status: selectedStatus,
                        priority: selectedPriority,
                        updatedAt: DateTime.now(),
                      ),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.tasksPageSaveAction),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _statusLabel(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.backlog:
        return l10n.tasksStatusBacklog;
      case TaskStatus.todo:
        return l10n.tasksStatusTodo;
      case TaskStatus.inProgress:
        return l10n.tasksStatusInProgress;
      case TaskStatus.review:
        return l10n.tasksStatusReview;
      case TaskStatus.completed:
        return l10n.tasksStatusCompleted;
      case TaskStatus.cancelled:
        return l10n.tasksStatusCancelled;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}

/// Small colored badge for task priority.
class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _PriorityBadge({
    required this.priority,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (priority == TaskPriority.none) return const SizedBox.shrink();

    final (Color color, Color bg) = switch (priority) {
      TaskPriority.low => (
        cs.onSurface.withValues(alpha: 0.4),
        cs.surfaceContainerHighest,
      ),
      TaskPriority.medium => (cs.primary, cs.primaryContainer),
      TaskPriority.high => (
        Colors.orange,
        Colors.orange.withValues(alpha: 0.15),
      ),
      TaskPriority.urgent => (Colors.red, Colors.red.withValues(alpha: 0.15)),
      TaskPriority.none => (cs.onSurface, cs.surfaceContainerHighest),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        TasksPage._priorityLabel(priority, l10n),
        style: TextStyle(
          fontSize: 9,
          fontWeight: AppFontWeights.semibold,
          color: color,
        ),
      ),
    );
  }
}

/// Small chip for the task card footer.
class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _FooterChip({
    required this.icon,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
