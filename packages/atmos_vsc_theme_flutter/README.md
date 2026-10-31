# atmos_vsc_theme_flutter

Русский: [README_RU.md](README_RU.md).

Map **VS Code / Cursor** color themes to Flutter `ColorScheme` / `ThemeData`
by [Atom735](https://github.com/Atom735).

Depends on [`atmos_vsc_theme`](../atmos_vsc_theme) for JSONC parsing and
`include` merge.

## Install

```yaml
dependencies:
  atmos_vsc_theme_flutter: ^0.3.0
```

## Quick start

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

### Load from assets (with `include`)

```dart
final theme = await VscThemeAssetLoader.load(VscBundledThemes.dark2026);
```

### Material ThemeData (optional)

```dart
// Still available when you want Material widgets:
// theme: theme.toThemeData(),
```

### ColorScheme only

```dart
final scheme = theme.toColorScheme();
```

Mapped areas: `ColorScheme` roles, AppBar / titleBar, inputs, text selection,
checkbox, snackbar, dialog, FAB, elevated buttons. Not every workbench color
has a Material counterpart.

## License

MIT. See [LICENSE](LICENSE).
