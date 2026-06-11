import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/skill.dart';
import '../../../core/providers/skill_provider.dart';
import '../../../core/services/skill_import_export.dart';
import '../../../core/services/skill_marketplace_service.dart';
import '../../../icons/lucide_adapter.dart' as lucide;
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_font_weights.dart';

/// Skills management page — browse marketplace, install/uninstall skills.
class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(lucide.Lucide.BookTemplate, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(l10n.skillsPageTitle),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.skillsPageInstalled),
            Tab(text: l10n.skillsPageMarketplace),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InstalledTab(),
          _MarketplaceTab(onInstalled: () {
            _tabController.animateTo(0);
          }),
        ],
      ),
    );
  }
}

/// Shows installed skills with uninstall option and import functionality.
class _InstalledTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final skillProvider = context.watch<SkillProvider>();
    final skills = skillProvider.getAll();

    return Column(
      children: [
        // Import button
        if (skills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(lucide.Lucide.Import, size: 14),
                  label: Text(l10n.skillsPageImport),
                  onPressed: () => _showImportDialog(context, l10n, cs),
                ),
              ],
            ),
          ),
        Expanded(
          child: skills.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lucide.Lucide.BookTemplate,
                        size: 56,
                        color: cs.onSurface.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.skillsPageEmpty,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.skillsPageEmptyHint,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.3),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: skills.length,
                  itemBuilder: (context, index) =>
                      _SkillCard(skill: skills[index], isMarketplace: false),
                ),
        ),
      ],
    );
  }

  void _showImportDialog(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.skillsPageImportTitle),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.skillsPageImportHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 6,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.skillsPageCancel),
          ),
          FilledButton(
            onPressed: () async {
              final json = controller.text.trim();
              if (json.isEmpty) return;
              final service = SkillImportExportService(
                skillProvider: context.read<SkillProvider>(),
              );
              if (!service.isValidManifest(json)) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(l10n.skillsPageImportInvalid)),
                  );
                }
                return;
              }
              try {
                final count = await service.importAndInstall(json);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.skillsPageImported(count.toString()),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: Text(l10n.skillsPageImportAction),
          ),
        ],
      ),
    );
  }
}

/// Shows available marketplace skills with install option.
class _MarketplaceTab extends StatefulWidget {
  final VoidCallback? onInstalled;

  const _MarketplaceTab({this.onInstalled});

  @override
  State<_MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<_MarketplaceTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final skillProvider = context.watch<SkillProvider>();

    final available = _searchQuery.isEmpty
        ? SkillMarketplaceService.builtInSkills
        : SkillMarketplaceService.search(_searchQuery);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.skillsPageSearchHint,
              prefixIcon:
                  Icon(lucide.Lucide.Search, size: 16),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        // Tag filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            children: SkillMarketplaceService.allTags.map(
              (tag) => FilterChip(
                label: Text(tag, style: const TextStyle(fontSize: 11)),
                selected: _searchQuery.toLowerCase() == tag.toLowerCase(),
                onSelected: (selected) {
                  setState(() {
                    _searchQuery = selected ? tag : '';
                  });
                },
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: available.isEmpty
              ? Center(
                  child: Text(
                    l10n.skillsPageNoResults,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: available.length,
                  itemBuilder: (context, index) => _SkillCard(
                    skill: available[index],
                    isMarketplace: true,
                    isInstalled: skillProvider.isInstalled(available[index].id),
                    onInstalled: widget.onInstalled,
                  ),
                ),
        ),
      ],
    );
  }
}

/// A card showing a skill's name, description, tags, and action button.
class _SkillCard extends StatelessWidget {
  final Skill skill;
  final bool isMarketplace;
  final bool isInstalled;
  final VoidCallback? onInstalled;

  const _SkillCard({
    required this.skill,
    required this.isMarketplace,
    this.isInstalled = false,
    this.onInstalled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  lucide.Lucide.BookTemplate,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: AppFontWeights.semibold,
                          color: cs.onSurface,
                        ),
                      ),
                      if (skill.author != null)
                        Text(
                          'v${skill.version} by ${skill.author}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isMarketplace)
                  isInstalled
                      ? Chip(
                          label: Text(
                            l10n.skillsPageInstalled,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor:
                              Colors.green.withValues(alpha: 0.1),
                        )
                      : FilledButton.tonalIcon(
                          icon: const Icon(lucide.Lucide.Download, size: 14),
                          label: Text(l10n.skillsPageInstall),
                          onPressed: () async {
                            await context
                                .read<SkillProvider>()
                                .install(skill);
                            onInstalled?.call();
                          },
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                else
                  OutlinedButton.icon(
                    icon: Icon(lucide.Lucide.Trash, size: 14, color: cs.error),
                    label: Text(
                      l10n.skillsPageUninstall,
                      style: TextStyle(color: cs.error),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.skillsPageUninstallConfirmTitle),
                          content: Text(
                            l10n.skillsPageUninstallConfirmContent(
                              skill.name,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.skillsPageCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                l10n.skillsPageUninstall,
                                style: TextStyle(color: cs.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await context
                            .read<SkillProvider>()
                            .uninstall(skill.id);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              skill.description,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (skill.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: skill.tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}