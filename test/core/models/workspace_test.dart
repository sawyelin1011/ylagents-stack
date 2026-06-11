import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/workspace.dart';
import 'package:Kelivo/core/models/workspace_settings.dart';

void main() {
  group('WorkspaceType', () {
    test('toJson returns correct string', () {
      expect(WorkspaceType.personal.toJson(), 'personal');
      expect(WorkspaceType.project.toJson(), 'project');
      expect(WorkspaceType.client.toJson(), 'client');
    });

    test('fromJson parses correctly', () {
      expect(WorkspaceType.fromJson('personal'), WorkspaceType.personal);
      expect(WorkspaceType.fromJson('project'), WorkspaceType.project);
      expect(WorkspaceType.fromJson('client'), WorkspaceType.client);
    });

    test('fromJson defaults to personal for unknown values', () {
      expect(WorkspaceType.fromJson('unknown'), WorkspaceType.personal);
      expect(WorkspaceType.fromJson(''), WorkspaceType.personal);
    });
  });

  group('Workspace', () {
    final now = DateTime(2026, 6, 11, 12, 0, 0);

    test('constructor sets correct defaults', () {
      final ws = Workspace(
        id: 'ws-1',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
      );
      expect(ws.type, WorkspaceType.personal);
      expect(ws.description, '');
      expect(ws.settings, isNull);
    });

    test('toJson and fromJson round-trip', () {
      final ws = Workspace(
        id: 'ws-1',
        name: 'My Project',
        type: WorkspaceType.project,
        description: 'Test workspace',
        createdAt: now,
        updatedAt: now,
        settings: const WorkspaceSettings(
          defaultAssistantId: 'assistant-1',
          defaultModelProvider: 'openai',
          defaultModelId: 'gpt-4',
          mcpServerIds: ['mcp-1'],
        ),
      );

      final json = ws.toJson();
      final restored = Workspace.fromJson(json);

      expect(restored.id, ws.id);
      expect(restored.name, ws.name);
      expect(restored.type, ws.type);
      expect(restored.description, ws.description);
      expect(restored.settings?.defaultAssistantId, 'assistant-1');
      expect(restored.settings?.defaultModelProvider, 'openai');
      expect(restored.settings?.defaultModelId, 'gpt-4');
      expect(restored.settings?.mcpServerIds, ['mcp-1']);
    });

    test('fromJson handles legacy data without settings', () {
      final json = {
        'id': 'ws-1',
        'name': 'Personal',
        'type': 'personal',
        'description': '',
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };
      final ws = Workspace.fromJson(json);
      expect(ws.settings, isNull);
    });

    test('copyWith preserves unset fields', () {
      final ws = Workspace(
        id: 'ws-1',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
      );
      final copy = ws.copyWith(name: 'Renamed');
      expect(copy.id, 'ws-1');
      expect(copy.name, 'Renamed');
      expect(copy.type, WorkspaceType.personal);
    });

    test('copyWith clearDescription clears description', () {
      final ws = Workspace(
        id: 'ws-1',
        name: 'Test',
        description: 'old desc',
        createdAt: now,
        updatedAt: now,
      );
      final copy = ws.copyWith(clearDescription: true);
      expect(copy.description, '');
    });

    test('encodeList and decodeList round-trip', () {
      final workspaces = [
        Workspace(id: 'ws-1', name: 'A', createdAt: now, updatedAt: now),
        Workspace(id: 'ws-2', name: 'B', createdAt: now, updatedAt: now),
      ];
      final encoded = Workspace.encodeList(workspaces);
      final decoded = Workspace.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'ws-1');
      expect(decoded[1].id, 'ws-2');
    });

    test('decodeList returns empty on invalid JSON', () {
      final decoded = Workspace.decodeList('invalid');
      expect(decoded, isEmpty);
    });
  });

  group('WorkspaceSettings', () {
    test('empty settings has null fields', () {
      const settings = WorkspaceSettings.empty;
      expect(settings.defaultAssistantId, isNull);
      expect(settings.defaultModelProvider, isNull);
      expect(settings.defaultModelId, isNull);
      expect(settings.mcpServerIds, isEmpty);
      expect(settings.localToolIds, isEmpty);
    });

    test('toJson omits null/empty fields', () {
      const settings = WorkspaceSettings.empty;
      final json = settings.toJson();
      expect(json.containsKey('defaultAssistantId'), false);
      expect(json.containsKey('mcpServerIds'), false);
    });

    test('toJson includes non-null fields', () {
      const settings = WorkspaceSettings(
        defaultAssistantId: 'a-1',
        mcpServerIds: ['mcp-1'],
      );
      final json = settings.toJson();
      expect(json['defaultAssistantId'], 'a-1');
      expect(json['mcpServerIds'], ['mcp-1']);
    });

    test('fromJson handles empty map', () {
      final settings = WorkspaceSettings.fromJson({});
      expect(settings.defaultAssistantId, isNull);
      expect(settings.mcpServerIds, isEmpty);
    });

    test('copyWith merges correctly', () {
      const settings = WorkspaceSettings(
        defaultAssistantId: 'a-1',
        defaultModelProvider: 'openai',
      );
      final copy = settings.copyWith(defaultModelId: 'gpt-4');
      expect(copy.defaultAssistantId, 'a-1');
      expect(copy.defaultModelProvider, 'openai');
      expect(copy.defaultModelId, 'gpt-4');
    });

    test('copyWith clearDefaultAssistantId clears field', () {
      const settings = WorkspaceSettings(defaultAssistantId: 'a-1');
      final copy = settings.copyWith(clearDefaultAssistantId: true);
      expect(copy.defaultAssistantId, isNull);
    });
  });
}
