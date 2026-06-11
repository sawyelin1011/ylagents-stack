import 'dart:convert';

/// Represents a registered device for multi-device sync.
///
/// Each device has a unique ID, a human-readable name, its platform
/// (android, ios, macos, windows, linux, web), and tracking metadata
/// for the sync engine.
class SyncDevice {
  final String id;
  final String name;
  final String platform;
  final bool isCurrentDevice;
  final String authToken;
  final DateTime lastSyncAt;
  final DateTime registeredAt;

  SyncDevice({
    required this.id,
    required this.name,
    required this.platform,
    this.isCurrentDevice = false,
    this.authToken = '',
    DateTime? lastSyncAt,
    DateTime? registeredAt,
  }) : lastSyncAt = lastSyncAt ?? DateTime.now(),
       registeredAt = registeredAt ?? DateTime.now();

  SyncDevice copyWith({
    String? id,
    String? name,
    String? platform,
    bool? isCurrentDevice,
    String? authToken,
    DateTime? lastSyncAt,
    DateTime? registeredAt,
  }) {
    return SyncDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      authToken: authToken ?? this.authToken,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform,
    'isCurrentDevice': isCurrentDevice,
    if (authToken.isNotEmpty) 'authToken': authToken,
    'lastSyncAt': lastSyncAt.millisecondsSinceEpoch,
    'registeredAt': registeredAt.millisecondsSinceEpoch,
  };

  factory SyncDevice.fromJson(Map<String, dynamic> json) => SyncDevice(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? 'Unknown Device',
    platform: (json['platform'] as String?) ?? 'unknown',
    isCurrentDevice: (json['isCurrentDevice'] as bool?) ?? false,
    authToken: (json['authToken'] as String?) ?? '',
    lastSyncAt: DateTime.fromMillisecondsSinceEpoch(
      (json['lastSyncAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    registeredAt: DateTime.fromMillisecondsSinceEpoch(
      (json['registeredAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
  );

  static String encodeList(List<SyncDevice> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<SyncDevice> decodeList(String raw) {
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in arr) SyncDevice.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const <SyncDevice>[];
    }
  }
}
