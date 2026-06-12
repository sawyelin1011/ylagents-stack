import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Kelivo/theme/app_font_weights.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:window_manager/window_manager.dart';
import 'desktop_nav_rail.dart';
import 'desktop_chat_page.dart';
import 'window_title_bar.dart';
import 'desktop_settings_page.dart';
import 'desktop_translate_page.dart';
import '../features/settings/pages/storage_space_page.dart';
import '../icons/lucide_adapter.dart' as lucide;
import '../l10n/app_localizations.dart';
import 'hotkeys/hotkey_event_bus.dart';
import 'hotkeys/chat_action_bus.dart';
import 'desktop_settings_navigation_bus.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/tasks/pages/tasks_page.dart';
import '../features/agents/pages/agents_page.dart';
import '../features/knowledge/pages/knowledge_page.dart';
import '../features/channels/pages/channels_page.dart';
import '../features/sync/pages/sync_page.dart';
import '../features/runtime/pages/runtime_page.dart';

/// Desktop home screen: left compact rail + main content.
///
/// Tabs: Dashboard (0), Tasks (1), Agents (2), Knowledge (3), Channels (4), Sync (5), Runtime (6), Chats (7), Settings (8)
class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({
    super.key,
    this.initialTabIndex,
    this.initialProviderKey,
  });

  final int? initialTabIndex; // Maps to NavTab
  final String? initialProviderKey;

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  NavTab _activeTab = NavTab.dashboard;
  bool _storageVisited = false; // ignore: unused_field
  StreamSubscription<HotkeyAction>? _hotkeySub;
  StreamSubscription<ChatAction>? _chatActionSub;
  StreamSubscription<DesktopSettingsNavigationTarget>? _settingsNavSub;

  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex != null) {
      _activeTab = NavTab
          .values[widget.initialTabIndex!.clamp(0, NavTab.values.length - 1)];
    }
    _storageVisited = _activeTab == NavTab.settings;
    // Focus chat input on chat tab
    if (_activeTab == NavTab.chats) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatActionBus.instance.fire(ChatAction.focusInput);
      });
    }
    // Listen to global hotkey actions
    _hotkeySub = HotkeyEventBus.instance.stream.listen((action) async {
      switch (action) {
        case HotkeyAction.openSettings:
          if (mounted) {
            setState(() {
              _activeTab = NavTab.settings;
            });
            ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
          }
          break;
        case HotkeyAction.closeWindow:
          try {
            await windowManager.close();
          } catch (_) {}
          break;
        case HotkeyAction.toggleAppVisibility:
          try {
            final visible = await windowManager.isVisible();
            final minimized = await windowManager.isMinimized();
            final focused = await windowManager.isFocused();

            if (!visible || minimized) {
              await windowManager.show();
              await windowManager.focus();
              if (_activeTab == NavTab.chats) {
                ChatActionBus.instance.fire(ChatAction.focusInput);
              }
            } else if (!focused) {
              await windowManager.focus();
              if (_activeTab == NavTab.chats) {
                ChatActionBus.instance.fire(ChatAction.focusInput);
              }
            } else {
              await windowManager.hide();
            }
          } catch (_) {}
          break;
        case HotkeyAction.newTopic:
          if (_activeTab == NavTab.chats) {
            ChatActionBus.instance.fire(ChatAction.newTopic);
          }
          break;
        case HotkeyAction.switchModel:
          if (_activeTab == NavTab.chats) {
            ChatActionBus.instance.fire(ChatAction.switchModel);
          }
          break;
        case HotkeyAction.toggleLeftPanelAssistants:
          if (_activeTab == NavTab.chats) {
            ChatActionBus.instance.fire(ChatAction.toggleLeftPanelAssistants);
          }
          break;
        case HotkeyAction.toggleLeftPanelTopics:
          if (_activeTab == NavTab.chats) {
            ChatActionBus.instance.fire(ChatAction.toggleLeftPanelTopics);
          }
          break;
      }
    });

    _chatActionSub = ChatActionBus.instance.stream.listen((action) {
      if (!mounted) return;
      switch (action) {
        case ChatAction.enterGlobalSearch:
          setState(() {
            _activeTab = NavTab.chats;
          });
          break;
        case ChatAction.exitGlobalSearch:
          break;
        default:
          break;
      }
    });
    _settingsNavSub = DesktopSettingsNavigationBus.instance.stream.listen((
      target,
    ) {
      if (!mounted) return;
      switch (target) {
        case DesktopSettingsNavigationTarget.backup:
          setState(() {
            _activeTab = NavTab.settings;
          });
          ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
          break;
      }
    });
  }

  void _switchTab(NavTab tab) {
    setState(() {
      _activeTab = tab;
    });
    ChatActionBus.instance.fire(ChatAction.exitGlobalSearch);
    if (_activeTab == NavTab.chats) {
      ChatActionBus.instance.fire(ChatAction.focusInput);
    }
  }

  void _onDashboardNewChat() {
    _switchTab(NavTab.chats);
    ChatActionBus.instance.fire(ChatAction.newTopic);
  }

  void _onDashboardNewAssistant() {
    _switchTab(NavTab.chats);
    ChatActionBus.instance.fire(ChatAction.newTopic);
  }

  void _showMoreMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + DesktopNavRail.width,
        offset.dy + 400,
        offset.dx + DesktopNavRail.width + 200,
        offset.dy + 500,
      ),
      items: [
        PopupMenuItem(
          value: 'translate',
          child: ListTile(
            leading: const Icon(lucide.Lucide.languages, size: 18),
            title: Text(l10n.desktopNavTranslateTooltip),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'storage',
          child: ListTile(
            leading: const Icon(lucide.Lucide.folder, size: 18),
            title: Text(l10n.desktopNavStorageTooltip),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ).then((value) {
      if (value == 'translate') {
        // ignore: use_build_context_synchronously
        _showTranslatePage(context);
      } else if (value == 'storage') {
        // ignore: use_build_context_synchronously
        _showStoragePage(context);
      }
    });
  }

  void _showTranslatePage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DesktopTranslatePage()));
  }

  void _showStoragePage(BuildContext context) {
    setState(() {
      _storageVisited = true;
    });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StorageSpacePage(embedded: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const minWidth = 960.0;
    const minHeight = 640.0;

    final isWindows = defaultTargetPlatform == TargetPlatform.windows;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final needsWidthPad = w < minWidth;
        final needsHeightPad = h < minHeight;

        Widget body = Row(
          children: [
            DesktopNavRail(
              activeTab: _activeTab,
              onTapDashboard: () => _switchTab(NavTab.dashboard),
              onTapTasks: () => _switchTab(NavTab.tasks),
              onTapAgents: () => _switchTab(NavTab.agents),
              onTapKnowledge: () => _switchTab(NavTab.knowledge),
              onTapChannels: () => _switchTab(NavTab.channels),
              onTapSync: () => _switchTab(NavTab.sync),
              onTapRuntime: () => _switchTab(NavTab.runtime),
              onTapChats: () => _switchTab(NavTab.chats),
              onTapSettings: () => _switchTab(NavTab.settings),
              onTapMore: () => _showMoreMenu(context),
            ),
            Expanded(
              child: IndexedStack(
                index: _activeTab.index,
                children: [
                  DashboardPage(
                    onNewChat: _onDashboardNewChat,
                    onNewAssistant: _onDashboardNewAssistant,
                  ),
                  const TasksPage(),
                  const AgentsPage(),
                  const KnowledgePage(),
                  const ChannelsPage(),
                  const SyncPage(),
                  const RuntimePage(),
                  const DesktopChatPage(),
                  DesktopSettingsPage(
                    key: const ValueKey('settings_page'),
                    initialProviderKey: widget.initialProviderKey,
                  ),
                ],
              ),
            ),
          ],
        );

        final content = isWindows
            ? Column(
                children: [
                  WindowTitleBar(
                    leftChildren: [
                      SizedBox(width: DesktopNavRail.width / 2 - 8 - 6 - 12),
                      const _TitleBarLeading(),
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        body,
                        if (_activeTab == NavTab.settings)
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              )
            : body;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: minWidth,
              minHeight: minHeight,
            ),
            child: SizedBox(
              width: needsWidthPad ? minWidth : w,
              height: needsHeightPad ? minHeight : h,
              child: content,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      _hotkeySub?.cancel();
    } catch (_) {}
    try {
      _chatActionSub?.cancel();
    } catch (_) {}
    try {
      _settingsNavSub?.cancel();
    } catch (_) {}
    super.dispose();
  }
}

class _TitleBarLeading extends StatelessWidget {
  const _TitleBarLeading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/kelivo.png',
          width: 16,
          height: 16,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.aboutPageAppName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: AppFontWeights.semibold,
            color: cs.onSurface.withValues(alpha: 0.8),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
