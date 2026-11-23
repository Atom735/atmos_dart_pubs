# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.0.1-alpha

- Бандл дефолтных keybindings через git-субмодуль (Windows / macOS / Linux)
- Модель `VscKeybinding` + JSONC-загрузчик (без зависимости от commands)
- Pure-Dart движок хоткеев: аккорды, when, слои default + user
- Парсер строк клавиш (`ctrl+/` и named tokens)
- `when`: regex, числовые сравнения, литералы
- Engine: hot-reload биндингов, диагностика skip, lookup
- Negative dumps в bundled API
