# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.0.1-alpha

- `VscCommandService` — registry, execute, enablement, общий context
- `createEngine` делит context с `VscKeybindingEngine`
- Парсинг `contributes.commands` / `contributes.keybindings` (JSONC)
- Зависимость от `atmos_vsc_keybindings` (реэкспорт engine / when / keybinding)
- `VscLocalizedString` из `atmos_vsc_l10n`; опциональный резолв `%nls%` в loader
