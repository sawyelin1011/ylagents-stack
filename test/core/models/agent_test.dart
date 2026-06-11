import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/agent.dart';
import 'package:Kelivo/core/models/agent_genome.dart';

void main() {
  group('AgentGenome', () {
    test('empty const works and isEmpty returns true', () {
      const genome = AgentGenome.empty;
      expect(genome.identity, '');
      expect(genome.soul, '');
      expect(genome.role, '');
      expect(genome.goals, isEmpty);
      expect(genome.backstory, '');
      expect(genome.isEmpty, isTrue);
    });

    test('full constructor sets all fields', () {
      const genome = AgentGenome(
        identity: 'Software Architect',
        soul: 'Crafts clean, maintainable code',
        role: 'Lead developer and code reviewer',
        goals: ['Improve code quality', 'Reduce tech debt'],
        backstory: 'Built three microservices at a fintech startup',
      );
      expect(genome.identity, 'Software Architect');
      expect(genome.soul, 'Crafts clean, maintainable code');
      expect(genome.role, 'Lead developer and code reviewer');
      expect(genome.goals, ['Improve code quality', 'Reduce tech debt']);
      expect(
        genome.backstory,
        'Built three microservices at a fintech startup',
      );
      expect(genome.isEmpty, isFalse);
    });

    test('toJson/fromJson round-trip', () {
      const genome = AgentGenome(
        identity: 'Architect',
        soul: 'Clean code advocate',
        role: 'Reviewer',
        goals: ['Goal 1', 'Goal 2'],
        backstory: 'Origin story',
      );
      final json = genome.toJson();
      final restored = AgentGenome.fromJson(json);
      expect(restored.identity, genome.identity);
      expect(restored.soul, genome.soul);
      expect(restored.role, genome.role);
      expect(restored.goals, genome.goals);
      expect(restored.backstory, genome.backstory);
    });

    test('toJson omits empty fields', () {
      const genome = AgentGenome.empty;
      final json = genome.toJson();
      expect(json.containsKey('identity'), isFalse);
      expect(json.containsKey('soul'), isFalse);
      expect(json.containsKey('role'), isFalse);
      expect(json.containsKey('goals'), isFalse);
      expect(json.containsKey('backstory'), isFalse);
    });

    test('toJson includes non-empty fields', () {
      const genome = AgentGenome(identity: 'Architect');
      final json = genome.toJson();
      expect(json['identity'], 'Architect');
      expect(json.containsKey('soul'), isFalse);
    });

    test('fromJson handles empty map', () {
      final genome = AgentGenome.fromJson({});
      expect(genome.identity, '');
      expect(genome.goals, isEmpty);
    });

    test('copyWith merges correctly', () {
      const genome = AgentGenome(identity: 'Dev', soul: 'Builder');
      final copy = genome.copyWith(role: 'Architect');
      expect(copy.identity, 'Dev');
      expect(copy.soul, 'Builder');
      expect(copy.role, 'Architect');
      expect(copy.goals, isEmpty);
    });

    test('copyWith clearIdentity clears identity', () {
      const genome = AgentGenome(identity: 'Dev');
      final copy = genome.copyWith(clearIdentity: true);
      expect(copy.identity, '');
    });

    test('copyWith clearGoals clears goals', () {
      const genome = AgentGenome(goals: ['Goal 1']);
      final copy = genome.copyWith(clearGoals: true);
      expect(copy.goals, isEmpty);
    });
  });

  group('AgentType', () {
    test('toJson returns correct string', () {
      expect(AgentType.standard.toJson(), 'standard');
      expect(AgentType.lead.toJson(), 'lead');
      expect(AgentType.worker.toJson(), 'worker');
    });

    test('fromJson parses correctly', () {
      expect(AgentType.fromJson('standard'), AgentType.standard);
      expect(AgentType.fromJson('lead'), AgentType.lead);
      expect(AgentType.fromJson('worker'), AgentType.worker);
    });

    test('fromJson defaults to standard for unknown values', () {
      expect(AgentType.fromJson('unknown'), AgentType.standard);
      expect(AgentType.fromJson(''), AgentType.standard);
    });
  });

  group('Agent', () {
    test('constructor sets correct defaults', () {
      const agent = Agent(id: 'a-1', name: 'Test Agent');
      expect(agent.type, AgentType.standard);
      expect(agent.genome, AgentGenome.empty);
      expect(agent.enabled, isTrue);
    });

    test('toJson and fromJson round-trip with genome', () {
      const agent = Agent(
        id: 'a-1',
        name: 'Architect',
        type: AgentType.lead,
        genome: AgentGenome(
          identity: 'Architect',
          role: 'Reviewer',
          goals: ['Quality'],
        ),
        enabled: true,
      );
      final json = agent.toJson();
      final restored = Agent.fromJson(json);
      expect(restored.id, agent.id);
      expect(restored.name, agent.name);
      expect(restored.type, agent.type);
      expect(restored.genome.identity, agent.genome.identity);
      expect(restored.genome.role, agent.genome.role);
      expect(restored.genome.goals, agent.genome.goals);
      expect(restored.enabled, agent.enabled);
    });

    test('toJson and fromJson round-trip without genome', () {
      const agent = Agent(id: 'a-2', name: 'Worker');
      final json = agent.toJson();
      final restored = Agent.fromJson(json);
      expect(restored.id, 'a-2');
      expect(restored.genome, isA<AgentGenome>());
      expect(restored.genome.isEmpty, isTrue);
    });

    test('toJson includes type and enabled', () {
      const agent = Agent(id: 'a-1', name: 'Test', type: AgentType.lead);
      final json = agent.toJson();
      expect(json['type'], 'lead');
      expect(json['enabled'], isTrue);
    });

    test('copyWith preserves unset fields', () {
      const agent = Agent(
        id: 'a-1',
        name: 'Original',
        type: AgentType.lead,
        genome: AgentGenome(identity: 'Dev'),
      );
      final copy = agent.copyWith(name: 'Renamed');
      expect(copy.id, 'a-1');
      expect(copy.name, 'Renamed');
      expect(copy.type, AgentType.lead);
      expect(copy.genome.identity, 'Dev');
    });

    test('copyWith clearGenome clears genome', () {
      const agent = Agent(
        id: 'a-1',
        name: 'Test',
        genome: AgentGenome(identity: 'Dev'),
      );
      final copy = agent.copyWith(clearGenome: true);
      expect(copy.genome, AgentGenome.empty);
    });

    test('encodeList and decodeList round-trip', () {
      final agents = [
        const Agent(id: 'a-1', name: 'Agent A', type: AgentType.lead),
        const Agent(id: 'a-2', name: 'Agent B'),
      ];
      final encoded = Agent.encodeList(agents);
      final decoded = Agent.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].id, 'a-1');
      expect(decoded[0].type, AgentType.lead);
      expect(decoded[1].id, 'a-2');
      expect(decoded[1].type, AgentType.standard);
    });

    test('decodeList returns empty on invalid JSON', () {
      final decoded = Agent.decodeList('not json');
      expect(decoded, isEmpty);
    });
  });
}
