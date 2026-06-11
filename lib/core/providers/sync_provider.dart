import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_record.dart';

/// Configuration for the sync engine.
///
/// Controls whether auto-sync is enabled, the relay server URL,
/// and which data types participate in sync.
class SyncConfig {
  final bool autoSyncEnabled;
  final String relayServerUrl;
  final int syncIntervalMinutes;
  final bool syncWorkspaces;
  final bool syncAgents;
  final bool syncTasks;
  final bool syncChannels;
  final bool syncSkills;

  const SyncConfig({
    this.autoSyncEnabled = false,
    this.relayServerUrl = '',
    this.syncIntervalMinutes = 30,
    this.syncWorkspaces = true,
    this.syncAgents = true,
    this.syncTasks = true,
    this.syncChannels = true,
    this.syncSkills = true,
  });

  SyncConfig copyWith({
    bool? autoSyncEnabled,
    String? relayServerUrl,
    int? syncIntervalMinutes,
    bool? syncWorkspaces,
    bool? syncAgents,
    bool? syncTasks,
    bool? syncChannels,
    bool? syncSkills,
    bool clearUrl = false,
  }) {
    return SyncConfig(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      relayServerUrl: clearUrl ? '' : (relayServerUrl ?? this.relayServerUrl),
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      syncWorkspaces: syncWorkspaces ?? this.syncWorkspaces,
      syncAgents: syncAgents ?? this.syncAgents,
      syncTasks: syncTasks ?? this.syncTasks,
      syncChannels: syncChannels ?? this.syncChannels,
      syncSkills: syncSkills ?? this.syncSkills,
    );
  }

  Map<String, dynamic> toJson() => {
    'autoSyncEnabled': autoSyncEnabled,
    'relayServerUrl': relayServerUrl,
    'syncIntervalMinutes': syncIntervalMinutes,
    'syncWorkspaces': syncWorkspaces,
    'syncAgents': syncAgents,
    'syncTasks': syncTasks,
    'syncChannels': syncChannels,
    'syncSkills': syncSkills,
  };

  factory SyncConfig.fromJson(Map<String, dynamic> json) => SyncConfig(
    autoSyncEnabled: (json['autoSyncEnabled'] as bool?) ?? false,
    relayServerUrl: (json['relayServerUrl'] as String?) ?? '',
    syncIntervalMinutes: (json['syncIntervalMinutes'] as num?)?.toInt() ?? 30,
    syncWorkspaces: (json['syncWorkspaces'] as bool?) ?? true,
    syncAgents: (json['syncAgents'] as bool?) ?? true,
    syncTasks: (json['syncTasks'] as bool?) ?? true,
    syncChannels: (json['syncChannels'] as bool?) ?? true,
    syncSkills: (json['syncSkills'] as bool?) ?? true,
  );
}

/// Manages the sync engine for multi-device data synchronization.
///
/// Tracks sync operations via [SyncRecord], provides workspace-scoped
/// queries, and persists sync history to SharedPreferences.
/// Currently operates in local-only mode — actual HTTP relay sync
/// will be wired in a future enhancement.
class SyncProvider extends ChangeNotifier {
  static const String _configKey = 'sync_config_v1';
  static const String _recordsKey = 'sync_records_v1';

  final Uuid _uuid = const Uuid();
  SyncConfig _config = const SyncConfig();
  final List<SyncRecord> _records = <SyncRecord>[];
  bool _loaded = false;

  SyncConfig get config => _config;
  List<SyncRecord> get records => List.unmodifiable(_records);
  bool get isLoaded => _loaded;

  /// The most recent sync record, if any.
  SyncRecord? get lastSync => _records.isNotEmpty ? _records.last : null;

  /// Whether sync is currently in progress.
  bool get isSyncing =>
      _records.isNotEmpty && _records.last.status == SyncStatus.syncing;

  SyncProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final configRaw = prefs.getString(_configKey);
    if (configRaw != null && configRaw.isNotEmpty) {
      try {
        _config =
            SyncConfig.fromJson(
              jsonDecode(configRaw) as Map<String, dynamic>,
            );
      } catch (_) {}
    }
    final recordsRaw = prefs.getString(_recordsKey);
    if (recordsRaw != null && recordsRaw.isNotEmpty) {
      _records.addAll(SyncRecord.decodeList(recordsRaw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(_config.toJson()));
  }

  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recordsKey, SyncRecord.encodeList(_records));
  }

  /// Update the sync configuration.
  Future<void> updateConfig(SyncConfig newConfig) async {
    _config = newConfig;
    await _persistConfig();
    notifyListeners();
  }

  /// Start a sync operation.
  /// Creates a new SyncRecord with status [SyncStatus.syncing].
  Future<void> startSync({String deviceId = '', String workspaceId = ''}) async {
    final record = SyncRecord(
      id: _uuid.v4(),
      deviceId: deviceId,
      workspaceId: workspaceId,
      status: SyncStatus.syncing,
    );
    _records.add(record);
    await _persistRecords();
    notifyListeners();
  }

  /// Complete a sync operation with the given counts.
  Future<void> completeSync({
    int itemsPushed = 0,
    int itemsPulled = 0,
    int conflictsResolved = 0,
  }) async {
    if (_records.isEmpty) return;
    final last = _records.last;
    final updated = last.copyWith(
      status: SyncStatus.success,
      itemsPushed: itemsPushed,
      itemsPulled: itemsPulled,
      conflictsResolved: conflictsResolved,
      completedAt: DateTime.now(),
    );
    _records[_records.length - 1] = updated;
    await _persistRecords();
    notifyListeners();
  }

  /// Mark the current sync as failed.
  Future<void> failSync({String errorMessage = ''}) async {
    if (_records.isEmpty) return;
    final last = _records.last;
    final updated = last.copyWith(
      status: SyncStatus.failed,
      errorMessage: errorMessage,
      completedAt: DateTime.now(),
    );
    _records[_records.length - 1] = updated;
    await _persistRecords();
    notifyListeners();
  }

  /// Get sync records for a workspace.
  List<SyncRecord> getRecordsForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_records);
    return _records
        .where((r) => r.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get sync records for a specific device.
  List<SyncRecord> getRecordsForDevice(String deviceId) {
    return _records
        .where((r) => r.deviceId == deviceId)
        .toList(growable: false);
  }

  /// Clear all sync records.
  Future<void> clearRecords() async {
    _records.clear();
    await _persistRecords();
    notifyListeners();
  }

  /// Delete sync records older than the given date.
  Future<void> pruneRecordsOlderThan(DateTime cutoff) async {
    _records.removeWhere((r) => r.startedAt.isBefore(cutoff));
    await _persistRecords();
    notifyListeners();
  }
}