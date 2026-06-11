import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// How often a scheduled task should repeat.
enum ScheduleInterval {
  once,
  hourly,
  daily,
  weekly,
  monthly;

  static ScheduleInterval fromJson(String value) {
    return ScheduleInterval.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScheduleInterval.once,
    );
  }

  String toJson() => name;

  Duration get duration {
    switch (this) {
      case ScheduleInterval.once:
        return Duration.zero;
      case ScheduleInterval.hourly:
        return const Duration(hours: 1);
      case ScheduleInterval.daily:
        return const Duration(days: 1);
      case ScheduleInterval.weekly:
        return const Duration(days: 7);
      case ScheduleInterval.monthly:
        return const Duration(days: 30);
    }
  }
}

/// A scheduled agent execution.
///
/// Associates an agent ID with a cron-like interval. The scheduler
/// checks due schedules and triggers agent execution in the background.
class ScheduledRun {
  final String id;
  final String agentId;
  final String agentName;
  final String workspaceId;
  final String taskTitle;
  final ScheduleInterval interval;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;

  ScheduledRun({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.workspaceId,
    this.taskTitle = '',
    this.interval = ScheduleInterval.daily,
    this.enabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastRunAt,
    this.nextRunAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ScheduledRun copyWith({
    String? id,
    String? agentId,
    String? agentName,
    String? workspaceId,
    String? taskTitle,
    ScheduleInterval? interval,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
    bool clearLastRun = false,
    bool clearNextRun = false,
  }) {
    return ScheduledRun(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      workspaceId: workspaceId ?? this.workspaceId,
      taskTitle: taskTitle ?? this.taskTitle,
      interval: interval ?? this.interval,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastRunAt: clearLastRun ? null : (lastRunAt ?? this.lastRunAt),
      nextRunAt: clearNextRun ? null : (nextRunAt ?? this.nextRunAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agentId': agentId,
    'agentName': agentName,
    'workspaceId': workspaceId,
    'taskTitle': taskTitle,
    'interval': interval.toJson(),
    'enabled': enabled,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    if (lastRunAt != null) 'lastRunAt': lastRunAt!.millisecondsSinceEpoch,
    if (nextRunAt != null) 'nextRunAt': nextRunAt!.millisecondsSinceEpoch,
  };

  factory ScheduledRun.fromJson(Map<String, dynamic> json) => ScheduledRun(
    id: json['id'] as String,
    agentId: (json['agentId'] as String?) ?? '',
    agentName: (json['agentName'] as String?) ?? '',
    workspaceId: (json['workspaceId'] as String?) ?? '',
    taskTitle: (json['taskTitle'] as String?) ?? '',
    interval: ScheduleInterval.fromJson(
      (json['interval'] as String?) ?? 'daily',
    ),
    enabled: (json['enabled'] as bool?) ?? true,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updatedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    lastRunAt: json['lastRunAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (json['lastRunAt'] as num).toInt(),
          )
        : null,
    nextRunAt: json['nextRunAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (json['nextRunAt'] as num).toInt(),
          )
        : null,
  );

  static String encodeList(List<ScheduledRun> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ScheduledRun> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr) ScheduledRun.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <ScheduledRun>[];
    }
  }
}

/// Manages scheduled agent executions.
///
/// Uses a periodic timer to check for due schedules and trigger
/// agent execution callbacks. Persists schedules to SharedPreferences.
class SchedulerService extends ChangeNotifier {
  static const String _storageKey = 'scheduled_runs_v1';

  final Uuid _uuid = const Uuid();
  final List<ScheduledRun> _schedules = <ScheduledRun>[];
  Timer? _tickTimer;
  bool _loaded = false;
  bool _running = false;

  /// Callback invoked when a scheduled run is due.
  /// Receives (ScheduledRun, workspaceId).
  void Function(ScheduledRun schedule)? onScheduleDue;

  List<ScheduledRun> get schedules => List.unmodifiable(_schedules);
  bool get isLoaded => _loaded;
  bool get isRunning => _running;

  SchedulerService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _schedules.addAll(ScheduledRun.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, ScheduledRun.encodeList(_schedules));
  }

  /// Start the scheduler tick timer.
  /// Checks for due schedules every 60 seconds.
  void start() {
    if (_running) return;
    _running = true;
    _tickTimer = Timer.periodic(const Duration(seconds: 60), (_) => _tick());
    notifyListeners();
  }

  /// Stop the scheduler tick timer.
  void stop() {
    _running = false;
    _tickTimer?.cancel();
    _tickTimer = null;
    notifyListeners();
  }

  void _tick() {
    final now = DateTime.now();
    for (final schedule in _schedules) {
      if (!schedule.enabled) continue;
      if (schedule.nextRunAt != null && !now.isBefore(schedule.nextRunAt!)) {
        onScheduleDue?.call(schedule);
        _advanceSchedule(schedule);
      }
    }
  }

  void _advanceSchedule(ScheduledRun schedule) {
    final now = DateTime.now();
    final nextRun = schedule.interval == ScheduleInterval.once
        ? null
        : now.add(schedule.interval.duration);
    _updateSchedule(
      schedule.copyWith(lastRunAt: now, nextRunAt: nextRun, updatedAt: now),
    );
  }

  /// Get schedules for a workspace.
  List<ScheduledRun> getSchedulesForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_schedules);
    return _schedules
        .where((s) => s.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get schedules for a specific agent.
  List<ScheduledRun> getSchedulesForAgent(String agentId) {
    return _schedules
        .where((s) => s.agentId == agentId)
        .toList(growable: false);
  }

  /// Create a new schedule.
  Future<ScheduledRun> createSchedule({
    required String agentId,
    required String agentName,
    required String workspaceId,
    String taskTitle = '',
    ScheduleInterval interval = ScheduleInterval.daily,
  }) async {
    final now = DateTime.now();
    final nextRun = interval == ScheduleInterval.once
        ? now
        : now.add(interval.duration);
    final schedule = ScheduledRun(
      id: _uuid.v4(),
      agentId: agentId,
      agentName: agentName,
      workspaceId: workspaceId,
      taskTitle: taskTitle,
      interval: interval,
      nextRunAt: nextRun,
      createdAt: now,
      updatedAt: now,
    );
    _schedules.add(schedule);
    await _persist();
    notifyListeners();
    return schedule;
  }

  /// Update an existing schedule.
  Future<void> updateSchedule(ScheduledRun updated) async {
    final idx = _schedules.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;
    _schedules[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _persist();
    notifyListeners();
  }

  /// Enable or disable a schedule.
  Future<void> _updateSchedule(ScheduledRun updated) async {
    final idx = _schedules.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;
    _schedules[idx] = updated;
    await _persist();
    notifyListeners();
  }

  /// Toggle enabled state.
  Future<void> toggleEnabled(String scheduleId) async {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    if (idx == -1) return;
    final s = _schedules[idx];
    _schedules[idx] = s.copyWith(
      enabled: !s.enabled,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Delete a schedule.
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  /// Delete all schedules for a workspace.
  Future<void> deleteSchedulesForWorkspace(String workspaceId) async {
    _schedules.removeWhere((s) => s.workspaceId == workspaceId);
    await _persist();
    notifyListeners();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
