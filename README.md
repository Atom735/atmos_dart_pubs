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
| [atmos_filesystem](packages/atmos_filesystem) | Portable VS Code–like filesystem API (providers, memory) | [pub.dev](https://pub.dev/packages/atmos_filesystem) |
| [atmos_filesystem_web](packages/atmos_filesystem_web) | Browser FSA adapter for `atmos_filesystem` | [pub.dev](https://pub.dev/packages/atmos_filesystem_web) |
| [atmos_web_files_system_access_api](packages/atmos_web_files_system_access_api) | File System Access API bindings | [pub.dev](https://pub.dev/packages/atmos_web_files_system_access_api) |
| [atmos_web_js_utils](packages/atmos_web_js_utils) | Browser JS interop helpers (Promise↔Future, …) | [pub.dev](https://pub.dev/packages/atmos_web_js_utils) |
| [atmos_multithreading](packages/atmos_multithreading) | Portable parallel compute API (jobs / local pool) | [pub.dev](https://pub.dev/packages/atmos_multithreading) |
| [atmos_multithreading_web](packages/atmos_multithreading_web) | Web Worker pool for `atmos_multithreading` | [pub.dev](https://pub.dev/packages/atmos_multithreading_web) |
| [atmos_web_worker](packages/atmos_web_worker) | Browser Web Worker bindings | [pub.dev](https://pub.dev/packages/atmos_web_worker) |
| [atmos_web_shared_buffer_api](packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics bindings | [pub.dev](https://pub.dev/packages/atmos_web_shared_buffer_api) |

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
