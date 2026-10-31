import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';

/// Scrollable sample of every public chrome widget.
class ComponentGallery extends StatefulWidget {
  /// Creates the gallery.
  const ComponentGallery({super.key, this.onOpenPalette});

  /// Opens the workbench command palette.
  final VoidCallback? onOpenPalette;

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  bool _checked = true;
  String _theme = 'dark';
  bool _banner = true;
  bool _note = true;
  String _panel = 'terminal';
  final _field = TextEditingController(text: 'hello');

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _block(
          'VscBanner',
          _banner
              ? VscBanner(
                  message: 'Workbench banner. Close it to dismiss.',
                  onClose: () => setState(() => _banner = false),
                )
              : VscButton(
                  label: 'Show banner',
                  onPressed: () => setState(() => _banner = true),
                ),
        ),
        _block(
          'VscToolbar',
          VscToolbar(
            children: [
              VscToolbarButton(
                tooltip: 'Save',
                icon: const VscCodicon(VscCodicons.save),
                onPressed: () {},
              ),
              VscToolbarButton(
                tooltip: 'Split',
                icon: const VscCodicon(VscCodicons.splitHorizontal),
                onPressed: () {},
              ),
            ],
          ),
        ),
        _block(
          'VscButton',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VscButton(
                label: 'Primary',
                primary: true,
                icon: const VscCodicon(VscCodicons.check),
                onPressed: () {},
              ),
              const VscButton(label: 'Secondary', onPressed: _noop),
              const VscButton(label: 'Disabled'),
              VscButton(
                label: 'Command palette',
                onPressed: widget.onOpenPalette,
              ),
            ],
          ),
        ),
        _block(
          'VscCheckbox',
          VscCheckbox(
            value: _checked,
            label: _checked ? 'Checked' : 'Unchecked',
            onChanged: (v) => setState(() => _checked = v),
          ),
        ),
        _block(
          'VscTextField',
          VscTextField(
            controller: _field,
            placeholder: 'Type to filter…',
          ),
        ),
        _block(
          'VscDropdown',
          VscDropdown<String>(
            value: _theme,
            items: const [
              VscDropdownItem(value: 'dark', label: 'Dark Modern'),
              VscDropdownItem(value: 'light', label: 'Light Modern'),
              VscDropdownItem(value: 'hc', label: 'High Contrast'),
            ],
            onChanged: (v) => setState(() => _theme = v),
          ),
        ),
        _block(
          'VscBadge',
          const Row(
            children: [
              VscBadge(label: '3'),
              SizedBox(width: 8),
              VscBadge(label: 'M'),
            ],
          ),
        ),
        _block(
          'VscProgressBar',
          const Column(
            children: [
              VscProgressBar(value: 0.65),
              SizedBox(height: 8),
              VscProgressBar(),
            ],
          ),
        ),
        _block(
          'VscTree',
          const VscTree(
            expandAll: true,
            selectedId: 'main',
            nodes: [
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
                ],
              ),
            ],
          ),
        ),
        _block(
          'VscListTile',
          VscListTile(
            label: 'lib/main.dart',
            selected: true,
            leading: const VscCodicon(VscCodicons.goToFile, size: 16),
            trailing: const VscBadge(label: '1'),
            onTap: () {},
          ),
        ),
        _block(
          'VscSection',
          const VscSection(
            title: 'EDITOR',
            child: Text('Collapsible section body'),
          ),
        ),
        _block(
          'VscSplit',
          SizedBox(
            height: 96,
            child: VscSplit(
              first: ColoredBox(
                color: theme.sideBarBackground,
                child: const Center(child: Text('Left')),
              ),
              second: ColoredBox(
                color: theme.widgetBackground,
                child: const Center(child: Text('Right')),
              ),
            ),
          ),
        ),
        _block(
          'VscBreadcrumbs',
          const VscBreadcrumbs(
            items: [
              VscBreadcrumb(label: 'lib'),
              VscBreadcrumb(label: 'src'),
              VscBreadcrumb(label: 'workbench.dart'),
            ],
          ),
        ),
        _block(
          'VscEditorTabs',
          const SizedBox(
            height: 35,
            child: VscEditorTabs(
              tabs: [
                VscEditorTab(id: 'a', label: 'main.dart'),
                VscEditorTab(id: 'b', label: 'README.md', dirty: true),
              ],
              selectedId: 'a',
            ),
          ),
        ),
        _block(
          'VscPanel',
          SizedBox(
            height: 120,
            child: VscPanel(
              selectedId: _panel,
              onSelected: (id) => setState(() => _panel = id),
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
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _panel == 'terminal' ? r'$ flutter test' : 'No problems',
                ),
              ),
            ),
          ),
        ),
        _block(
          'VscMenuBar',
          const VscMenuBar(
            entries: [
              VscMenuEntry(
                label: 'Sample',
                items: [
                  VscMenuItem(label: 'Enabled item', onSelected: _noop),
                  VscMenuItem(label: 'Disabled item'),
                ],
              ),
            ],
          ),
        ),
        _block(
          'VscNotification',
          _note
              ? VscNotification(
                  title: 'Extension installed',
                  message: 'atmos_vsc_ui is ready.',
                  onClose: () => setState(() => _note = false),
                )
              : VscButton(
                  label: 'Show notification',
                  onPressed: () => setState(() => _note = true),
                ),
        ),
        _block(
          'VscPressable',
          VscPressable(
            tooltip: 'Pressable tooltip',
            onTap: () {},
            hoverColor: theme.listHoverBackground,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Hover and click'),
            ),
          ),
        ),
        _block(
          'VscActivityBar',
          const SizedBox(
            height: 96,
            child: VscActivityBar(
              selectedId: 'explorer',
              items: [
                VscActivityBarItem(
                  id: 'explorer',
                  icon: VscCodicon(
                    VscCodicons.files,
                    size: 24,
                    semanticLabel: 'Gallery explorer',
                  ),
                ),
                VscActivityBarItem(
                  id: 'search',
                  icon: VscCodicon(VscCodicons.search, size: 24),
                ),
              ],
            ),
          ),
        ),
        _block(
          'VscTitleBar',
          const VscTitleBar(title: 'atmos_vsc_ui'),
        ),
        _block(
          'VscStatusBar',
          const VscStatusBar(
            leading: [Text('Ln 1, Col 1')],
            trailing: [Text('Dart'), Text('UTF-8')],
          ),
        ),
      ],
    );
  }

  Widget _block(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

void _noop() {}
