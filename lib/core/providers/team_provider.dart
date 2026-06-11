import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_team.dart';

/// Manages [AgentTeam] persistence and lifecycle.
///
/// Stores teams in SharedPreferences under the `agent_teams_v1` key.
/// Provides workspace-scoped queries and live [ChangeNotifier] updates.
class TeamProvider extends ChangeNotifier {
  static const String _storageKey = 'agent_teams_v1';

  final List<AgentTeam> _teams = <AgentTeam>[];
  bool _loaded = false;

  /// All teams (unmodifiable).
  List<AgentTeam> get teams => List.unmodifiable(_teams);

  bool get isLoaded => _loaded;

  TeamProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _teams.addAll(AgentTeam.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AgentTeam.encodeList(_teams));
  }

  /// Get teams for a workspace.
  List<AgentTeam> getTeamsForWorkspace(String? workspaceId) {
    if (workspaceId == null) return List.unmodifiable(_teams);
    return _teams
        .where((t) => t.workspaceId == workspaceId)
        .toList(growable: false);
  }

  /// Get a single team by ID.
  AgentTeam? getById(String id) {
    final idx = _teams.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    return _teams[idx];
  }

  /// Create a new team.
  Future<void> createTeam(AgentTeam team) async {
    _teams.add(team);
    await _persist();
    notifyListeners();
  }

  /// Update an existing team.
  Future<void> updateTeam(String id, AgentTeam updates) async {
    final index = _teams.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _teams[index] = updates;
    await _persist();
    notifyListeners();
  }

  /// Delete a team by ID.
  Future<void> deleteTeam(String id) async {
    _teams.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  /// Add a member agent to a team.
  Future<void> addMember(String teamId, String agentId) async {
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index == -1) return;
    final team = _teams[index];
    if (team.memberAgentIds.contains(agentId)) return;
    _teams[index] = team.copyWith(
      memberAgentIds: [...team.memberAgentIds, agentId],
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Remove a member agent from a team.
  Future<void> removeMember(String teamId, String agentId) async {
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index == -1) return;
    final team = _teams[index];
    _teams[index] = team.copyWith(
      memberAgentIds: team.memberAgentIds.where((a) => a != agentId).toList(),
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Get the team that a specific agent leads.
  AgentTeam? getTeamLedByAgent(String agentId) {
    final idx = _teams.indexWhere((t) => t.leadAgentId == agentId);
    if (idx == -1) return null;
    return _teams[idx];
  }

  /// Get all teams that a specific agent is a member of.
  List<AgentTeam> getTeamsForAgent(String agentId) {
    return _teams
        .where((t) => t.memberAgentIds.contains(agentId))
        .toList(growable: false);
  }

  /// Delete all teams for a workspace.
  Future<void> deleteTeamsForWorkspace(String workspaceId) async {
    _teams.removeWhere((t) => t.workspaceId == workspaceId);
    await _persist();
    notifyListeners();
  }
}
