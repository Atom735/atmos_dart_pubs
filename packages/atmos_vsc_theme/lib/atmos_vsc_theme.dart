/// Parse VS Code / Cursor color themes (JSONC, `include` merge, hex colors).
///
/// ## ENG
/// Pure Dart — no Flutter dependency and no `dart:io`. Use `VscThemeLoader`
/// to parse themes, then typed `theme.colors.editor.background` or raw
/// `theme['…']`. Filesystem loading is
/// `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`.
/// JSONC parsing is provided by package `atmos_jsonc`.
///
/// ## RU
/// Чистый Dart без Flutter и без `dart:io`. Разбор через `VscThemeLoader`,
/// далее `theme.colors.editor.background` или сырой ключ через `[]`.
/// Файлы — `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`.
/// JSONC — пакет `atmos_jsonc`.
library atmos_vsc_theme;

export 'package:atmos_jsonc/atmos_jsonc.dart' show jsoncDecode, stripJsonc;

export 'src/bundled_themes.dart';
export 'src/color.dart';
export 'src/generated/workbench_colors.g.dart';
export 'src/loader.dart';
export 'src/theme.dart';
export 'src/token_color.dart';
