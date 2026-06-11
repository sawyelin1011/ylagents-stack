import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';

/// Manages [Skill] installation, listing, and removal.
///
/// Skills are stored in SharedPreferences under `installed_skills_v1`.
/// Provides workspace-agnostic listing and CRUD.
class SkillProvider extends ChangeNotifier {
  static const String _storageKey = 'installed_skills_v1';

  final List<Skill> _skills = <Skill>[];
  bool _loaded = false;

  /// All installed skills (unmodifiable).
  List<Skill> get skills => List.unmodifiable(_skills);

  bool get isLoaded => _loaded;

  SkillProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _skills.addAll(Skill.decodeList(raw));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Skill.encodeList(_skills));
  }

  /// Get all available skills.
  List<Skill> getAll() => List.unmodifiable(_skills);

  /// Get a skill by ID.
  Skill? getById(String id) {
    final idx = _skills.indexWhere((s) => s.id == id);
    if (idx == -1) return null;
    return _skills[idx];
  }

  /// Install a new skill.
  Future<void> install(Skill skill) async {
    // Replace if already installed
    final existing = _skills.indexWhere((s) => s.id == skill.id);
    if (existing >= 0) {
      _skills[existing] = skill;
    } else {
      _skills.add(skill);
    }
    await _persist();
    notifyListeners();
  }

  /// Uninstall a skill by ID.
  Future<void> uninstall(String id) async {
    _skills.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  /// Check if a skill is already installed.
  bool isInstalled(String id) => _skills.any((s) => s.id == id);

  /// Get skills filtered by a tag.
  List<Skill> getByTag(String tag) {
    return _skills.where((s) => s.tags.contains(tag)).toList(growable: false);
  }

  /// Bulk install skills (e.g. from marketplace or import).
  Future<void> installAll(List<Skill> skills) async {
    for (final skill in skills) {
      final existing = _skills.indexWhere((s) => s.id == skill.id);
      if (existing >= 0) {
        _skills[existing] = skill;
      } else {
        _skills.add(skill);
      }
    }
    await _persist();
    notifyListeners();
  }

  /// Count of installed skills.
  int get count => _skills.length;
}
