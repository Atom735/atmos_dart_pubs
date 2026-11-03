import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'activity_bar.dart';
import 'editor_tabs.dart';
import 'side_bar.dart';
import 'status_bar.dart';
import 'title_bar.dart';

/// VS Code-like workbench shell.
class VscWorkbench extends StatelessWidget {
  /// Creates a workbench layout.
  const VscWorkbench({
    super.key,
    required this.title,
    required this.activityItems,
    required this.sideBarTitle,
    required this.sideBar,
    required this.tabs,
    required this.editor,
    this.selectedActivityId,
    this.onActivitySelected,
    this.selectedTabId,
    this.onTabSelected,
    this.onTabClose,
    this.statusLeading = const [],
    this.statusTrailing = const [],
    this.titleBarLeading,
    this.titleBarActions = const [],
    this.showSideBar = true,
    this.sideBarWidth = 260,
    this.breadcrumbs,
    this.panel,
    this.panelHeight = 160,
  });

  /// Window title.
  final String title;

  /// Activity bar entries.
  final List<VscActivityBarItem> activityItems;

  /// Selected activity id.
  final String? selectedActivityId;

  /// Activity selection callback.
  final ValueChanged<String>? onActivitySelected;

  /// Side bar section title.
  final String sideBarTitle;

  /// Side bar body.
  final Widget sideBar;

  /// Whether the side bar is visible.
  final bool showSideBar;

  /// Side bar width.
  final double sideBarWidth;

  /// Editor tabs.
  final List<VscEditorTab> tabs;

  /// Active tab id.
  final String? selectedTabId;

  /// Tab selection.
  final ValueChanged<String>? onTabSelected;

  /// Tab close.
  final ValueChanged<String>? onTabClose;

  /// Main editor area.
  final Widget editor;

  /// Status bar left.
  final List<Widget> statusLeading;

  /// Status bar right.
  final List<Widget> statusTrailing;

  /// Title bar leading.
  final Widget? titleBarLeading;

  /// Title bar trailing actions.
  final List<Widget> titleBarActions;

  /// Optional bar between the editor tabs and the editor body.
  final Widget? breadcrumbs;

  /// Optional bottom panel under the editor.
  final Widget? panel;

  /// Height of [panel] when it is shown.
  final double panelHeight;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ColoredBox(
      color: theme.editorBackground,
      child: Column(
        children: [
          VscTitleBar(
            title: title,
            leading: titleBarLeading,
            actions: titleBarActions,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VscActivityBar(
                  items: activityItems,
                  selectedId: selectedActivityId,
                  onSelected: onActivitySelected,
                ),
                if (showSideBar)
                  VscSideBar(
                    title: sideBarTitle,
                    width: sideBarWidth,
                    child: sideBar,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VscEditorTabs(
                        tabs: tabs,
                        selectedId: selectedTabId,
                        onSelected: onTabSelected,
                        onClose: onTabClose,
                      ),
                      if (breadcrumbs != null) breadcrumbs!,
                      Expanded(
                        child: ColoredBox(
                          color: theme.editorBackground,
                          child: DefaultTextStyle(
                            style: DefaultTextStyle.of(context).style.merge(
                                  TextStyle(
                                    color: theme.editorForeground,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                            child: editor,
                          ),
                        ),
                      ),
                      if (panel != null)
                        SizedBox(height: panelHeight, child: panel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VscStatusBar(
            leading: statusLeading,
            trailing: statusTrailing,
          ),
        ],
      ),
    );
  }
}
