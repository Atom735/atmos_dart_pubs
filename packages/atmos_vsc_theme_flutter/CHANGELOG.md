# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.3.0

- `VscThemeAssetLoader` — load bundled themes from `AssetBundle` with `include`
- Package `flutter: assets:` for all `atmos_vsc_theme` theme folders
- Nullable `VscColor?.toFlutterColor()`

## 0.2.0

- `VscThemeScope` / `context.vscTheme` for subtree theme access
- Depends on `atmos_vsc_theme` typed `theme.colors.*` accessors

## 0.1.0

- Initial release under package name `atmos_vsc_theme_flutter`
- `toColorScheme()` / `toThemeData()` from `VscColorTheme`
- Extra widget themes: selection, checkbox, snackbar, dialog, FAB
- `VscColor.toFlutterColor()` helper
