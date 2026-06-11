import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_channel.dart';

/// Manages [AgentChannel] persistence and lifecycle.
///
/// Stores channels in SharedPreferences under the `agent_channels_v1` key.
/// Provides workspace-scoped queries and live [ChangeNotifier] updates.
class ChannelProvider extends ChangeNotifier {
  static const String _storageKey = 'agent_channels_v1';

  final List<AgentChannel> _channels = <AgentChannel>[];
  bool _loaded = false;

  /// All channels (unmodifiable).
  List<AgentChannel> get channels => List.unmodifiable(_channels);

  bool get isLoaded => _loaded;

  ChannelProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _channels.addAll(AgentChannel.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AgentChannel.encodeList(_channels));
  }

  /// Get channels for a workspace.
  List<AgentChannel> getChannelsForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_channels);
    return _channels
        .where((c) => c.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get channels bound to a specific agent.
  List<AgentChannel> getChannelsForAgent(String agentId) {
    return _channels
        .where((c) => c.agentId == agentId)
        .toList(growable: false);
  }

  /// Get a single channel by ID.
  AgentChannel? getById(String id) {
    final idx = _channels.indexWhere((c) => c.id == id);
    if (idx == -1) return null;
    return _channels[idx];
  }

  /// Create a new channel.
  Future<void> createChannel(AgentChannel channel) async {
    // Reject duplicate agent+type pair
    final exists = _channels.any(
      (c) => c.agentId == channel.agentId && c.type == channel.type,
    );
    if (exists) return;
    _channels.add(channel);
    await _persist();
    notifyListeners();
  }

  /// Update an existing channel.
  Future<void> updateChannel(String id, AgentChannel updates) async {
    final index = _channels.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _channels[index] = updates;
    await _persist();
    notifyListeners();
  }

  /// Delete a channel by ID.
  Future<void> deleteChannel(String id) async {
    _channels.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  /// Toggle enabled/disabled.
  Future<void> toggleEnabled(String id) async {
    final index = _channels.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final channel = _channels[index];
    _channels[index] = channel.copyWith(
      enabled: !channel.enabled,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Update channel config.
  Future<void> updateConfig(String id, Map<String, dynamic> newConfig) async {
    final index = _channels.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final channel = _channels[index];
    _channels[index] = channel.copyWith(
      configJson: jsonEncode(newConfig),
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Delete all channels for a workspace.
  Future<void> deleteChannelsForWorkspace(String workspaceId) async {
    _channels.removeWhere((c) => c.workspaceId == workspaceId);
    await _persist();
    notifyListeners();
  }
}