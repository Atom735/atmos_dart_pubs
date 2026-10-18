# atmos_vscode_theme_flutter

Map **VS Code / Cursor** color themes to Flutter `ColorScheme` / `ThemeData`
by [Atom735](https://github.com/Atom735).

Depends on [`atmos_vscode_theme`](https://pub.dev/packages/atmos_vscode_theme)
for JSONC parsing and `include` merge.

## Install

```yaml
dependencies:
  atmos_vscode_theme_flutter: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vscode_theme_flutter/atmos_vscode_theme_flutter.dart';
import 'package:flutter/material.dart';

Widget buildApp(VscodeColorTheme vscodeTheme) {
  return MaterialApp(
    theme: vscodeTheme.toThemeData(),
    home: const Scaffold(body: Center(child: Text('Hello'))),
  );
}
```

### ColorScheme only

```dart
final scheme = vscodeTheme.toColorScheme();
```

Mapping is curated (editor / button / sideBar / input / titleBar keys). Not every
workbench color has a Material counterpart.

## License

MIT. See [LICENSE](LICENSE).
