# atmos_vsc_ui

Русский: [README_RU.md](README_RU.md).

Flutter widgets for a **VS Code / Cursor-like** workbench UI by
[Atom735](https://github.com/Atom735) — **without Material or Cupertino**.

- Workbench shell: menu bar, title bar, activity bar, side bar, breadcrumbs, editor tabs, bottom panel, status bar
- Controls: button, checkbox, text field, dropdown, badge, progress, tree, list row, section, split, toolbar, banner, notification
- Command palette over [`atmos_vsc_commands`](../atmos_vsc_commands)
- Chrome colors via `VscUiTheme` / `VscUiThemeScope` (or `VscThemeScope`)
- Icons: [`atmos_vsc_codicon_flutter`](../atmos_vsc_codicon_flutter) (`VscCodicon`)

The example activity **Widgets** opens a gallery of every component.

## Install

```yaml
dependencies:
  atmos_vsc_ui: ^0.3.0-alpha
```

## Quick start

```dart
import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';

Widget buildWorkbench(VscColorTheme colorTheme) {
  return VscThemeScope(
    theme: colorTheme,
    child: VscUiThemeScope(
      theme: VscUiTheme.fromColorTheme(colorTheme),
      child: WidgetsApp(
        color: const Color(0xFF1E1E1E),
        pageRouteBuilder: <T>(settings, builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return builder(context);
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return child;
            },
          );
        },
        home: VscWorkbench(
          title: 'My Workspace',
          activityItems: [
            VscActivityBarItem(
              id: 'explorer',
              icon: const VscCodicon(VscCodicons.files, size: 24),
              tooltip: 'Explorer',
            ),
          ],
          selectedActivityId: 'explorer',
          sideBarTitle: 'Explorer',
          sideBar: const Center(child: Text('files…')),
          tabs: const [
            VscEditorTab(id: 'main', label: 'main.dart'),
          ],
          selectedTabId: 'main',
          editor: const Center(child: Text('editor')),
          statusLeading: const [Text('UTF-8')],
          statusTrailing: const [Text('Dart')],
        ),
      ),
    ),
  );
}
```

### Command palette

```dart
final cmd = await VscCommandPalette.show(
  context,
  commands: contributions.commands,
);
```

## Example (web)

```bash
cd packages/atmos_vsc_ui/example
flutter run -d chrome
```

## License

MIT. See [LICENSE](LICENSE).
