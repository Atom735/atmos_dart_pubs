# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.3.1

- `null` и пустая строка в `colors` сбрасывают унаследованный цвет
- Файловая загрузка перенесена в `package:atmos_vsc_theme/atmos_vsc_theme_io.dart` (`VscThemeIo`): ядро больше не импортирует `dart:io`

## 0.3.0

- Типизированный доступ: `theme.colors.editor.background`
- Сырая map — `colorMap` (в конструкторе по-прежнему `colors:`)
- Генератор: `dart run tool/generate_workbench_colors.dart`
- Вложенный `include` относительно каждого файла; async URI-загрузка
- `==` / `hashCode` для theme / token / semantic

## 0.2.0

- Встроенные цветовые темы в `lib/themes/` (defaults VS Code + 2026, Cursor, Abyss, Monokai, Solarized, …)
- Хелперы путей `VscBundledThemes` / `VscBundledTheme` для файлов и Flutter assets
- Происхождение тем — `lib/themes/NOTICE.md`

## 0.1.0

- Первый релиз пакета `atmos_vsc_theme`
- Merge `include`, hex-цвета, модели theme / token / semantic
- UTF-8 загрузка (`parseColorThemeUtf8`, `loadColorThemeBytes`)
- Операции `VscColor`: `blendOver`, `mix`/`lerp`, `lighten`/`darken`, contrast
- Загрузка файлов цветовых тем VS Code / Cursor
