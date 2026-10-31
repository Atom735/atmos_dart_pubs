# atmos_vsc_theme

Русский: [README_RU.md](README_RU.md).

Parse **VS Code / Cursor** color theme JSON into Dart models by [Atom735](https://github.com/Atom735).

- JSONC via [`atmos_jsonc`](https://pub.dev/packages/atmos_jsonc) (`//` / `/* */`, trailing commas)
- Recursive `include` merge (`colors` override, `null` / `""` clears a key, `tokenColors` append)
- Hex colors: `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`
- Color helpers: `blendOver`, `mix` / `lerp`, `lighten` / `darken`, contrast
- Semantic token styles (`foreground` / `fontStyle`)
- UTF-8 byte load without a full document `String`

For Flutter `ThemeData` / `ColorScheme`, see [`atmos_vsc_theme_flutter`](../atmos_vsc_theme_flutter).

## Install

```yaml
dependencies:
  atmos_vsc_theme: ^0.3.1
```

## Quick start

```dart
import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart';

void main() {
  final theme = VscThemeIo.loadColorThemePath(
    VscBundledThemes.darkModern.packageLibPath,
  );

  print(theme.name); // Default Dark Modern
  print(theme.colors.editor.background?.toHex()); // #1f1f1f
  print(theme['sideBar.foreground']?.toHex()); // raw key still works
  print(theme.tokenColors.length);
  print(theme.semanticTokenColors['newOperator']?.foreground?.toHex());

  // Resolve translucent workbench color against editor background
  final selection = theme['editor.selectionBackground'];
  final bg = theme.editorBackground;
  if (selection != null && bg != null) {
    print(selection.blendOver(bg).toHex());
  }
}
```

### Flutter assets

Prefer [`atmos_vsc_theme_flutter`](../atmos_vsc_theme_flutter)
`VscThemeAssetLoader` (handles nested `include`):

```dart
final theme = await VscThemeAssetLoader.load(VscBundledThemes.darkModern);
// theme.colors.editor.background
```

Assets are declared by `atmos_vsc_theme_flutter`. Apps that depend only on
`atmos_vsc_theme` must list `packages/atmos_vsc_theme/themes/...` themselves.

### UTF-8 bytes

```dart
import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart';

final theme = VscThemeIo.loadColorThemeBytes(
  file.readAsBytesSync(),
  includeBase: file.parent,
);
```

### From a string (custom include resolver)

```dart
final theme = VscThemeLoader.parseColorTheme(
  source,
  resolveInclude: (relative) => File('themes/$relative').readAsStringSync(),
);
```

## Scope

Supported color-theme JSON fields: `name`, `type`, `include`, `colors`,
`tokenColors` (inline array), `semanticHighlighting`, `semanticTokenColors`.

`colors` values of `null` or `""` remove that key from an included parent.
Any other non-hex value is ignored and the parent color stays.

Not supported: `tokenColors` as a path to a TextMate `.tmTheme` file.
Filesystem helpers (`VscThemeIo`) are in `atmos_vsc_theme_io.dart` (`dart:io`).

### Typed colors

Workbench keys from bundled themes are generated into nested getters:

```dart
theme.colors.editor.background;
theme.colors.activityBar.foreground;
theme.colors.focusBorder;
```

Regenerate after adding theme JSON keys:

```bash
dart run tool/generate_workbench_colors.dart
```

## Bundled themes

`lib/themes/` ships color themes copied from VS Code / Cursor built-ins
(see [lib/themes/NOTICE.md](lib/themes/NOTICE.md)). Catalog:
[`VscBundledThemes`](lib/src/bundled_themes.dart).

| Folder | Source |
|--------|--------|
| `defaults/` | VS Code `theme-defaults` (+ `2026-*.json` from upstream) |
| `cursor/` | Cursor `theme-cursor` |
| `abyss/`, `monokai/`, `solarized-*`, … | Matching VS Code / Cursor theme extensions |

## License

MIT for package code. See [LICENSE](LICENSE). Bundled theme JSON: see
[lib/themes/NOTICE.md](lib/themes/NOTICE.md).
