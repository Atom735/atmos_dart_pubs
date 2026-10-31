# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.3.1

- `null` and blank `colors` values clear an inherited workbench color
- Filesystem loading moved to `package:atmos_vsc_theme/atmos_vsc_theme_io.dart` (`VscThemeIo`) so the core library does not import `dart:io`

## 0.3.0

- Generated typed workbench accessors: `theme.colors.editor.background`
- Raw map moved to `colorMap` (constructor still accepts `colors:`)
- Generator: `dart run tool/generate_workbench_colors.dart`
- Nested `include` resolves relative to each file; async URI loaders
- `==` / `hashCode` on theme / token / semantic models

## 0.2.0

- Ship bundled color themes under `lib/themes/` (VS Code defaults + 2026, Cursor, Abyss, Monokai, Solarized, …)
- Add `VscBundledThemes` / `VscBundledTheme` path helpers for filesystem and Flutter assets
- Document third-party theme provenance in `lib/themes/NOTICE.md`

## 0.1.0

- Initial release under package name `atmos_vsc_theme`
- `include` merge, hex colors, theme / token / semantic models
- UTF-8 loaders (`parseColorThemeUtf8`, `loadColorThemeBytes`)
- `VscColor` ops: `blendOver`, `mix`/`lerp`, `lighten`/`darken`, contrast
- Filesystem loader for VS Code / Cursor color theme JSON
