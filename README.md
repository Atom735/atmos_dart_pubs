# atmos_dart_pubs

Monorepo for public Flutter and Dart packages by [Atom735](https://github.com/Atom735).

## Layout

```text
packages/
  <package_name>/   # one pub package per folder
```

Each package under `packages/` is published independently to [pub.dev](https://pub.dev).

## Packages

| Package | Description | pub.dev |
|---------|-------------|---------|
| [atmos_binary_buffer](packages/atmos_binary_buffer) | Binary reader/writer, floats, UUID, LEB128, FourCC | [pub.dev](https://pub.dev/packages/atmos_binary_buffer) |
| [atmos_jsonc](packages/atmos_jsonc) | Streaming JSONC decoder (comments, trailing commas, UTF-8) | [pub.dev](https://pub.dev/packages/atmos_jsonc) |
| [atmos_lints](packages/atmos_lints) | Shared analyzer/linter presets (`lints` / `full` / `_2`) | [pub.dev](https://pub.dev/packages/atmos_lints) |
| [atmos_logger](packages/atmos_logger) | Composable logger (console / file / filter) | [pub.dev](https://pub.dev/packages/atmos_logger) |
| [atmos_vscode_theme](packages/atmos_vscode_theme) | Parse VS Code / Cursor color themes (JSONC, `include`) | — |
| [atmos_vscode_theme_flutter](packages/atmos_vscode_theme_flutter) | Theme → Flutter `ColorScheme` / `ThemeData` | — |

## Development

Target toolchain: **Flutter 3.16.9** (and the Dart SDK bundled with it).

```bash
dart pub get
dart run melos bootstrap

# From a package directory
cd packages/<package_name>
dart pub get
# or
flutter pub get
```

Optional: [Melos](https://pub.dev/packages/melos) manages all packages from the repo root (`melos.yaml`).

## License

Unless noted otherwise in a package, code is under the BSD 3-Clause License. See [LICENSE](LICENSE).

Individual packages may carry their own `LICENSE` (some published packages are MIT).
