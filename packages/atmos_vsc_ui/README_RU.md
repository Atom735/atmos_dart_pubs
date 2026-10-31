# atmos_vsc_ui

English: [README.md](README.md).

Flutter-виджеты оболочки в духе **VS Code / Cursor** от
[Atom735](https://github.com/Atom735) — **без Material и Cupertino**.

- Оболочка: меню, title bar, activity bar, side bar, хлебные крошки, вкладки, нижняя панель, status bar
- Контролы: кнопка, checkbox, поле ввода, dropdown, badge, progress, дерево, строка списка, секция, split, toolbar, баннер, уведомление
- Command palette поверх [`atmos_vsc_commands`](../atmos_vsc_commands)
- Цвета хрома через `VscUiTheme` / `VscUiThemeScope` (или `VscThemeScope`)
- Иконки: [`atmos_vsc_codicon_flutter`](../atmos_vsc_codicon_flutter) (`VscCodicon`)

В примере пункт **Widgets** открывает галерею всех компонентов.

## Установка

```yaml
dependencies:
  atmos_vsc_ui: ^0.3.0-alpha
```

## Быстрый старт

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

## Пример (web)

```bash
cd packages/atmos_vsc_ui/example
flutter run -d chrome
```

## Лицензия

MIT. См. [LICENSE](LICENSE).
