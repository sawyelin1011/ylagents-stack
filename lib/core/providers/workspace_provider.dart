import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/workspace.dart';
import '../models/workspace_settings.dart';
import '../services/chat/chat_service.dart';

/// Manages workspace CRUD, selection, and persistence.
///
/// Workspaces are stored as a JSON array in SharedPreferences under `workspaces_v1`.
/// This matches the existing pattern used by [AssistantProvider] for assistant storage.
class WorkspaceProvider extends ChangeNotifier {
  static const String _workspacesKey = 'workspaces_v1';
  static const String _currentWorkspaceKey = 'current_workspace_id_v1';

  final List<Workspace> _workspaces = <Workspace>[];
  String? _currentWorkspaceId;
  bool _loaded = false;

  /// Unmodifiable view of all workspaces.
  UnmodifiableListView<Workspace> get workspaces =>
      UnmodifiableListView(_workspaces);

  /// Whether the provider has finished loading from disk.
  bool get loaded => _loaded;

  /// The ID of the currently selected workspace.
  String? get currentWorkspaceId => _currentWorkspaceId;

  /// The currently selected workspace, or the first workspace if none selected.
  Workspace? get currentWorkspace {
    if (_currentWorkspaceId != null) {
      final idx = _workspaces.indexWhere((w) => w.id == _currentWorkspaceId);
      if (idx != -1) return _workspaces[idx];
    }
    if (_workspaces.isNotEmpty) return _workspaces.first;
    return null;
  }

  WorkspaceProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_workspacesKey);

    if (raw != null && raw.isNotEmpty) {
      _workspaces.addAll(Workspace.decodeList(raw));
    }

    // Restore current workspace if present
    final savedId = prefs.getString(_currentWorkspaceKey);
    if (savedId != null && _workspaces.any((w) => w.id == savedId)) {
      _currentWorkspaceId = savedId;
    } else if (_workspaces.isNotEmpty) {
      _currentWorkspaceId = _workspaces.first.id;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workspacesKey, Workspace.encodeList(_workspaces));
  }

  /// Select a workspace by ID.
  Future<void> setCurrentWorkspace(String id) async {
    if (_currentWorkspaceId == id) return;
    if (!_workspaces.any((w) => w.id == id)) return;

    _currentWorkspaceId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentWorkspaceKey, id);
  }

  /// Get a workspace by ID.
  Workspace? getById(String id) {
    final idx = _workspaces.indexWhere((w) => w.id == id);
    if (idx == -1) return null;
    return _workspaces[idx];
  }

  /// Create a new workspace.
  ///
  /// Returns the new workspace ID.
  Future<String> createWorkspace({
    required String name,
    WorkspaceType type = WorkspaceType.personal,
    String description = '',
  }) async {
    final now = DateTime.now();
    final workspace = Workspace(
      id: const Uuid().v4(),
      name: name,
      type: type,
      description: description,
      createdAt: now,
      updatedAt: now,
    );

    _workspaces.add(workspace);

    // Auto-select the new workspace if this is the only one
    if (_workspaces.length == 1) {
      _currentWorkspaceId = workspace.id;
    }

    await _persist();
    notifyListeners();
    return workspace.id;
  }

  /// Update an existing workspace.
  Future<void> updateWorkspace(Workspace updated) async {
    final idx = _workspaces.indexWhere((w) => w.id == updated.id);
    if (idx == -1) return;

    _workspaces[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _persist();
    notifyListeners();
  }

  /// Delete a workspace by ID.
  ///
  /// Returns false if it's the last remaining workspace (cannot delete).
  Future<bool> deleteWorkspace(String id) async {
    final idx = _workspaces.indexWhere((w) => w.id == id);
    if (idx == -1) return false;

    // Do not allow deleting the last remaining workspace
    if (_workspaces.length <= 1) return false;

    final wasCurrent = _workspaces[idx].id == _currentWorkspaceId;
    _workspaces.removeAt(idx);

    if (wasCurrent || _currentWorkspaceId == id) {
      _currentWorkspaceId = _workspaces.isNotEmpty
          ? _workspaces.first.id
          : null;
    }

    await _persist();
    final prefs = await SharedPreferences.getInstance();
    if (_currentWorkspaceId != null) {
      await prefs.setString(_currentWorkspaceKey, _currentWorkspaceId!);
    } else {
      await prefs.remove(_currentWorkspaceKey);
    }
    notifyListeners();
    return true;
  }

  /// Get settings for the current workspace, or empty defaults if none.
  WorkspaceSettings get currentWorkspaceSettings =>
      currentWorkspace?.settings ?? WorkspaceSettings.empty;

  /// Get settings for a specific workspace, or empty defaults.
  WorkspaceSettings getWorkspaceSettings(String workspaceId) {
    final ws = getById(workspaceId);
    return ws?.settings ?? WorkspaceSettings.empty;
  }

  /// Update settings for a workspace (merges with existing).
  Future<void> updateWorkspaceSettings(
    String workspaceId,
    WorkspaceSettings newSettings,
  ) async {
    final idx = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (idx == -1) return;

    final existing = _workspaces[idx].settings;
    _workspaces[idx] = _workspaces[idx].copyWith(
      settings: existing != null
          ? existing.copyWith(
              defaultAssistantId: newSettings.defaultAssistantId,
              defaultModelProvider: newSettings.defaultModelProvider,
              defaultModelId: newSettings.defaultModelId,
              mcpServerIds: newSettings.mcpServerIds,
              localToolIds: newSettings.localToolIds,
            )
          : newSettings,
    );
    await _persist();
    notifyListeners();
  }

  /// Clear all settings overrides for a workspace (revert to global defaults).
  Future<void> clearWorkspaceSettings(String workspaceId) async {
    final idx = _workspaces.indexWhere((w) => w.id == workspaceId);
    if (idx == -1) return;

    _workspaces[idx] = _workspaces[idx].copyWith(clearSettings: true);
    await _persist();
    notifyListeners();
  }

  /// Ensure at least a "Personal" workspace exists.
  ///
  /// Called after localization is available (matching [AssistantProvider.ensureDefaults]).
  Future<void> ensurePersonalWorkspace(String localizedName) async {
    if (_workspaces.isNotEmpty) return;

    await createWorkspace(name: localizedName, type: WorkspaceType.personal);
  }

  /// Migrate legacy assistants and conversations to the Personal workspace.
  ///
  /// Assigns [workspaceId] to all assistants and conversations that have null
  /// workspaceId. This handles the Kelivo → YLAgents migration path.
  Future<void> migrateLegacyData({
    required String personalWorkspaceId,
    required List<String> unassignedAssistantIds,
    required ChatService chatService,
    Future<void> Function(String assistantId, String workspaceId)?
    onUpdateAssistant,
  }) async {
    // Migrate assistants
    if (onUpdateAssistant != null) {
      for (final assistantId in unassignedAssistantIds) {
        await onUpdateAssistant(assistantId, personalWorkspaceId);
      }
    }

    // Migrate conversations via ChatService
    await chatService.assignUnassignedConversationsToWorkspace(
      personalWorkspaceId,
    );
  }
}
