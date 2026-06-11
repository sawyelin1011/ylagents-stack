import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/agent_genome.dart';
import '../../../core/models/agent_template.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/services/agent_templates.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Multi-step wizard for creating a new Agent.
///
/// Steps:
/// 1. Template selection (or start from scratch)
/// 2. Identity (name + description)
/// 3. Role & Genome (type + genome fields)
/// 4. Review & Create
class AgentFactoryPage extends StatefulWidget {
  const AgentFactoryPage({super.key});

  @override
  State<AgentFactoryPage> createState() => _AgentFactoryPageState();
}

class _AgentFactoryPageState extends State<AgentFactoryPage> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Template selection
  AgentTemplate? _selectedTemplate;

  // Step 2: Identity
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 3: Role & Genome
  AgentType _agentType = AgentType.standard;
  final _identityController = TextEditingController();
  final _soulController = TextEditingController();
  final _roleController = TextEditingController();
  final _backstoryController = TextEditingController();
  final List<String> _goals = [];
  final _goalController = TextEditingController();

  // Step 4: Review state
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _identityController.dispose();
    _soulController.dispose();
    _roleController.dispose();
    _backstoryController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _applyTemplate(AgentTemplate template) {
    _selectedTemplate = template;
    _nameController.text = template.name;
    _descriptionController.text = template.description;
    _agentType = template.agentType;
    _identityController.text = template.genome.identity;
    _soulController.text = template.genome.soul;
    _roleController.text = template.genome.role;
    _backstoryController.text = template.genome.backstory;
    _goals.clear();
    _goals.addAll(template.genome.goals);
  }

  void _resetForm() {
    _selectedTemplate = null;
    _nameController.clear();
    _descriptionController.clear();
    _agentType = AgentType.standard;
    _identityController.clear();
    _soulController.clear();
    _roleController.clear();
    _backstoryController.clear();
    _goals.clear();
  }

  Future<void> _createAgent() async {
    final l10n = AppLocalizations.of(context)!;
    final assistantProvider = context.read<AssistantProvider>();
    final agentProvider = context.read<AgentProvider>();

    setState(() => _isCreating = true);

    try {
      // Step 1: Create the assistant
      final assistantId = await assistantProvider.addAssistant(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        context: context,
      );

      // Step 2: Promote to agent with genome
      final genome = AgentGenome(
        identity: _identityController.text.trim(),
        soul: _soulController.text.trim(),
        role: _roleController.text.trim(),
        goals: List<String>.of(_goals),
        backstory: _backstoryController.text.trim(),
      );

      await agentProvider.promoteToAgent(
        assistantId,
        type: _agentType,
        genome: genome,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : l10n.agentFactoryCreatedSnackbar} ${l10n.agentFactoryCreated}',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.agentFactoryCreateFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.agentFactoryTitle),
        leading: IconButton(
          icon: const Icon(lucide.Lucide.ArrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() => _currentStep--);
              },
              child: Text(l10n.agentFactoryBack),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            labels: [
              l10n.agentFactoryStepTemplate,
              l10n.agentFactoryStepIdentity,
              l10n.agentFactoryStepGenome,
              l10n.agentFactoryStepReview,
            ],
            colorScheme: cs,
          ),
          const SizedBox(height: 8),
          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStepContent(l10n, cs),
            ),
          ),
          // Bottom navigation
          _buildBottomBar(l10n, cs),
        ],
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n, ColorScheme cs) {
    switch (_currentStep) {
      case 0:
        return _buildTemplateStep(l10n, cs);
      case 1:
        return _buildIdentityStep(l10n, cs);
      case 2:
        return _buildGenomeStep(l10n, cs);
      case 3:
        return _buildReviewStep(l10n, cs);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 1: Template selection ──────────────────────────────────────

  Widget _buildTemplateStep(AppLocalizations l10n, ColorScheme cs) {
    final templates = AgentTemplateService.builtInTemplates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.agentFactoryTemplateSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        // Start from scratch card
        _TemplateCard(
          icon: lucide.Lucide.Sparkles,
          title: l10n.agentFactoryScratch,
          description: l10n.agentFactoryScratchDesc,
          isSelected: _selectedTemplate == null,
          colorScheme: cs,
          onTap: () => setState(() {
            _resetForm();
          }),
        ),
        const SizedBox(height: 12),
        // Template cards
        ...templates.map(
          (template) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TemplateCard(
              icon: _iconForTemplate(template.iconName),
              title: template.name,
              description: template.description,
              isSelected: _selectedTemplate?.id == template.id,
              colorScheme: cs,
              onTap: () => setState(() {
                _applyTemplate(template);
              }),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForTemplate(String iconName) {
    return switch (iconName) {
      'Code' => lucide.Lucide.Code,
      'Pen' => lucide.Lucide.Pencil,
      'Search' => lucide.Lucide.Search,
      _ => lucide.Lucide.Bot,
    };
  }

  // ─── Step 2: Identity ────────────────────────────────────────────────

  Widget _buildIdentityStep(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.agentFactoryIdentitySubtitle,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.agentFactoryNameLabel,
            hintText: l10n.agentFactoryNameHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: l10n.agentFactoryDescLabel,
            hintText: l10n.agentFactoryDescHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // ─── Step 3: Role & Genome ───────────────────────────────────────────

  Widget _buildGenomeStep(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.agentFactoryGenomeSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        // Agent type dropdown
        DropdownButtonFormField<AgentType>(
          value: _agentType,
          decoration: InputDecoration(
            labelText: l10n.agentGenomeTypeLabel,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            DropdownMenuItem(
              value: AgentType.standard,
              child: Text(l10n.agentTypeStandard),
            ),
            DropdownMenuItem(
              value: AgentType.lead,
              child: Text(l10n.agentTypeLead),
            ),
            DropdownMenuItem(
              value: AgentType.worker,
              child: Text(l10n.agentTypeWorker),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _agentType = v);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _identityController,
          decoration: InputDecoration(
            labelText: l10n.agentGenomeIdentityLabel,
            hintText: l10n.agentGenomeIdentityHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _soulController,
          decoration: InputDecoration(
            labelText: l10n.agentGenomeSoulLabel,
            hintText: l10n.agentGenomeSoulHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _roleController,
          decoration: InputDecoration(
            labelText: l10n.agentGenomeRoleLabel,
            hintText: l10n.agentGenomeRoleHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        // Goals
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.agentGenomeGoalsLabel,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ..._goals.asMap().entries.map(
              (entry) => Chip(
                label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  setState(() {
                    _goals.removeAt(entry.key);
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _goalController,
                decoration: InputDecoration(
                  hintText: l10n.agentGenomeAddGoalHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (v) {
                  final trimmed = v.trim();
                  if (trimmed.isNotEmpty) {
                    setState(() {
                      _goals.add(trimmed);
                      _goalController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _backstoryController,
          decoration: InputDecoration(
            labelText: l10n.agentGenomeBackstoryLabel,
            hintText: l10n.agentGenomeBackstoryHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // ─── Step 4: Review ──────────────────────────────────────────────────

  Widget _buildReviewStep(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.agentFactoryReviewSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        // Summary cards
        _ReviewCard(
          icon: lucide.Lucide.User,
          title: l10n.agentFactoryStepIdentity,
          children: [
            _ReviewRow(
              label: l10n.agentFactoryNameLabel,
              value: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : '-',
            ),
            if (_descriptionController.text.trim().isNotEmpty)
              _ReviewRow(
                label: l10n.agentFactoryDescLabel,
                value: _descriptionController.text.trim(),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ReviewCard(
          icon: lucide.Lucide.Shapes,
          title: l10n.agentFactoryStepGenome,
          children: [
            _ReviewRow(
              label: l10n.agentGenomeTypeLabel,
              value: switch (_agentType) {
                AgentType.standard => l10n.agentTypeStandard,
                AgentType.lead => l10n.agentTypeLead,
                AgentType.worker => l10n.agentTypeWorker,
              },
            ),
            if (_identityController.text.trim().isNotEmpty)
              _ReviewRow(
                label: l10n.agentGenomeIdentityLabel,
                value: _identityController.text.trim(),
              ),
            if (_soulController.text.trim().isNotEmpty)
              _ReviewRow(
                label: l10n.agentGenomeSoulLabel,
                value: _soulController.text.trim(),
              ),
            if (_roleController.text.trim().isNotEmpty)
              _ReviewRow(
                label: l10n.agentGenomeRoleLabel,
                value: _roleController.text.trim(),
              ),
            if (_goals.isNotEmpty)
              _ReviewRow(
                label: l10n.agentGenomeGoalsLabel,
                value: _goals.join(', '),
              ),
          ],
        ),
        if (_selectedTemplate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${l10n.agentFactoryBasedOn} ${_selectedTemplate!.name}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Bottom navigation bar ──────────────────────────────────────────

  Widget _buildBottomBar(AppLocalizations l10n, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: Text(l10n.agentFactoryBack),
            )
          else
            const SizedBox.shrink(),
          if (_currentStep < _totalSteps - 1)
            FilledButton(
              onPressed: _canGoNext
                  ? () => setState(() => _currentStep++)
                  : null,
              child: Text(l10n.agentFactoryNext),
            )
          else
            FilledButton(
              onPressed: _isCreating ? null : _createAgent,
              child: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.agentFactoryCreate),
            ),
        ],
      ),
    );
  }

  bool get _canGoNext {
    if (_currentStep == 0) return true;
    if (_currentStep == 1) {
      return _nameController.text.trim().isNotEmpty;
    }
    if (_currentStep == 2) return true;
    return true;
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;
  final ColorScheme colorScheme;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIdx = index ~/ 2;
            final active = stepIdx < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: active
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            );
          }
          // Step dot
          final stepIdx = index ~/ 2;
          final isActive = stepIdx == currentStep;
          final isCompleted = stepIdx < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isActive ? 28 : 24,
                height: isActive ? 28 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colorScheme.primary
                      : isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          lucide.Lucide.Check,
                          size: 14,
                          color: colorScheme.onPrimary,
                        )
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: AppFontWeights.semibold,
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels.length > stepIdx ? labels[stepIdx] : '',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Template Card ──────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: AppFontWeights.semibold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(lucide.Lucide.Check, color: colorScheme.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Review Card ────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: AppFontWeights.semibold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
