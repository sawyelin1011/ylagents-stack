import '../models/skill.dart';

/// Provides built-in skills available for installation.
///
/// In Phase 7, this uses a local JSON-based listing. Future phases
/// will add remote marketplace fetching via URL.
class SkillMarketplaceService {
  /// Built-in skills available in the marketplace.
  static List<Skill> get builtInSkills => [
    Skill(
      id: 'skill-research',
      name: 'Research Assistant',
      description:
          'Deep research and analysis skill. Gathers information from multiple sources, evaluates credibility, and produces structured reports.',
      version: '1.0.0',
      author: 'YLAgents',
      tags: ['research', 'analysis', 'writing'],
      source: SkillInstallSource.marketplace,
      content: const SkillContent(
        prompts: [
          SkillPrompt(
            id: 'research-plan',
            name: 'Research Plan',
            text:
                'Create a research plan covering: 1) Key questions, 2) Search sources, 3) Credibility criteria, 4) Deliverable structure.',
            role: 'system',
          ),
          SkillPrompt(
            id: 'research-report',
            name: 'Research Report',
            text:
                'Synthesize findings into a structured report with: Executive summary, Key findings, Detailed analysis, Sources, Recommendations.',
            role: 'system',
          ),
        ],
        workflows: [
          SkillWorkflow(
            id: 'research-flow',
            name: 'Research Workflow',
            description: 'Plan → Gather → Analyze → Report',
            steps: [
              'Plan research',
              'Gather information',
              'Analyze findings',
              'Produce report',
            ],
          ),
        ],
      ),
    ),
    Skill(
      id: 'skill-code-review',
      name: 'Code Review',
      description:
          'Automated code review skill. Analyzes code for bugs, style issues, security vulnerabilities, and performance concerns.',
      version: '1.0.0',
      author: 'YLAgents',
      tags: ['code', 'review', 'quality'],
      source: SkillInstallSource.marketplace,
      content: const SkillContent(
        prompts: [
          SkillPrompt(
            id: 'review-analysis',
            name: 'Code Analysis',
            text:
                'Review the provided code for: 1) Logic errors, 2) Security vulnerabilities, 3) Performance issues, 4) Style violations, 5) Test coverage gaps.',
            role: 'system',
          ),
        ],
        workflows: [
          SkillWorkflow(
            id: 'review-flow',
            name: 'Review Workflow',
            description: 'Analyze → Report → Suggest fixes',
            steps: ['Analyze code', 'Identify issues', 'Suggest improvements'],
          ),
        ],
      ),
    ),
    Skill(
      id: 'skill-customer-support',
      name: 'Customer Support',
      description:
          'Handles customer inquiries with empathy and accuracy. Follows support workflows, escalation paths, and knowledge base lookups.',
      version: '1.0.0',
      author: 'YLAgents',
      tags: ['support', 'customer', 'communication'],
      source: SkillInstallSource.marketplace,
      content: const SkillContent(
        prompts: [
          SkillPrompt(
            id: 'support-triage',
            name: 'Support Triage',
            text:
                'Categorize the customer inquiry: 1) Issue type, 2) Priority level, 3) Required expertise, 4) Escalation needed.',
            role: 'system',
          ),
          SkillPrompt(
            id: 'support-response',
            name: 'Support Response',
            text:
                'Respond with: 1) Acknowledge the issue, 2) Clarify if needed, 3) Provide solution or next steps, 4) Set expectations.',
            role: 'system',
          ),
        ],
        workflows: [
          SkillWorkflow(
            id: 'support-flow',
            name: 'Support Workflow',
            description: 'Triage → Resolve → Follow up',
            steps: [
              'Triage inquiry',
              'Research solution',
              'Respond to customer',
              'Follow up',
            ],
          ),
        ],
      ),
    ),
    Skill(
      id: 'skill-content-writer',
      name: 'Content Writer',
      description:
          'Professional content creation skill. Produces articles, blog posts, marketing copy, and documentation with consistent tone and style.',
      version: '1.0.0',
      author: 'YLAgents',
      tags: ['writing', 'content', 'marketing'],
      source: SkillInstallSource.marketplace,
      content: const SkillContent(
        prompts: [
          SkillPrompt(
            id: 'content-brief',
            name: 'Content Brief',
            text:
                'Define: 1) Target audience, 2) Tone and voice, 3) Key messages, 4) Call to action, 5) SEO keywords.',
            role: 'system',
          ),
        ],
        workflows: [
          SkillWorkflow(
            id: 'content-flow',
            name: 'Content Workflow',
            description: 'Brief → Draft → Review → Polish',
            steps: [
              'Create brief',
              'Write draft',
              'Review and edit',
              'Final polish',
            ],
          ),
        ],
      ),
    ),
  ];

  /// Find a built-in skill by ID.
  static Skill? getById(String id) {
    return builtInSkills.where((s) => s.id == id).firstOrNull;
  }

  /// Search built-in skills by query (matches name, description, tags).
  static List<Skill> search(String query) {
    if (query.isEmpty) return builtInSkills;
    final q = query.toLowerCase();
    return builtInSkills
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q) ||
              s.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  /// Get all unique tags from built-in skills.
  static List<String> get allTags {
    final tagSet = <String>{};
    for (final s in builtInSkills) {
      tagSet.addAll(s.tags);
    }
    return tagSet.toList()..sort();
  }
}
