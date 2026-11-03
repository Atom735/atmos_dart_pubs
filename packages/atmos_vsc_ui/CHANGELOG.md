# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.3.0-alpha

- Workbench, side bar, panel, and status bar keep the ambient font and only override color and size
- Product icons use `VscCodicon` from `atmos_vsc_codicon_flutter`
- Removed geometric `VscIcons`
- Command palette draws `$(codicon)` icons from command contributions
- Chrome widgets: menu bar, breadcrumbs, panel, button, checkbox, text field, dropdown, badge, progress, tree, list row, section, split, toolbar, banner, notification
- Example gallery shows every component

## 0.2.0

- **Breaking:** no Material / Cupertino — widgets use `package:flutter/widgets.dart`
- `VscUiTheme` is a plain token class + `VscUiThemeScope` (no `ThemeExtension` / lerp)
- Removed `toWorkbenchThemeData()`
- Added `VscPressable`
- Web example runs on `WidgetsApp`

## 0.1.1

- `VscUiTheme.fromColorTheme` uses typed `theme.colors.*`
- `VscUiTheme.of` falls back to `VscThemeScope`
- Full **web** example: themes, tabs, palette, shortcuts, side bars

## 0.1.0

- Initial release: workbench shell, activity / side / status bars, editor tabs
- Command palette overlay wired to `atmos_vsc_commands`
- Theme tokens from `VscColorTheme` / `VscUiTheme`
