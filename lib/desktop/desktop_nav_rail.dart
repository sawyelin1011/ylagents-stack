import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/emoji_text.dart';
import '../l10n/app_localizations.dart';
import '../core/providers/user_provider.dart';
import '../core/providers/settings_provider.dart';
import 'user_profile_dialog.dart';
import '../icons/lucide_adapter.dart' as lucide;
import '../utils/sandbox_path_resolver.dart';
import '../theme/app_font_weights.dart';

/// Workspace-first desktop nav tabs.
enum NavTab {
  dashboard,
  tasks,
  agents,
  knowledge,
  channels,
  sync,
  runtime,
  chats,
  settings,
}

/// A compact left rail for desktop with workspace-first navigation.
///
/// Layout (top to bottom):
///   Avatar / Dashboard / Tasks / Agents / Knowledge / Chats / Spacer / More / Settings
class DesktopNavRail extends StatelessWidget {
  const DesktopNavRail({
    super.key,
    required this.activeTab,
    required this.onTapDashboard,
    required this.onTapTasks,
    required this.onTapAgents,
    required this.onTapKnowledge,
    required this.onTapChannels,
    required this.onTapSync,
    required this.onTapRuntime,
    required this.onTapChats,
    required this.onTapSettings,
    this.onTapMore,
  });

  final NavTab activeTab;
  final VoidCallback onTapDashboard;
  final VoidCallback onTapTasks;
  final VoidCallback onTapAgents;
  final VoidCallback onTapKnowledge;
  final VoidCallback onTapChannels;
  final VoidCallback onTapSync;
  final VoidCallback onTapRuntime;
  final VoidCallback onTapChats;
  final VoidCallback onTapSettings;
  final VoidCallback? onTapMore;

  static const double width = 64.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isMac = Platform.isMacOS;
    final double topGap = isMac ? 36.0 : 8.0;

    return Container(
      width: width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SizedBox(height: topGap),
          _UserAvatarButton(),
          const SizedBox(height: 12),
          _NavButton(
            tooltip: l10n.desktopNavDashboardTooltip,
            icon: lucide.Lucide.ChartColumnBig,
            isActive: activeTab == NavTab.dashboard,
            onTap: onTapDashboard,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavTasksTooltip,
            icon: lucide.Lucide.CheckSquare,
            isActive: activeTab == NavTab.tasks,
            onTap: onTapTasks,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavAgentsTooltip,
            icon: lucide.Lucide.Bot,
            isActive: activeTab == NavTab.agents,
            onTap: onTapAgents,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavKnowledgeTooltip,
            icon: lucide.Lucide.BookOpen,
            isActive: activeTab == NavTab.knowledge,
            onTap: onTapKnowledge,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavChannelsTooltip,
            icon: lucide.Lucide.Network,
            isActive: activeTab == NavTab.channels,
            onTap: onTapChannels,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavSyncTooltip,
            icon: lucide.Lucide.RefreshCw,
            isActive: activeTab == NavTab.sync,
            onTap: onTapSync,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavRuntimeTooltip,
            icon: lucide.Lucide.Server,
            isActive: activeTab == NavTab.runtime,
            onTap: onTapRuntime,
          ),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavChatTooltip,
            icon: lucide.Lucide.MessageCircle,
            isActive: activeTab == NavTab.chats,
            onTap: onTapChats,
          ),
          const Spacer(),
          if (onTapMore != null)
            _NavButton(
              tooltip: l10n.desktopNavMoreTooltip,
              icon: lucide.Lucide.Ellipsis,
              isActive: false,
              onTap: onTapMore!,
            ),
          const SizedBox(height: 8),
          _ThemeCycleButton(),
          const SizedBox(height: 8),
          _NavButton(
            tooltip: l10n.desktopNavSettingsTooltip,
            icon: lucide.Lucide.Settings,
            isActive: activeTab == NavTab.settings,
            onTap: onTapSettings,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// A single nav icon button with active state and hover.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tooltip,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: onTap,
        child: _HoverCircle(
          size: 40,
          child: Icon(
            icon,
            size: 18,
            color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _UserAvatarButton extends StatefulWidget {
  @override
  State<_UserAvatarButton> createState() => _UserAvatarButtonState();
}

class _UserAvatarButtonState extends State<_UserAvatarButton> {
  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();
    final cs = Theme.of(context).colorScheme;
    Widget avatar;
    final type = up.avatarType;
    final value = up.avatarValue;
    if (type == 'emoji' && value != null && value.isNotEmpty) {
      avatar = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: EmojiText(value, fontSize: 18, optimizeEmojiAlign: true),
      );
    } else if (type == 'url' && value != null && value.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          value,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _initialAvatar(up.name, cs);
          },
        ),
      );
    } else if (type == 'file' && value != null && value.isNotEmpty) {
      final fixed = SandboxPathResolver.fix(value);
      final f = File(fixed);
      if (f.existsSync()) {
        avatar = ClipOval(
          child: Image(
            image: FileImage(f),
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        );
      } else {
        avatar = _initialAvatar(up.name, cs);
      }
    } else {
      avatar = _initialAvatar(up.name, cs);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          showUserProfileDialog(context);
        },
        onSecondaryTap: () {
          showUserProfileDialog(context);
        },
        child: _HoverCircle(size: 42, child: avatar),
      ),
    );
  }

  Widget _initialAvatar(String name, ColorScheme cs) {
    final letter = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: cs.primary,
          fontWeight: AppFontWeights.emphasis,
          decoration: TextDecoration.none,
          fontSize: 36 * 0.44,
        ),
      ),
    );
  }
}

class _HoverCircle extends StatefulWidget {
  const _HoverCircle({required this.child, this.size = 44});
  final Widget child;
  final double size;
  @override
  State<_HoverCircle> createState() => _HoverCircleState();
}

class _HoverCircleState extends State<_HoverCircle> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _hovered
              ? cs.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

class _ThemeCycleButton extends StatefulWidget {
  @override
  State<_ThemeCycleButton> createState() => _ThemeCycleButtonState();
}

class _ThemeCycleButtonState extends State<_ThemeCycleButton> {
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final icon = _iconFor(sp.themeMode);
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.desktopNavThemeToggleTooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => _cycleTheme(context),
        child: _HoverCircle(
          size: 40,
          child: Icon(
            icon,
            size: 20,
            color: cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lucide.Lucide.Sun;
      case ThemeMode.dark:
        return lucide.Lucide.Moon;
      case ThemeMode.system:
        return lucide.Lucide.Monitor;
    }
  }

  void _cycleTheme(BuildContext context) {
    final sp = context.read<SettingsProvider>();
    final current = sp.themeMode;
    final next = () {
      switch (current) {
        case ThemeMode.system:
          return ThemeMode.light;
        case ThemeMode.light:
          return ThemeMode.dark;
        case ThemeMode.dark:
          return ThemeMode.system;
      }
    }();
    sp.setThemeMode(next);
  }
}
