# atmos_vsc_theme_flutter

English: [README.md](README.md).

Цветовые темы **VS Code / Cursor** → Flutter `ColorScheme` / `ThemeData`,
[Atom735](https://github.com/Atom735).

Зависит от [`atmos_vsc_theme`](../atmos_vsc_theme): разбор JSONC и merge `include`.

## Установка

```yaml
dependencies:
  atmos_vsc_theme_flutter: ^0.3.0
```

## Быстрый старт

```dart
import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter/widgets.dart';

Widget buildApp(VscColorTheme theme) {
  return VscThemeScope(
    theme: theme,
    child: Builder(
      builder: (context) {
        final bg = context.vscTheme.colors.editor.background
            ?.toFlutterColor();
        return ColoredBox(
          color: bg ?? const Color(0xFF1E1E1E),
          child: const Center(child: Text('Hello')),
        );
      },
    ),
  );
}
```

### Загрузка из assets (с `include`)

```dart
final theme = await VscThemeAssetLoader.load(VscBundledThemes.dark2026);
```

### Material ThemeData

```dart
// Если нужны виджеты Material:
// theme: theme.toThemeData(),
```

### Только ColorScheme

```dart
final scheme = theme.toColorScheme();
```

Сопоставляются роли `ColorScheme`, AppBar / titleBar, поля ввода, выделение
текста, checkbox, snackbar, dialog, FAB, elevated buttons. Не у каждого
цвета workbench есть пара в Material.

## Лицензия

MIT. См. [LICENSE](LICENSE).
