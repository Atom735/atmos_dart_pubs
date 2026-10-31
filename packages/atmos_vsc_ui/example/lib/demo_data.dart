import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';

/// One openable demo file.
class DemoFile {
  const DemoFile({
    required this.id,
    required this.path,
    required this.language,
    required this.content,
  });

  final String id;
  final String path;
  final String language;
  final String content;

  String get name => path.split('/').last;
}

/// Selectable bundled color theme for the demo.
class DemoThemeOption {
  const DemoThemeOption({
    required this.id,
    required this.label,
    required this.bundled,
  });

  final String id;
  final String label;
  final VscBundledTheme bundled;
}

/// Static content for the workbench demo.
abstract final class DemoData {
  static const themes = <DemoThemeOption>[
    DemoThemeOption(
      id: 'darkModern',
      label: 'Dark Modern',
      bundled: VscBundledThemes.darkModern,
    ),
    DemoThemeOption(
      id: 'dark2026',
      label: '2026 Dark',
      bundled: VscBundledThemes.dark2026,
    ),
    DemoThemeOption(
      id: 'cursorDark',
      label: 'Cursor Dark',
      bundled: VscBundledThemes.cursorDark,
    ),
    DemoThemeOption(
      id: 'cursorMidnight',
      label: 'Cursor Dark Midnight',
      bundled: VscBundledThemes.cursorDarkMidnight,
    ),
    DemoThemeOption(
      id: 'lightModern',
      label: 'Light Modern',
      bundled: VscBundledThemes.lightModern,
    ),
    DemoThemeOption(
      id: 'light2026',
      label: '2026 Light',
      bundled: VscBundledThemes.light2026,
    ),
    DemoThemeOption(
      id: 'cursorLight',
      label: 'Cursor Light',
      bundled: VscBundledThemes.cursorLight,
    ),
  ];

  static const files = <DemoFile>[
    DemoFile(
      id: 'main',
      path: 'lib/main.dart',
      language: 'Dart',
      content: r'''
import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = await VscThemeAssetLoader.load(
    VscBundledThemes.darkModern,
  );
  runApp(MyApp(theme: theme));
}
''',
    ),
    DemoFile(
      id: 'workbench',
      path: 'lib/src/widgets/workbench.dart',
      language: 'Dart',
      content: r'''
/// VS Code-like workbench shell (no Material).
class VscWorkbench extends StatelessWidget {
  const VscWorkbench({super.key, required this.editor});
  final Widget editor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VscUiTheme.of(context).editorBackground,
      child: editor,
    );
  }
}
''',
    ),
    DemoFile(
      id: 'pubspec',
      path: 'pubspec.yaml',
      language: 'YAML',
      content: '''
name: atmos_vsc_ui_example
publish_to: none

dependencies:
  atmos_vsc_ui:
    path: ../
  flutter:
    sdk: flutter
''',
    ),
    DemoFile(
      id: 'readme',
      path: 'README.md',
      language: 'Markdown',
      content: '''
# atmos_vsc_ui example

Flutter **web** demo (WidgetsApp, no Material).

```bash
flutter run -d chrome
```
''',
    ),
    DemoFile(
      id: 'analysis',
      path: 'analysis_options.yaml',
      language: 'YAML',
      content: '''
include: package:flutter_lints/flutter.yaml
''',
    ),
  ];

  static DemoFile? fileById(String id) {
    for (final f in files) {
      if (f.id == id) return f;
    }
    return null;
  }

  static List<VscCommand> buildCommands() {
    return VscCommandsLoader.parseContributions(r'''
    {
      "contributes": {
        "commands": [
          { "command": "workbench.action.showCommands", "title": "Show All Commands", "category": "View", "icon": "$(list-flat)" },
          { "command": "workbench.action.quickOpen", "title": "Go to File…", "category": "Go", "icon": "$(go-to-file)" },
          { "command": "workbench.action.toggleSidebarVisibility", "title": "Toggle Primary Side Bar Visibility", "category": "View", "icon": "$(layout-sidebar-left)" },
          { "command": "workbench.action.closeActiveEditor", "title": "Close Editor", "category": "View", "icon": "$(close)" },
          { "command": "workbench.action.files.newUntitledFile", "title": "New Untitled Text File", "category": "File", "icon": "$(new-file)" },
          { "command": "editor.action.formatDocument", "title": "Format Document", "category": "Format", "icon": "$(whitespace)" },
          { "command": "demo.theme.darkModern", "title": "Dark Modern", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.dark2026", "title": "2026 Dark", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.cursorDark", "title": "Cursor Dark", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.cursorMidnight", "title": "Cursor Dark Midnight", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.lightModern", "title": "Light Modern", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.light2026", "title": "2026 Light", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" },
          { "command": "demo.theme.cursorLight", "title": "Cursor Light", "category": "Preferences: Color Theme", "icon": "$(symbol-color)" }
        ]
      }
    }
    ''').commands;
  }

  static List<VscActivityBarItem> activityItems() => const [
        VscActivityBarItem(
          id: 'explorer',
          icon: VscCodicon(VscCodicons.files, size: 24),
          tooltip: 'Explorer',
        ),
        VscActivityBarItem(
          id: 'search',
          icon: VscCodicon(VscCodicons.search, size: 24),
          tooltip: 'Search',
        ),
        VscActivityBarItem(
          id: 'scm',
          icon: VscCodicon(VscCodicons.sourceControl, size: 24),
          tooltip: 'Source Control',
        ),
        VscActivityBarItem(
          id: 'extensions',
          icon: VscCodicon(VscCodicons.extensions, size: 24),
          tooltip: 'Extensions',
        ),
        VscActivityBarItem(
          id: 'widgets',
          icon: VscCodicon(
            VscCodicons.preview,
            size: 24,
            semanticLabel: 'Widgets',
          ),
          tooltip: 'Widgets',
        ),
      ];
}
