import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/agent.dart';
import 'package:Kelivo/core/models/agent_genome.dart';
import 'package:Kelivo/core/models/agent_template.dart';
import 'package:Kelivo/core/services/agent_templates.dart';

void main() {
  group('AgentTemplate', () {
    test('constructor sets fields correctly', () {
      const template = AgentTemplate(
        id: 'test-template',
        name: 'Test Template',
        description: 'A test template',
        iconName: 'Code',
        agentType: AgentType.worker,
        genome: AgentGenome(
          identity: 'a test agent',
          soul: 'test soul',
          role: 'test role',
          goals: ['goal 1', 'goal 2'],
          backstory: 'test backstory',
        ),
        suggestedSystemPrompt: 'You are a test agent.',
      );

      expect(template.id, 'test-template');
      expect(template.name, 'Test Template');
      expect(template.description, 'A test template');
      expect(template.iconName, 'Code');
      expect(template.agentType, AgentType.worker);
      expect(template.genome.identity, 'a test agent');
      expect(template.genome.soul, 'test soul');
      expect(template.genome.role, 'test role');
      expect(template.genome.goals, ['goal 1', 'goal 2']);
      expect(template.genome.backstory, 'test backstory');
      expect(template.suggestedSystemPrompt, 'You are a test agent.');
    });

    test('constructor uses defaults for optional fields', () {
      const template = AgentTemplate(
        id: 'minimal',
        name: 'Minimal',
        description: 'Minimal template',
      );

      expect(template.iconName, 'Bot');
      expect(template.agentType, AgentType.standard);
      expect(template.genome, AgentGenome.empty);
      expect(template.suggestedSystemPrompt, '');
    });

    test('toJson/fromJson round-trip preserves all fields', () {
      const template = AgentTemplate(
        id: 'round-trip',
        name: 'Round Trip',
        description: 'Testing JSON serialization',
        iconName: 'Code',
        agentType: AgentType.lead,
        genome: AgentGenome(
          identity: 'lead identity',
          soul: 'lead soul',
          role: 'lead role',
          goals: ['goal a'],
          backstory: 'lead backstory',
        ),
        suggestedSystemPrompt: 'Lead system prompt.',
      );

      final json = template.toJson();
      final restored = AgentTemplate.fromJson(json);

      expect(restored.id, template.id);
      expect(restored.name, template.name);
      expect(restored.description, template.description);
      expect(restored.iconName, template.iconName);
      expect(restored.agentType, template.agentType);
      expect(restored.genome.identity, template.genome.identity);
      expect(restored.genome.soul, template.genome.soul);
      expect(restored.genome.role, template.genome.role);
      expect(restored.genome.goals, template.genome.goals);
      expect(restored.genome.backstory, template.genome.backstory);
      expect(restored.suggestedSystemPrompt, template.suggestedSystemPrompt);
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'minimal-json',
        'name': 'Minimal JSON',
        'description': 'Test',
      };

      final template = AgentTemplate.fromJson(json);
      expect(template.id, 'minimal-json');
      expect(template.name, 'Minimal JSON');
      expect(template.iconName, 'Bot');
      expect(template.agentType, AgentType.standard);
      expect(template.genome, AgentGenome.empty);
      expect(template.suggestedSystemPrompt, '');
    });

    test('fromJson handles empty genome field', () {
      final json = <String, dynamic>{
        'id': 'no-genome',
        'name': 'No Genome',
        'description': 'Test',
        'genome': <String, dynamic>{},
      };

      final template = AgentTemplate.fromJson(json);
      expect(template.genome.isEmpty, true);
    });

    test('fromJson handles null genome', () {
      final json = <String, dynamic>{
        'id': 'null-genome',
        'name': 'Null Genome',
        'description': 'Test',
        'genome': null,
      };

      final template = AgentTemplate.fromJson(json);
      expect(template.genome, AgentGenome.empty);
    });

    test('fromJson handles unknown agent type defaults to standard', () {
      final json = <String, dynamic>{
        'id': 'bad-type',
        'name': 'Bad Type',
        'description': 'Test',
        'agentType': 'unknown_type',
      };

      final template = AgentTemplate.fromJson(json);
      expect(template.agentType, AgentType.standard);
    });
  });

  group('AgentTemplateService', () {
    test('builtInTemplates returns 5 templates', () {
      final templates = AgentTemplateService.builtInTemplates;
      expect(templates.length, 5);
    });

    test('builtInTemplates contains general-assistant', () {
      final template = AgentTemplateService.getById('general-assistant');
      expect(template, isNotNull);
      expect(template!.name, 'General Assistant');
      expect(template.agentType, AgentType.standard);
      expect(template.genome.identity, contains('assistant'));
    });

    test('builtInTemplates contains code-helper', () {
      final template = AgentTemplateService.getById('code-helper');
      expect(template, isNotNull);
      expect(template!.name, 'Code Helper');
      expect(template.agentType, AgentType.worker);
      expect(template.genome.goals.isNotEmpty, true);
    });

    test('builtInTemplates contains writer', () {
      final template = AgentTemplateService.getById('writer');
      expect(template, isNotNull);
      expect(template!.name, 'Writer');
      expect(template.genome.identity, contains('writer'));
    });

    test('builtInTemplates contains researcher', () {
      final template = AgentTemplateService.getById('researcher');
      expect(template, isNotNull);
      expect(template!.name, 'Researcher');
      expect(template.genome.identity, contains('research'));
    });

    test('builtInTemplates contains lead-agent', () {
      final template = AgentTemplateService.getById('lead-agent');
      expect(template, isNotNull);
      expect(template!.name, 'Lead Agent');
      expect(template.agentType, AgentType.lead);
      expect(template.genome.goals, contains('Delegate tasks'));
    });

    test('getById returns null for unknown id', () {
      expect(AgentTemplateService.getById('non-existent'), isNull);
    });

    test('all built-in templates have non-empty descriptions', () {
      for (final t in AgentTemplateService.builtInTemplates) {
        expect(
          t.description.isNotEmpty,
          isTrue,
          reason: 'Template ${t.id} has empty description',
        );
      }
    });

    test('all built-in templates have valid agent types', () {
      for (final t in AgentTemplateService.builtInTemplates) {
        expect(
          AgentType.values.contains(t.agentType),
          isTrue,
          reason: 'Template ${t.id} has invalid agent type',
        );
      }
    });

    test('all built-in templates have suggested system prompts', () {
      for (final t in AgentTemplateService.builtInTemplates) {
        expect(
          t.suggestedSystemPrompt.isNotEmpty,
          isTrue,
          reason: 'Template ${t.id} has empty suggestedSystemPrompt',
        );
      }
    });

    test('all template IDs are unique', () {
      final ids = AgentTemplateService.builtInTemplates.map((t) => t.id);
      expect(ids.toSet().length, ids.length);
    });
  });
}
