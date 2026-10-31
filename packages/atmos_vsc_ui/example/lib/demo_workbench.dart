import 'package:atmos_vsc_l10n_flutter/atmos_vsc_l10n_flutter.dart';
import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'component_gallery.dart';
import 'demo_data.dart';

/// Interactive workbench shell for the web demo.
class DemoWorkbench extends StatefulWidget {
  const DemoWorkbench({
    super.key,
    required this.commands,
    required this.themeOptionId,
    required this.onSelectTheme,
  });

  final List<VscCommand> commands;
  final String themeOptionId;
  final ValueChanged<String> onSelectTheme;

  @override
  State<DemoWorkbench> createState() => _DemoWorkbenchState();
}

class _DemoWorkbenchState extends State<DemoWorkbench> {
  String _activity = 'explorer';
  bool _showSideBar = true;
  bool _showPanel = true;
  String _panelId = 'terminal';
  String? _statusMessage;
  String _searchQuery = '';

  late List<_OpenTab> _tabs;
  late String _activeTabId;
  int _untitledSeq = 1;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final main = DemoData.fileById('main')!;
    _tabs = [_OpenTab.fromFile(main)];
    _activeTabId = main.id;
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  _OpenTab? get _activeTab {
    for (final t in _tabs) {
      if (t.id == _activeTabId) return t;
    }
    return _tabs.isEmpty ? null : _tabs.first;
  }

  Future<void> _openPalette({bool filesOnly = false}) async {
    final commands = filesOnly
        ? DemoData.files
            .map(
              (f) => VscCommand(
                command: 'demo.open.${f.id}',
                title: VscLocalizedString(f.path),
                category: const VscLocalizedString('File'),
              ),
            )
            .toList()
        : widget.commands;

    final cmd = await VscCommandPalette.show(context, commands: commands);
    if (cmd == null || !mounted) return;
    await _runCommand(cmd);
  }

  Future<void> _runCommand(VscCommand cmd) async {
    final id = cmd.command;
    if (id.startsWith('demo.open.')) {
      final fileId = id.substring('demo.open.'.length);
      final file = DemoData.fileById(fileId);
      if (file != null) _openFile(file);
      return;
    }
    if (id.startsWith('demo.theme.')) {
      widget.onSelectTheme(id.substring('demo.theme.'.length));
      _flash('Theme: ${cmd.title.text}');
      return;
    }

    switch (id) {
      case 'workbench.action.showCommands':
        await _openPalette();
        return;
      case 'workbench.action.quickOpen':
        await _openPalette(filesOnly: true);
        return;
      case 'workbench.action.toggleSidebarVisibility':
        setState(() => _showSideBar = !_showSideBar);
        return;
      case 'workbench.action.closeActiveEditor':
        _closeTab(_activeTabId);
        return;
      case 'workbench.action.files.newUntitledFile':
        _newUntitled();
        return;
      case 'editor.action.formatDocument':
        _flash('Formatted ${_activeTab?.label ?? 'document'}');
        return;
      default:
        _flash(cmd.paletteLabel);
    }
  }

  void _flash(String message) {
    setState(() => _statusMessage = message);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_statusMessage == message) {
        setState(() => _statusMessage = null);
      }
    });
  }

  void _openFile(DemoFile file) {
    setState(() {
      if (!_tabs.any((t) => t.id == file.id)) {
        _tabs = [..._tabs, _OpenTab.fromFile(file)];
      }
      _activeTabId = file.id;
      _activity = 'explorer';
      _showSideBar = true;
    });
  }

  void _newUntitled() {
    final id = 'untitled-${_untitledSeq++}';
    setState(() {
      _tabs = [
        ..._tabs,
        _OpenTab(
          id: id,
          label: 'Untitled-$_untitledSeq',
          language: 'Plain Text',
          content: '',
          dirty: true,
        ),
      ];
      _activeTabId = id;
    });
  }

  void _closeTab(String id) {
    setState(() {
      if (_tabs.length <= 1) {
        _flash('Cannot close the last editor');
        return;
      }
      final index = _tabs.indexWhere((t) => t.id == id);
      if (index < 0) return;
      _tabs = [..._tabs]..removeAt(index);
      if (_activeTabId == id) {
        _activeTabId = _tabs[index > 0 ? index - 1 : 0].id;
      }
    });
  }

  void _openComponents() {
    setState(() {
      if (!_tabs.any((t) => t.id == 'components')) {
        _tabs = [
          ..._tabs,
          const _OpenTab(
            id: 'components',
            label: 'Components',
            language: 'Gallery',
            content: '',
          ),
        ];
      }
      _activeTabId = 'components';
      _activity = 'widgets';
      _showSideBar = true;
    });
  }

  void _cycleTheme() {
    final i =
        DemoData.themes.indexWhere((t) => t.id == widget.themeOptionId);
    final next = DemoData.themes[(i + 1) % DemoData.themes.length];
    widget.onSelectTheme(next.id);
  }

  @override
  Widget build(BuildContext context) {
    final vsc = context.vscTheme;
    final ui = VscUiTheme.of(context);
    final active = _activeTab;
    String? themeLabel;
    for (final t in DemoData.themes) {
      if (t.id == widget.themeOptionId) {
        themeLabel = t.label;
        break;
      }
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
          shift: true,
        ): _openPalette,
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          meta: true,
          shift: true,
        ): _openPalette,
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
            _openPalette(filesOnly: true),
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): () =>
            _openPalette(filesOnly: true),
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
            setState(() => _showSideBar = !_showSideBar),
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
            setState(() => _showSideBar = !_showSideBar),
        const SingleActivator(LogicalKeyboardKey.keyW, control: true): () =>
            _closeTab(_activeTabId),
        const SingleActivator(LogicalKeyboardKey.keyW, meta: true): () =>
            _closeTab(_activeTabId),
      },
      child: Focus(
        autofocus: true,
        child: Builder(
          builder: (context) {
            final l10n = VscL10nScope.of(context);
            final workbench = l10n.t('Workbench');
            return VscWorkbench(
              title: 'atmos_vsc_ui — ${vsc.name ?? workbench}',
              titleBarLeading: VscMenuBar(
                entries: [
                  VscMenuEntry(
                    label: 'File',
                    items: [
                      VscMenuItem(
                        label: 'New File',
                        shortcut: 'Ctrl+N',
                        onSelected: _newUntitled,
                      ),
                      VscMenuItem(
                        label: 'Command Palette',
                        shortcut: 'Ctrl+Shift+P',
                        onSelected: _openPalette,
                      ),
                    ],
                  ),
                  VscMenuEntry(
                    label: 'View',
                    items: [
                      VscMenuItem(
                        label: 'Toggle Side Bar',
                        shortcut: 'Ctrl+B',
                        onSelected: () => setState(
                          () => _showSideBar = !_showSideBar,
                        ),
                      ),
                      VscMenuItem(
                        label: 'Toggle Panel',
                        shortcut: 'Ctrl+J',
                        onSelected: () =>
                            setState(() => _showPanel = !_showPanel),
                      ),
                      VscMenuItem(
                        label: 'Components',
                        onSelected: _openComponents,
                      ),
                    ],
                  ),
                ],
              ),
              activityItems: DemoData.activityItems(),
              selectedActivityId: _activity,
              onActivitySelected: (id) {
                if (id == 'widgets') {
                  _openComponents();
                  return;
                }
                setState(() {
                  _activity = id;
                  _showSideBar = true;
                });
              },
              showSideBar: _showSideBar,
              sideBarTitle: _sideBarTitle,
              sideBar: _buildSideBar(),
              breadcrumbs: VscBreadcrumbs(items: _crumbs(active)),
              tabs: [
                for (final t in _tabs)
                  VscEditorTab(id: t.id, label: t.label, dirty: t.dirty),
              ],
              selectedTabId: _activeTabId,
              onTabSelected: (id) => setState(() => _activeTabId = id),
              onTabClose: _closeTab,
              titleBarActions: [
                VscPressable(
                  onTap: () {
                    l10n.locale = l10n.locale.isDefault
                        ? VscLocale('ru')
                        : VscLocale.defaultLocale;
                  },
                  tooltip: l10n.t(
                    'Locale: {0}',
                    args: [
                      if (l10n.locale.isDefault) 'en' else l10n.locale.tag,
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.locale.isDefault ? 'EN' : 'RU',
                      style: TextStyle(
                        color: ui.titleBarForeground,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                VscPressable(
                  onTap: _openPalette,
                  tooltip: 'Command Palette (Ctrl+Shift+P)',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: VscCodicon(
                      VscCodicons.terminal,
                      color: ui.titleBarForeground,
                    ),
                  ),
                ),
                VscPressable(
                  onTap: _cycleTheme,
                  tooltip: 'Cycle color theme',
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VscCodicon(
                          VscCodicons.symbolColor,
                          color: ui.titleBarForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          themeLabel ?? 'Theme',
                          style: TextStyle(
                            color: ui.titleBarForeground,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              editor: active?.id == 'components'
                  ? ComponentGallery(onOpenPalette: _openPalette)
                  : _EditorPane(
                      tab: active,
                      foreground: ui.editorForeground,
                    ),
              panel: _showPanel ? _panel() : null,
              statusLeading: [
                Text(
                  _statusMessage ?? l10n.t('atmos_vsc_ui example'),
                ),
                if (active != null) Text(active.language),
              ],
              statusTrailing: [
                Text(themeLabel ?? ''),
                const Text('UTF-8'),
                const Text('LF'),
                VscPressable(
                  onTap: _openPalette,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('⌘P'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<VscBreadcrumb> _crumbs(_OpenTab? tab) {
    if (tab == null) return const [];
    if (tab.id == 'components') {
      return const [
        VscBreadcrumb(label: 'example'),
        VscBreadcrumb(label: 'Components'),
      ];
    }
    final path = DemoData.fileById(tab.id)?.path ?? tab.label;
    return [
      for (final part in path.split('/')) VscBreadcrumb(label: part),
    ];
  }

  Widget _panel() {
    final terminal = _panelId == 'terminal';
    return VscPanel(
      selectedId: _panelId,
      onSelected: (id) => setState(() => _panelId = id),
      onClose: () => setState(() => _showPanel = false),
      tabs: const [
        VscPanelTab(
          id: 'terminal',
          label: 'TERMINAL',
          icon: VscCodicon(VscCodicons.terminal, size: 14),
        ),
        VscPanelTab(
          id: 'problems',
          label: 'PROBLEMS',
          icon: VscCodicon(VscCodicons.warning, size: 14),
        ),
      ],
      child: terminal
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Text(r'$ flutter test'),
            )
          : const VscListTile(
              label: 'No problems have been detected.',
              leading: VscCodicon(VscCodicons.check, size: 16),
            ),
    );
  }

  String get _sideBarTitle {
    switch (_activity) {
      case 'search':
        return 'SEARCH';
      case 'scm':
        return 'SOURCE CONTROL';
      case 'extensions':
        return 'EXTENSIONS';
      case 'widgets':
        return 'WIDGETS';
      default:
        return 'EXPLORER';
    }
  }

  Widget _buildSideBar() {
    switch (_activity) {
      case 'search':
        return _SearchSideBar(
          controller: _searchController,
          focusNode: _searchFocus,
          query: _searchQuery,
          onOpen: _openFile,
        );
      case 'scm':
        return _ScmSideBar(onOpen: _openFile);
      case 'extensions':
        return const _ExtensionsSideBar();
      case 'widgets':
        return _WidgetsSideBar(onOpen: _openComponents);
      default:
        return _ExplorerSideBar(
          activeId: _activeTabId,
          onOpen: _openFile,
        );
    }
  }
}

class _OpenTab {
  const _OpenTab({
    required this.id,
    required this.label,
    required this.language,
    required this.content,
    this.dirty = false,
  });

  factory _OpenTab.fromFile(DemoFile file) => _OpenTab(
        id: file.id,
        label: file.name,
        language: file.language,
        content: file.content,
      );

  final String id;
  final String label;
  final String language;
  final String content;
  final bool dirty;
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({required this.tab, required this.foreground});

  final _OpenTab? tab;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (tab == null) {
      return const Center(child: Text('No editor open'));
    }
    final lines = tab!.content.split('\n');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 16),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final n = index + 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '$n',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: foreground.withOpacity(0.35),
                  fontFamily: 'Consolas, Monaco, monospace',
                  fontSize: 13,
                  height: 1.45,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lines[index].isEmpty ? ' ' : lines[index],
                style: TextStyle(
                  color: foreground,
                  fontFamily: 'Consolas, Monaco, monospace',
                  fontSize: 13,
                  height: 1.45,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExplorerSideBar extends StatelessWidget {
  const _ExplorerSideBar({
    required this.activeId,
    required this.onOpen,
  });

  final String activeId;
  final ValueChanged<DemoFile> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        VscSection(
          title: 'ATMOS_VSC_UI_EXAMPLE',
          child: VscTree(
            expandAll: true,
            selectedId: activeId,
            onSelected: (id) {
              final file = DemoData.fileById(id);
              if (file != null) onOpen(file);
            },
            nodes: const [
              VscTreeNode(
                id: 'lib',
                label: 'lib',
                icon: VscCodicon(VscCodicons.folder, size: 16),
                children: [
                  VscTreeNode(
                    id: 'main',
                    label: 'main.dart',
                    icon: VscCodicon(VscCodicons.file, size: 16),
                  ),
                  VscTreeNode(
                    id: 'src',
                    label: 'src',
                    icon: VscCodicon(VscCodicons.folder, size: 16),
                    children: [
                      VscTreeNode(
                        id: 'widgets',
                        label: 'widgets',
                        icon: VscCodicon(VscCodicons.folder, size: 16),
                        children: [
                          VscTreeNode(
                            id: 'workbench',
                            label: 'workbench.dart',
                            icon: VscCodicon(VscCodicons.file, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              VscTreeNode(
                id: 'pubspec',
                label: 'pubspec.yaml',
                icon: VscCodicon(VscCodicons.file, size: 16),
              ),
              VscTreeNode(
                id: 'readme',
                label: 'README.md',
                icon: VscCodicon(VscCodicons.file, size: 16),
              ),
              VscTreeNode(
                id: 'analysis',
                label: 'analysis_options.yaml',
                icon: VscCodicon(VscCodicons.file, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchSideBar extends StatelessWidget {
  const _SearchSideBar({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onOpen,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<DemoFile> onOpen;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final hits = q.isEmpty
        ? const <DemoFile>[]
        : DemoData.files
            .where(
              (f) =>
                  f.path.toLowerCase().contains(q) ||
                  f.content.toLowerCase().contains(q),
            )
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: VscTextField(
            controller: controller,
            focusNode: focusNode,
            placeholder: 'Search',
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              if (q.isNotEmpty && hits.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No results'),
                ),
              for (final file in hits)
                VscListTile(
                  label: file.path,
                  leading: const VscCodicon(VscCodicons.search, size: 16),
                  onTap: () => onOpen(file),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScmSideBar extends StatelessWidget {
  const _ScmSideBar({required this.onOpen});

  final ValueChanged<DemoFile> onOpen;

  @override
  Widget build(BuildContext context) {
    final changed = [
      DemoData.fileById('main')!,
      DemoData.fileById('pubspec')!,
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final file in changed)
          VscListTile(
            label: file.name,
            leading: const VscCodicon(VscCodicons.sourceControl, size: 16),
            trailing: const VscBadge(label: 'M'),
            onTap: () => onOpen(file),
          ),
      ],
    );
  }
}

class _ExtensionsSideBar extends StatelessWidget {
  const _ExtensionsSideBar();

  @override
  Widget build(BuildContext context) {
    const items = [
      'atmos_vsc_theme',
      'atmos_vsc_commands',
      'atmos_jsonc',
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final name in items)
          VscListTile(
            label: name,
            leading: const VscCodicon(VscCodicons.extensions, size: 16),
            trailing: const VscBadge(label: 'on'),
            onTap: () {},
          ),
      ],
    );
  }
}

class _WidgetsSideBar extends StatelessWidget {
  const _WidgetsSideBar({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    const names = [
      'VscButton',
      'VscCheckbox',
      'VscTextField',
      'VscDropdown',
      'VscTree',
      'VscPanel',
      'VscMenuBar',
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final name in names)
          VscListTile(
            label: name,
            leading: const VscCodicon(VscCodicons.preview, size: 16),
            onTap: onOpen,
          ),
      ],
    );
  }
}
