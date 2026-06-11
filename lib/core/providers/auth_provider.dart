import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_device.dart';

/// Manages device identity and authentication for multi-device sync.
///
/// Each device generates a unique device ID on first launch and optionally
/// registers with a remote sync relay server. Auth tokens are stored
/// alongside device metadata in SharedPreferences.
class AuthProvider extends ChangeNotifier {
  static const String _deviceKey = 'sync_device_v1';
  static const String _devicesKey = 'sync_devices_list_v1';

  final Uuid _uuid = const Uuid();

  /// The current device's identity.
  SyncDevice? _currentDevice;

  /// Known devices (including this one).
  final List<SyncDevice> _knownDevices = <SyncDevice>[];
  bool _loaded = false;

  SyncDevice? get currentDevice => _currentDevice;
  List<SyncDevice> get knownDevices => List.unmodifiable(_knownDevices);
  bool get isLoaded => _loaded;

  /// Whether the current device is registered for sync.
  bool get isRegistered =>
      _currentDevice != null && _currentDevice!.authToken.isNotEmpty;

  AuthProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceRaw = prefs.getString(_deviceKey);
    if (deviceRaw != null && deviceRaw.isNotEmpty) {
      try {
        _currentDevice = SyncDevice.fromJson(
          jsonDecode(deviceRaw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    final devicesRaw = prefs.getString(_devicesKey);
    if (devicesRaw != null && devicesRaw.isNotEmpty) {
      _knownDevices.addAll(SyncDevice.decodeList(devicesRaw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistCurrentDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceKey, jsonEncode(_currentDevice!.toJson()));
  }

  Future<void> _persistDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_devicesKey, SyncDevice.encodeList(_knownDevices));
  }

  /// Ensure this device has an identity.
  /// Called on first launch to generate a device ID and name.
  Future<void> ensureDeviceIdentity({
    String name = '',
    String platform = 'unknown',
  }) async {
    if (_currentDevice != null) return;
    final id = _uuid.v4();
    final deviceName = name.isNotEmpty
        ? name
        : 'Device ${_knownDevices.length + 1}';
    _currentDevice = SyncDevice(
      id: id,
      name: deviceName,
      platform: platform,
      isCurrentDevice: true,
    );
    _knownDevices.add(_currentDevice!);
    await _persistCurrentDevice();
    await _persistDevices();
    notifyListeners();
  }

  /// Register this device with the sync server by setting an auth token.
  Future<void> registerDevice(String token) async {
    if (_currentDevice == null) return;
    _currentDevice = _currentDevice!.copyWith(authToken: token);
    final idx = _knownDevices.indexWhere((d) => d.id == _currentDevice!.id);
    if (idx != -1) {
      _knownDevices[idx] = _currentDevice!;
    }
    await _persistCurrentDevice();
    await _persistDevices();
    notifyListeners();
  }

  /// Unregister this device (clear auth token).
  Future<void> unregisterDevice() async {
    if (_currentDevice == null) return;
    _currentDevice = _currentDevice!.copyWith(authToken: '');
    final idx = _knownDevices.indexWhere((d) => d.id == _currentDevice!.id);
    if (idx != -1) {
      _knownDevices[idx] = _currentDevice!;
    }
    await _persistCurrentDevice();
    await _persistDevices();
    notifyListeners();
  }

  /// Update the last sync timestamp for this device.
  Future<void> updateLastSync() async {
    if (_currentDevice == null) return;
    final now = DateTime.now();
    _currentDevice = _currentDevice!.copyWith(lastSyncAt: now);
    final idx = _knownDevices.indexWhere((d) => d.id == _currentDevice!.id);
    if (idx != -1) {
      _knownDevices[idx] = _currentDevice!;
    }
    await _persistCurrentDevice();
    await _persistDevices();
    notifyListeners();
  }

  /// Rename the current device.
  Future<void> renameDevice(String newName) async {
    if (_currentDevice == null) return;
    _currentDevice = _currentDevice!.copyWith(name: newName);
    final idx = _knownDevices.indexWhere((d) => d.id == _currentDevice!.id);
    if (idx != -1) {
      _knownDevices[idx] = _currentDevice!;
    }
    await _persistCurrentDevice();
    await _persistDevices();
    notifyListeners();
  }

  /// Remove a known device by ID (cannot remove current device).
  Future<void> removeDevice(String deviceId) async {
    if (_currentDevice != null && deviceId == _currentDevice!.id) return;
    _knownDevices.removeWhere((d) => d.id == deviceId);
    await _persistDevices();
    notifyListeners();
  }
}
