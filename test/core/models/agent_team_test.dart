import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/agent_team.dart';

void main() {
  group('AgentTeam', () {
    test('constructor sets default values', () {
      final now = DateTime.now();
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
      );

      expect(team.id, 'team-1');
      expect(team.name, 'Test Team');
      expect(team.description, isNull);
      expect(team.workspaceId, 'ws-1');
      expect(team.leadAgentId, 'lead-1');
      expect(team.memberAgentIds, isEmpty);
      expect(team.createdAt, isNotNull);
      expect(team.updatedAt, isNotNull);
    });

    test('constructor with all fields', () {
      final now = DateTime.now();
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        description: 'A test team',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
        memberAgentIds: ['worker-1', 'worker-2'],
        createdAt: now,
        updatedAt: now,
      );

      expect(team.description, 'A test team');
      expect(team.memberAgentIds, ['worker-1', 'worker-2']);
      expect(team.createdAt, now);
      expect(team.updatedAt, now);
    });

    test('copyWith preserves values unless overridden', () {
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        description: 'Original desc',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
        memberAgentIds: ['worker-1'],
      );

      final copied = team.copyWith(name: 'Updated Team');
      expect(copied.id, 'team-1');
      expect(copied.name, 'Updated Team');
      expect(copied.description, 'Original desc');
      expect(copied.leadAgentId, 'lead-1');
      expect(copied.memberAgentIds, ['worker-1']);
    });

    test('copyWith clears description when flag set', () {
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        description: 'Original desc',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
      );

      final copied = team.copyWith(clearDescription: true);
      expect(copied.description, isNull);
    });

    test('copyWith clears members when flag set', () {
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
        memberAgentIds: ['worker-1', 'worker-2'],
      );

      final copied = team.copyWith(clearMemberIds: true);
      expect(copied.memberAgentIds, isEmpty);
    });

    test('toJson/fromJson round-trip with all fields', () {
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        description: 'A test team',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
        memberAgentIds: ['worker-1', 'worker-2'],
      );

      final json = team.toJson();
      final decoded = AgentTeam.fromJson(json);

      expect(decoded.id, team.id);
      expect(decoded.name, team.name);
      expect(decoded.description, team.description);
      expect(decoded.workspaceId, team.workspaceId);
      expect(decoded.leadAgentId, team.leadAgentId);
      expect(decoded.memberAgentIds, team.memberAgentIds);
    });

    test('toJson omits optional empty fields', () {
      final team = AgentTeam(
        id: 'team-1',
        name: 'Test Team',
        workspaceId: 'ws-1',
        leadAgentId: 'lead-1',
      );

      final json = team.toJson();
      expect(json.containsKey('description'), false);
      expect(json.containsKey('memberAgentIds'), false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'team-1',
        'name': 'Test Team',
        'workspaceId': 'ws-1',
        'leadAgentId': 'lead-1',
        'createdAt': 1000000,
        'updatedAt': 1000000,
      };

      final team = AgentTeam.fromJson(json);
      expect(team.id, 'team-1');
      expect(team.description, isNull);
      expect(team.memberAgentIds, isEmpty);
    });

    test('encodeList/decodeList round-trip', () {
      final teams = [
        AgentTeam(
          id: 'team-1',
          name: 'Team 1',
          workspaceId: 'ws-1',
          leadAgentId: 'lead-1',
          memberAgentIds: ['worker-1'],
        ),
        AgentTeam(
          id: 'team-2',
          name: 'Team 2',
          workspaceId: 'ws-1',
          leadAgentId: 'lead-2',
          memberAgentIds: ['worker-2', 'worker-3'],
        ),
      ];

      final encoded = AgentTeam.encodeList(teams);
      final decoded = AgentTeam.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, 'team-1');
      expect(decoded[1].memberAgentIds, ['worker-2', 'worker-3']);
    });

    test('decodeList handles invalid JSON', () {
      final decoded = AgentTeam.decodeList('');
      expect(decoded, isEmpty);
    });
  });
}