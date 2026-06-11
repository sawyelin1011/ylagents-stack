import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent.dart';
import '../models/agent_genome.dart';
import '../models/assistant.dart';
import '../providers/assistant_provider.dart';

/// Manages Agent-level data (genome, type, enabled status).
///
/// Works alongside [AssistantProvider] — each Agent shares the same [id]
/// as its underlying [Assistant]. Genome data is stored separately in
/// SharedPreferences under `agents_v1`.
///
/// Key responsibilities:
///   - Promote an [Assistant] to an [Agent] (with genome fields)
///   - Update agent genome, type, enabled status
///   - List agents in the current workspace
class AgentProvider extends ChangeNotifier {
  static const String _agentsKey = 'agents_v1';

  final List<Agent> _agents = <Agent>[];
  final AssistantProvider _assistantProvider;
  bool _loaded = false;

  /// Unmodifiable view of all agents.
  UnmodifiableListView<Agent> get agents => UnmodifiableListView(_agents);

  /// Whether the provider has finished loading from disk.
  bool get loaded => _loaded;

  /// Reference to the underlying AssistantProvider.
  AssistantProvider get assistantProvider => _assistantProvider;

  AgentProvider(this._assistantProvider) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_agentsKey);
    if (raw != null && raw.isNotEmpty) {
      _agents.addAll(Agent.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_agentsKey, Agent.encodeList(_agents));
  }

  /// Get an agent by ID.
  Agent? getById(String id) {
    final idx = _agents.indexWhere((a) => a.id == id);
    if (idx == -1) return null;
    return _agents[idx];
  }

  /// Check if an assistant has been promoted to an agent.
  bool isAgent(String assistantId) {
    return _agents.any((a) => a.id == assistantId);
  }

  /// Promote an [Assistant] to an [Agent] with optional genome data.
  ///
  /// If the assistant is already an agent, updates the existing record.
  Future<void> promoteToAgent(
    String assistantId, {
    AgentType type = AgentType.standard,
    AgentGenome genome = AgentGenome.empty,
  }) async {
    final idx = _agents.indexWhere((a) => a.id == assistantId);
    final assistant = _assistantProvider.getById(assistantId);
    if (assistant == null) return;

    if (idx != -1) {
      // Already an agent — update
      _agents[idx] = _agents[idx].copyWith(type: type, genome: genome);
    } else {
      _agents.add(
        Agent(
          id: assistantId,
          name: assistant.name,
          type: type,
          genome: genome,
        ),
      );
    }
    await _persist();
    notifyListeners();
  }

  /// Demote an agent back to a plain Assistant (removes genome data).
  Future<void> demoteFromAgent(String assistantId) async {
    _agents.removeWhere((a) => a.id == assistantId);
    await _persist();
    notifyListeners();
  }

  /// Update the genome for an existing agent.
  Future<void> updateGenome(String assistantId, AgentGenome genome) async {
    final idx = _agents.indexWhere((a) => a.id == assistantId);
    if (idx == -1) return;

    _agents[idx] = _agents[idx].copyWith(genome: genome);
    await _persist();
    notifyListeners();
  }

  /// Update the agent type.
  Future<void> updateType(String assistantId, AgentType type) async {
    final idx = _agents.indexWhere((a) => a.id == assistantId);
    if (idx == -1) return;

    _agents[idx] = _agents[idx].copyWith(type: type);
    await _persist();
    notifyListeners();
  }

  /// Toggle enabled status.
  Future<void> toggleEnabled(String assistantId) async {
    final idx = _agents.indexWhere((a) => a.id == assistantId);
    if (idx == -1) return;

    _agents[idx] = _agents[idx].copyWith(enabled: !_agents[idx].enabled);
    await _persist();
    notifyListeners();
  }

  /// Sync agent names from their underlying assistants (e.g. after rename).
  void syncNames() {
    bool changed = false;
    for (int i = 0; i < _agents.length; i++) {
      final assistant = _assistantProvider.getById(_agents[i].id);
      if (assistant != null && assistant.name != _agents[i].name) {
        _agents[i] = _agents[i].copyWith(name: assistant.name);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      // Fire-and-forget persist
      _persist();
    }
  }

  /// Get all agents that match the given workspace ID (via underlying assistants).
  List<Agent> getAgentsForWorkspace(String workspaceId) {
    return _agents.where((agent) {
      final assistant = _assistantProvider.getById(agent.id);
      return assistant != null &&
          (assistant.workspaceId == null ||
              assistant.workspaceId == workspaceId);
    }).toList();
  }

  /// Get the lead agent for a workspace (if any).
  Agent? getLeadAgentForWorkspace(String workspaceId) {
    final agents = getAgentsForWorkspace(workspaceId);
    try {
      return agents.firstWhere((a) => a.type == AgentType.lead);
    } catch (_) {
      return null;
    }
  }

  /// Remove agent records for deleted assistants.
  Future<void> cleanupDeletedAssistants(Set<String> validAssistantIds) async {
    final before = _agents.length;
    _agents.removeWhere((a) => !validAssistantIds.contains(a.id));
    if (_agents.length != before) {
      await _persist();
      notifyListeners();
    }
  }
}
