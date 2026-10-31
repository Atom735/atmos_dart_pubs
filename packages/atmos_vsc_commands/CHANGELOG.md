# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.0.1-alpha

- `VscCommandService` — registry, execute, enablement, shared context
- `createEngine` shares context with `VscKeybindingEngine`
- Parse `contributes.commands` / `contributes.keybindings` (JSONC)
- Depends on `atmos_vsc_keybindings` (re-exports engine / when / keybinding)
- `VscLocalizedString` from `atmos_vsc_l10n`; optional `%nls%` resolve in loader
