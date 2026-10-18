/// Parse VS Code / Cursor color themes (JSONC, `include` merge, hex colors).
///
/// ## ENG
/// Pure Dart — no Flutter dependency. Use `VscodeThemeLoader` to load themes,
/// then read `VscodeColorTheme.colors` / `VscodeColorTheme.tokenColors`.
/// JSONC parsing is provided by package `atmos_jsonc`.
///
/// ## RU
/// Чистый Dart без Flutter. Загрузка через `VscodeThemeLoader`, далее
/// `VscodeColorTheme.colors` / `VscodeColorTheme.tokenColors`.
/// JSONC — пакет `atmos_jsonc`.
library atmos_vscode_theme;

export 'package:atmos_jsonc/atmos_jsonc.dart' show jsoncDecode, stripJsonc;

export 'src/color.dart';
export 'src/loader.dart';
export 'src/theme.dart';
export 'src/token_color.dart';
