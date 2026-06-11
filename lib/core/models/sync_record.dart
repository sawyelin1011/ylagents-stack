import 'dart:convert';

/// The current status of a sync operation.
enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  paused;

  static SyncStatus fromJson(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncStatus.idle,
    );
  }

  String toJson() => name;
}

/// A record of a sync operation, tracking what was synced and when.
///
/// Each record captures the scope (workspace or global), the number of
/// items pushed and pulled, and the final status.
class SyncRecord {
  final String id;
  final String deviceId;
  final String workspaceId;
  final SyncStatus status;
  final int itemsPushed;
  final int itemsPulled;
  final int conflictsResolved;
  final String errorMessage;
  final DateTime startedAt;
  final DateTime completedAt;

  SyncRecord({
    required this.id,
    required this.deviceId,
    this.workspaceId = '',
    this.status = SyncStatus.idle,
    this.itemsPushed = 0,
    this.itemsPulled = 0,
    this.conflictsResolved = 0,
    this.errorMessage = '',
    DateTime? startedAt,
    DateTime? completedAt,
  }) : startedAt = startedAt ?? DateTime.now(),
       completedAt = completedAt ?? DateTime.now();

  Duration get duration => completedAt.difference(startedAt);

  SyncRecord copyWith({
    String? id,
    String? deviceId,
    String? workspaceId,
    SyncStatus? status,
    int? itemsPushed,
    int? itemsPulled,
    int? conflictsResolved,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearError = false,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      workspaceId: workspaceId ?? this.workspaceId,
      status: status ?? this.status,
      itemsPushed: itemsPushed ?? this.itemsPushed,
      itemsPulled: itemsPulled ?? this.itemsPulled,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'workspaceId': workspaceId,
    'status': status.toJson(),
    'itemsPushed': itemsPushed,
    'itemsPulled': itemsPulled,
    'conflictsResolved': conflictsResolved,
    if (errorMessage.isNotEmpty) 'errorMessage': errorMessage,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  factory SyncRecord.fromJson(Map<String, dynamic> json) => SyncRecord(
    id: json['id'] as String,
    deviceId: (json['deviceId'] as String?) ?? '',
    workspaceId: (json['workspaceId'] as String?) ?? '',
    status: SyncStatus.fromJson((json['status'] as String?) ?? ''),
    itemsPushed: (json['itemsPushed'] as num?)?.toInt() ?? 0,
    itemsPulled: (json['itemsPulled'] as num?)?.toInt() ?? 0,
    conflictsResolved: (json['conflictsResolved'] as num?)?.toInt() ?? 0,
    errorMessage: (json['errorMessage'] as String?) ?? '',
    startedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['startedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    completedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['completedAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  static String encodeList(List<SyncRecord> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<SyncRecord> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr) SyncRecord.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <SyncRecord>[];
    }
  }
}
