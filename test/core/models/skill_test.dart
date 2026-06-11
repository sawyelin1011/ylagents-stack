import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/skill.dart';

void main() {
  group('Skill', () {
    test('constructor sets required fields', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Test Skill',
        description: 'A test skill',
        content: SkillContent.empty(),
      );

      expect(skill.id, 'test-1');
      expect(skill.name, 'Test Skill');
      expect(skill.version, '1.0.0');
      expect(skill.source, SkillInstallSource.local);
      expect(skill.installedAt, isNotNull);
    });

    test('constructor with all fields', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Test Skill',
        description: 'Full test',
        version: '2.0.0',
        author: 'Author',
        tags: ['tag1', 'tag2'],
        source: SkillInstallSource.marketplace,
        sourceUrl: 'https://example.com',
        content: const SkillContent(
          prompts: [
            SkillPrompt(id: 'p1', name: 'Prompt 1', text: 'Do something'),
          ],
        ),
      );

      expect(skill.author, 'Author');
      expect(skill.tags, ['tag1', 'tag2']);
      expect(skill.source, SkillInstallSource.marketplace);
      expect(skill.sourceUrl, 'https://example.com');
      expect(skill.content.prompts.length, 1);
    });

    test('copyWith preserves and overrides', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Original',
        description: 'Original desc',
        content: SkillContent.empty(),
      );

      final copied = skill.copyWith(name: 'Updated');
      expect(copied.name, 'Updated');
      expect(copied.description, 'Original desc');
      expect(copied.id, 'test-1');
    });

    test('copyWith clears author when flag set', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Test',
        description: 'Test',
        author: 'Author',
        content: SkillContent.empty(),
      );

      final copied = skill.copyWith(clearAuthor: true);
      expect(copied.author, isNull);
    });

    test('toJson/fromJson round-trip with all fields', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Test Skill',
        description: 'A test skill',
        version: '2.0.0',
        author: 'Author',
        tags: ['tag1'],
        source: SkillInstallSource.marketplace,
        sourceUrl: 'https://example.com',
        content: const SkillContent(
          prompts: [SkillPrompt(id: 'p1', name: 'P1', text: 'Do')],
          workflows: [SkillWorkflow(id: 'w1', name: 'W1', steps: ['Step 1'])],
          requiredMcpTools: ['fetch'],
          knowledgeLinks: ['kb1'],
        ),
      );

      final json = skill.toJson();
      final decoded = Skill.fromJson(json);

      expect(decoded.id, skill.id);
      expect(decoded.name, skill.name);
      expect(decoded.author, skill.author);
      expect(decoded.source, skill.source);
      expect(decoded.content.prompts.length, 1);
      expect(decoded.content.workflows.length, 1);
      expect(decoded.content.requiredMcpTools, ['fetch']);
    });

    test('toJson omits optional empty fields', () {
      final skill = Skill(
        id: 'test-1',
        name: 'Minimal',
        description: 'Minimal',
        content: const SkillContent(),
      );

      final json = skill.toJson();
      expect(json.containsKey('author'), false);
      expect(json.containsKey('tags'), false);
      expect(json.containsKey('sourceUrl'), false);
    });

    test('fromJson handles missing fields', () {
      final json = {
        'id': 'test-1',
        'name': 'Test',
        'description': 'Test',
        'content': {},
        'installedAt': 1000000,
      };

      final skill = Skill.fromJson(json);
      expect(skill.id, 'test-1');
      expect(skill.tags, isEmpty);
      expect(skill.content.isEmpty, true);
    });

    test('encodeList/decodeList round-trip', () {
      final skills = [
        Skill(
          id: 's1', name: 'S1', description: 'One',
          content: SkillContent.empty(),
        ),
        Skill(
          id: 's2', name: 'S2', description: 'Two',
          content: SkillContent.empty(),
        ),
      ];

      final encoded = Skill.encodeList(skills);
      final decoded = Skill.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, 's1');
      expect(decoded[1].name, 'S2');
    });

    test('decodeList handles invalid JSON', () {
      expect(Skill.decodeList(''), isEmpty);
      expect(Skill.decodeList('not json'), isEmpty);
    });
  });

  group('SkillInstallSource', () {
    test('values and serialization', () {
      expect(SkillInstallSource.local.toJson(), 'local');
      expect(SkillInstallSource.marketplace.toJson(), 'marketplace');
      expect(SkillInstallSource.git.toJson(), 'git');
    });

    test('fromJson with unknown value defaults to local', () {
      expect(SkillInstallSource.fromJson('unknown'), SkillInstallSource.local);
    });
  });

  group('SkillContent', () {
    test('empty() has no content', () {
      final content = SkillContent.empty();
      expect(content.isEmpty, true);
    });

    test('non-empty content', () {
      final content = const SkillContent(
        prompts: [SkillPrompt(id: 'p1', name: 'P1', text: 'Do')],
      );
      expect(content.isEmpty, false);
    });
  });
}