# atmos_dart_pubs

English: [README.md](README.md).

Монорепозиторий публичных Flutter- и Dart-пакетов [Atom735](https://github.com/Atom735).

## Структура

```text
packages/
  <package_name>/   # один pub-пакет на папку
```

Каждый пакет в `packages/` публикуется на [pub.dev](https://pub.dev) отдельно.

## Пакеты

| Пакет | Описание | pub.dev |
|-------|----------|---------|
| [atmos_binary_buffer](packages/atmos_binary_buffer) | Бинарный reader/writer, floats, UUID, LEB128, FourCC | [pub.dev](https://pub.dev/packages/atmos_binary_buffer) |
| [atmos_jsonc](packages/atmos_jsonc) | Потоковый JSONC-декодер (комментарии, trailing commas, UTF-8) | [pub.dev](https://pub.dev/packages/atmos_jsonc) |
| [atmos_lints](packages/atmos_lints) | Общие пресеты analyzer/linter (`lints` / `full` / `_2`) | [pub.dev](https://pub.dev/packages/atmos_lints) |
| [atmos_logger](packages/atmos_logger) | Композируемый логгер (console / file / filter) | [pub.dev](https://pub.dev/packages/atmos_logger) |
| [atmos_vsc_theme](packages/atmos_vsc_theme) | Парсинг цветовых тем VS Code / Cursor (JSONC, `include`) | [pub.dev](https://pub.dev/packages/atmos_vsc_theme) |
| [atmos_vsc_theme_flutter](packages/atmos_vsc_theme_flutter) | Тема → Flutter `ColorScheme` / `ThemeData` | — |
| [atmos_vsc_keybindings](packages/atmos_vsc_keybindings) | Бандл дефолтных keybindings VS Code + pure-Dart hotkey engine | [pub.dev](https://pub.dev/packages/atmos_vsc_keybindings) |
| [atmos_vsc_keybindings_flutter](packages/atmos_vsc_keybindings_flutter) | Flutter asset loader + chord-aware key host | [pub.dev](https://pub.dev/packages/atmos_vsc_keybindings_flutter) |
| [atmos_vsc_l10n](packages/atmos_vsc_l10n) | NLS / l10n в стиле VS Code (`%keys%`, `package.nls`, `t()`) | [pub.dev](https://pub.dev/packages/atmos_vsc_l10n) |
| [atmos_vsc_l10n_flutter](packages/atmos_vsc_l10n_flutter) | Загрузчики AssetBundle + `VscL10nScope` | [pub.dev](https://pub.dev/packages/atmos_vsc_l10n_flutter) |
| [atmos_vsc_commands](packages/atmos_vsc_commands) | Хаб команд (registry / execute) + contribution JSONC | [pub.dev](https://pub.dev/packages/atmos_vsc_commands) |
| [atmos_vsc_commands_flutter](packages/atmos_vsc_commands_flutter) | `VscCommandHost` — keybindings → command service | [pub.dev](https://pub.dev/packages/atmos_vsc_commands_flutter) |
| [atmos_vsc_codicon_flutter](packages/atmos_vsc_codicon_flutter) | Шрифт VS Code Codicon и полный набор кодпоинтов product icons | [pub.dev](https://pub.dev/packages/atmos_vsc_codicon_flutter) |
| [atmos_filesystem](packages/atmos_filesystem) | Портабельный filesystem API в духе VS Code (providers, memory) | [pub.dev](https://pub.dev/packages/atmos_filesystem) |
| [atmos_filesystem_web](packages/atmos_filesystem_web) | Браузерный FSA-адаптер для `atmos_filesystem` | [pub.dev](https://pub.dev/packages/atmos_filesystem_web) |
| [atmos_web_files_system_access_api](packages/atmos_web_files_system_access_api) | Биндинги File System Access API | [pub.dev](https://pub.dev/packages/atmos_web_files_system_access_api) |
| [atmos_local_fonts](packages/atmos_local_fonts) | Портабельная модель локальных шрифтов (faces, source) | [pub.dev](https://pub.dev/packages/atmos_local_fonts) |
| [atmos_local_fonts_web](packages/atmos_local_fonts_web) | Источник локальных шрифтов в браузере (Local Font Access API) | [pub.dev](https://pub.dev/packages/atmos_local_fonts_web) |
| [atmos_local_fonts_flutter](packages/atmos_local_fonts_flutter) | Регистрация локальных шрифтов во Flutter | [pub.dev](https://pub.dev/packages/atmos_local_fonts_flutter) |
| [atmos_web_local_font_access_api](packages/atmos_web_local_font_access_api) | Биндинги Local Font Access API | [pub.dev](https://pub.dev/packages/atmos_web_local_font_access_api) |
| [atmos_web_js_utils](packages/atmos_web_js_utils) | Хелперы JS interop в браузере (Promise↔Future, …) | [pub.dev](https://pub.dev/packages/atmos_web_js_utils) |
| [atmos_multithreading](packages/atmos_multithreading) | Портабельный API параллельных вычислений (jobs / local pool) | [pub.dev](https://pub.dev/packages/atmos_multithreading) |
| [atmos_multithreading_web](packages/atmos_multithreading_web) | Пул Web Worker для `atmos_multithreading` | [pub.dev](https://pub.dev/packages/atmos_multithreading_web) |
| [atmos_web_worker](packages/atmos_web_worker) | Биндинги браузерного Web Worker | [pub.dev](https://pub.dev/packages/atmos_web_worker) |
| [atmos_web_shared_buffer_api](packages/atmos_web_shared_buffer_api) | Биндинги SharedArrayBuffer + Atomics | [pub.dev](https://pub.dev/packages/atmos_web_shared_buffer_api) |

## Разработка

Целевой toolchain: **Flutter 3.16.9** (и Dart SDK, входящий в него).

```bash
dart pub get
dart run melos bootstrap

# Из каталога пакета
cd packages/<package_name>
dart pub get
# или
flutter pub get
```

Опционально: [Melos](https://pub.dev/packages/melos) управляет всеми пакетами из корня репозитория (`melos.yaml`).

## Лицензия

Если в пакете не указано иное, код распространяется по лицензии BSD 3-Clause. См. [LICENSE](LICENSE).

У отдельных пакетов может быть свой `LICENSE` (часть опубликованных пакетов — MIT).
