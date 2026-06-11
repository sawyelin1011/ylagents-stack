import 'dart:convert';
import '../models/skill.dart';
import '../providers/skill_provider.dart';

/// Handles Skill import and export in JSON manifest format.
///
/// Skills can be exported as a JSON manifest string (for clipboard, file, or
/// network transfer). Import validates the manifest before installing.
class SkillImportExportService {
  final SkillProvider skillProvider;

  SkillImportExportService({required this.skillProvider});

  /// Export a single skill to a JSON manifest string.
  String exportSkill(Skill skill) {
    return const JsonEncoder.withIndent('  ').convert(skill.toJson());
  }

  /// Export multiple skills to a JSON manifest string.
  String exportSkills(List<Skill> skills) {
    final list = skills.map((s) => s.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Import a skill from a JSON manifest string.
  ///
  /// Returns the imported [Skill] on success, or throws a [FormatException].
  Skill importFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      if (data is List) {
        if (data.isEmpty) throw const FormatException('Empty skill list');
        final skill = Skill.fromJson(data[0] as Map<String, dynamic>);
        return skill;
      } else if (data is Map) {
        return Skill.fromJson(data as Map<String, dynamic>);
      }
      throw const FormatException('Invalid skill format');
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to parse skill manifest: $e');
    }
  }

  /// Import and install skills from a JSON manifest string.
  ///
  /// Returns the number of skills successfully installed.
  Future<int> importAndInstall(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      final skills = <Skill>[];

      if (data is List) {
        for (final item in data) {
          skills.add(Skill.fromJson(item as Map<String, dynamic>));
        }
      } else if (data is Map) {
        skills.add(Skill.fromJson(data as Map<String, dynamic>));
      }

      if (skills.isEmpty) return 0;
      await skillProvider.installAll(skills);
      return skills.length;
    } catch (e) {
      throw FormatException('Failed to import skills: $e');
    }
  }

  /// Validate a skill manifest string without installing.
  bool isValidManifest(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      if (data is List) {
        return data.isNotEmpty && data.every((e) => e is Map && e.containsKey('id') && e.containsKey('name'));
      }
      return data is Map && data.containsKey('id') && data.containsKey('name');
    } catch (_) {
      return false;
    }
  }
}