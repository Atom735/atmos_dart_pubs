# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.0.1-alpha

- Bundled OS default keybinding JSON via git submodule (Windows / macOS / Linux)
- Owns `VscKeybinding` model + JSONC loader (no `atmos_vsc_commands` dep)
- Pure-Dart hotkey engine: chords, when-clauses, default + user layers
- Key string parser (`ctrl+k ctrl+c`, punctuation literals like `ctrl+/`)
- `when`: `=~ /regex/`, numeric compares, boolean literals
- Engine: `replaceBindings` / `applyUser`, `skippedBindings`, lookups
- Negative dumps (`*.negative.keybindings.json`) in bundled API
