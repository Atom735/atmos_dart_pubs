# Changelog

## 0.0.1-alpha

### EN

- Bundled OS default keybinding JSON via git submodule (Windows / macOS / Linux)
- Owns `VscKeybinding` model + JSONC loader (no `atmos_vsc_commands` dep)
- Pure-Dart hotkey engine: chords, when-clauses, default + user layers
- Key string parser (`ctrl+k ctrl+c`, punctuation literals like `ctrl+/`)
- `when`: `=~ /regex/`, numeric compares, boolean literals
- Engine: `replaceBindings` / `applyUser`, `skippedBindings`, lookups
- Negative dumps (`*.negative.keybindings.json`) in bundled API

### RU

- Бандл дефолтных keybindings через git-субмодуль (Windows / macOS / Linux)
- Модель `VscKeybinding` + JSONC-загрузчик (без зависимости от commands)
- Pure-Dart движок хоткеев: аккорды, when, слои default + user
- Парсер строк клавиш (`ctrl+/` и named tokens)
- `when`: regex, числовые сравнения, литералы
- Engine: hot-reload биндингов, диагностика skip, lookup
- Negative dumps в bundled API
