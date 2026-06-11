import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../core/providers/workspace_provider.dart';
import '../../../core/models/sync_device.dart';
import '../../../core/models/sync_record.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Sync management page — device identity, sync config, and sync history.
class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDeviceIdentity(context);
    });
  }

  Future<void> _ensureDeviceIdentity(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentDevice != null) return;
    await auth.ensureDeviceIdentity(
      platform: _detectPlatform(),
    );
  }

  String _detectPlatform() {
    // Simplified platform detection for UI display
    return 'desktop';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final sync = context.watch<SyncProvider>();
    final ws = context.watch<WorkspaceProvider>();
    final workspaceId = ws.currentWorkspace?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.RefreshCw, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.syncPageTitle),
          ],
        ),
        actions: [
          if (auth.isRegistered)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: sync.isSyncing
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : Icon(lucide.Lucide.RefreshCw, size: 14),
                label: Text(
                  sync.isSyncing
                      ? l10n.syncPageSyncing
                      : l10n.syncPageSyncNow,
                ),
                onPressed: sync.isSyncing
                    ? null
                    : () => _triggerSync(context, workspaceId),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeviceSection(auth: auth, l10n: l10n, cs: cs),
          const SizedBox(height: 16),
          _ConfigSection(sync: sync, l10n: l10n, cs: cs),
          const SizedBox(height: 16),
          _RecordsSection(
            sync: sync,
            workspaceId: workspaceId,
            l10n: l10n,
            cs: cs,
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSync(
    BuildContext context,
    String? workspaceId,
  ) async {
    final auth = context.read<AuthProvider>();
    final sync = context.read<SyncProvider>();
    final deviceId = auth.currentDevice?.id ?? '';
    await sync.startSync(
      deviceId: deviceId,
      workspaceId: workspaceId ?? '',
    );
    // Simulate sync completion (real HTTP relay sync is future work)
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      await sync.completeSync(
        itemsPushed: 0,
        itemsPulled: 0,
        conflictsResolved: 0,
      );
      await auth.updateLastSync();
    }
  }
}

/// Device identity and registration section.
class _DeviceSection extends StatelessWidget {
  final AuthProvider auth;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _DeviceSection({
    required this.auth,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final device = auth.currentDevice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Smartphone, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.syncPageDeviceSection,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (device != null) ...[
              _InfoRow(
                label: l10n.syncPageDeviceName,
                value: device.name,
                cs: cs,
              ),
              const SizedBox(height: 4),
              _InfoRow(
                label: l10n.syncPageDevicePlatform,
                value: device.platform,
                cs: cs,
              ),
              const SizedBox(height: 4),
              _InfoRow(
                label: l10n.syncPageDeviceId,
                value: device.id,
                cs: cs,
              ),
              const SizedBox(height: 4),
              _InfoRow(
                label: l10n.syncPageLastSync,
                value: _formatDate(device.lastSyncAt),
                cs: cs,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!auth.isRegistered)
                    FilledButton.icon(
                      icon: const Icon(lucide.Lucide.Shield, size: 14),
                      label: Text(l10n.syncPageRegister),
                      onPressed: () => _showRegisterDialog(context),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.syncPageRegistered,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(lucide.Lucide.LogOut, size: 14),
                      label: Text(l10n.syncPageUnregister),
                      onPressed: () => auth.unregisterDevice(),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: cs.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.syncPageRegisterTitle),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.syncPageRegisterHint,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.syncPageTokenLabel,
                  hintText: l10n.syncPageTokenHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.syncPageCancel),
          ),
          FilledButton(
            onPressed: () {
              final token = controller.text.trim();
              if (token.isNotEmpty) {
                context.read<AuthProvider>().registerDevice(token);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.syncPageConfirm),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

/// Sync configuration section with toggles.
class _ConfigSection extends StatelessWidget {
  final SyncProvider sync;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _ConfigSection({
    required this.sync,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = sync.config;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lucide.Lucide.Settings, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.syncPageConfigSection,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: AppFontWeights.semibold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              label: l10n.syncPageAutoSync,
              value: cfg.autoSyncEnabled,
              cs: cs,
              onChanged: (v) {
                sync.updateConfig(cfg.copyWith(autoSyncEnabled: v));
              },
            ),
            const Divider(height: 4),
            _ToggleRow(
              label: l10n.syncPageSyncWorkspaces,
              value: cfg.syncWorkspaces,
              cs: cs,
              onChanged: (v) {
                sync.updateConfig(cfg.copyWith(syncWorkspaces: v));
              },
            ),
            const Divider(height: 4),
            _ToggleRow(
              label: l10n.syncPageSyncAgents,
              value: cfg.syncAgents,
              cs: cs,
              onChanged: (v) {
                sync.updateConfig(cfg.copyWith(syncAgents: v));
              },
            ),
            const Divider(height: 4),
            _ToggleRow(
              label: l10n.syncPageSyncTasks,
              value: cfg.syncTasks,
              cs: cs,
              onChanged: (v) {
                sync.updateConfig(cfg.copyWith(syncTasks: v));
              },
            ),
            const Divider(height: 4),
            _ToggleRow(
              label: l10n.syncPageSyncChannels,
              value: cfg.syncChannels,
              cs: cs,
              onChanged: (v) {
                sync.updateConfig(cfg.copyWith(syncChannels: v));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Sync records / history section.
class _RecordsSection extends StatelessWidget {
  final SyncProvider sync;
  final String? workspaceId;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _RecordsSection({
    required this.sync,
    required this.workspaceId,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final records = sync.records;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  lucide.Lucide.Clock,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.syncPageHistorySection,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semibold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${records.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.syncPageNoRecords,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else
              ...records.reversed.take(20).map((record) {
                return _SyncRecordRow(record: record, cs: cs, l10n: l10n);
              }),
          ],
        ),
      ),
    );
  }
}

/// A single sync history record row.
class _SyncRecordRow extends StatelessWidget {
  final SyncRecord record;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _SyncRecordRow({
    required this.record,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusIcon = _statusIcon(record.status);
    final statusColor = _statusColor(record.status);
    final statusText = _statusText(record.status, l10n);

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
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  l10n.syncPageItemsSummary(
                    record.itemsPushed.toString(),
                    record.itemsPulled.toString(),
                    record.conflictsResolved.toString(),
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(record.duration),
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return lucide.Lucide.Loader;
      case SyncStatus.success:
        return lucide.Lucide.CheckCircle;
      case SyncStatus.failed:
        return lucide.Lucide.AlertCircle;
      case SyncStatus.paused:
        return lucide.Lucide.PauseCircle;
      case SyncStatus.idle:
        return lucide.Lucide.Circle;
    }
  }

  Color _statusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return cs.primary;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.failed:
        return cs.error;
      case SyncStatus.paused:
        return Colors.orange;
      case SyncStatus.idle:
        return cs.onSurface.withValues(alpha: 0.3);
    }
  }

  String _statusText(SyncStatus status, AppLocalizations l10n) {
    switch (status) {
      case SyncStatus.syncing:
        return l10n.syncStatusSyncing;
      case SyncStatus.success:
        return l10n.syncStatusSuccess;
      case SyncStatus.failed:
        return l10n.syncStatusFailed;
      case SyncStatus.paused:
        return l10n.syncStatusPaused;
      case SyncStatus.idle:
        return l10n.syncStatusIdle;
    }
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }
}

/// A row with a label and toggle switch.
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ColorScheme cs;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.cs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

/// An info label-value row.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}