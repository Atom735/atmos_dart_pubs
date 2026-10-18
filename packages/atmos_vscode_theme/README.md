# atmos_vscode_theme

Parse **VS Code / Cursor** color theme JSON into Dart models by [Atom735](https://github.com/Atom735).

- JSONC via [`atmos_jsonc`](../atmos_jsonc) (`//` / `/* */`, trailing commas)
- Recursive `include` merge (`colors` override, `tokenColors` append)
- Hex colors: `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`

For Flutter `ThemeData` / `ColorScheme`, see [`atmos_vscode_theme_flutter`](../atmos_vscode_theme_flutter).

## Install

```yaml
dependencies:
  atmos_vscode_theme: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vscode_theme/atmos_vscode_theme.dart';

void main() {
  final theme = VscodeThemeLoader.loadColorThemePath('themes/dark_modern.json');

  print(theme.name); // Dark Modern
  print(theme['editor.background']?.toHex()); // #1f1f1f
  print(theme.tokenColors.length);
}
```

### From a string (custom include resolver)

```dart
final theme = VscodeThemeLoader.parseColorTheme(
  source,
  resolveInclude: (relative) => File('themes/$relative').readAsStringSync(),
);
```

## Fixtures

`test/fixtures/` contains a Dark Modern include chain copied from VS Code
`theme-defaults` (MIT). Use them as samples only — ship your own themes in apps.

## License

MIT. See [LICENSE](LICENSE).
