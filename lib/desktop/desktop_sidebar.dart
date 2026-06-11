import 'dart:async';
import 'package:flutter/material.dart';
import '../features/home/widgets/side_drawer.dart';

/// Desktop sidebar wrapper. Passes workspace context to SideDrawer.
class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.userName,
    required this.assistantName,
    this.onSelectConversation,
    this.onNewConversation,
    this.loadingConversationIds = const <String>{},
    this.workspaceId,
  });

  final String userName;
  final String assistantName;

  /// Callback when a conversation is selected.
  /// The [closeDrawer] parameter is ignored on desktop (sidebar is always visible).
  final FutureOr<void> Function(String id, {bool closeDrawer})?
  onSelectConversation;

  /// Callback when a new conversation is requested.
  /// The [closeDrawer] parameter is ignored on desktop (sidebar is always visible).
  final FutureOr<void> Function({bool closeDrawer})? onNewConversation;
  final Set<String> loadingConversationIds;

  /// If set, only conversations belonging to this workspace are shown.
  final String? workspaceId;

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      embedded: true,
      embeddedWidth: 300,
      userName: userName,
      assistantName: assistantName,
      onSelectConversation: onSelectConversation,
      onNewConversation: onNewConversation,
      loadingConversationIds: loadingConversationIds,
      workspaceId: workspaceId,
      onEnterGlobalSearch: () {},
      onExitGlobalSearch: () {},
      showBottomBar: false,
    );
  }
}
