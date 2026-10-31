# atmos_vsc_theme

English: [README.md](README.md).

Разбор JSON цветовых тем **VS Code / Cursor** в модели Dart, [Atom735](https://github.com/Atom735).

- JSONC через [`atmos_jsonc`](https://pub.dev/packages/atmos_jsonc) (`//` / `/* */`, завершающие запятые)
- Рекурсивный merge `include` (перекрытие `colors`, `null` / `""` сбрасывает ключ, `tokenColors` дописываются)
- Hex-цвета: `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`
- Хелперы цвета: `blendOver`, `mix` / `lerp`, `lighten` / `darken`, contrast
- Стили семантических токенов (`foreground` / `fontStyle`)
- Загрузка UTF-8 байт без целой строки документа

Для Flutter `ThemeData` / `ColorScheme` см. [`atmos_vsc_theme_flutter`](../atmos_vsc_theme_flutter).

## Установка

```yaml
dependencies:
  atmos_vsc_theme: ^0.3.1
```

## Быстрый старт

```dart
import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart';

void main() {
  final theme = VscThemeIo.loadColorThemePath(
    VscBundledThemes.darkModern.packageLibPath,
  );

  print(theme.name); // Default Dark Modern
  print(theme.colors.editor.background?.toHex()); // #1f1f1f
  print(theme['sideBar.foreground']?.toHex()); // сырой ключ тоже работает
  print(theme.tokenColors.length);
  print(theme.semanticTokenColors['newOperator']?.foreground?.toHex());

  // Свести полупрозрачный цвет workbench на фон редактора
  final selection = theme['editor.selectionBackground'];
  final bg = theme.editorBackground;
  if (selection != null && bg != null) {
    print(selection.blendOver(bg).toHex());
  }
}
```

На web и везде без `dart:io` импортируйте `package:atmos_vsc_theme/atmos_vsc_theme.dart` и вызывайте `VscThemeLoader.parseColorTheme`.

### Ассеты Flutter

Удобнее [`atmos_vsc_theme_flutter`](../atmos_vsc_theme_flutter)
`VscThemeAssetLoader` (учитывает вложенный `include`):

```dart
final theme = await VscThemeAssetLoader.load(VscBundledThemes.darkModern);
// theme.colors.editor.background
```

Ассеты объявлены в `atmos_vsc_theme_flutter`. Приложение, которое зависит только от
`atmos_vsc_theme`, само перечисляет `packages/atmos_vsc_theme/themes/...`.

### Байты UTF-8

```dart
import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart';

final theme = VscThemeIo.loadColorThemeBytes(
  file.readAsBytesSync(),
  includeBase: file.parent,
);
```

### Из строки (свой резолвер `include`)

```dart
final theme = VscThemeLoader.parseColorTheme(
  source,
  resolveInclude: (relative) => File('themes/$relative').readAsStringSync(),
);
```

## Область

Поддерживаемые поля JSON цветовой темы: `name`, `type`, `include`, `colors`,
`tokenColors` (массив в том же файле), `semanticHighlighting`, `semanticTokenColors`.

Значения `colors` равные `null` или `""` убирают этот ключ у родителя из `include`.
Любое другое не-hex значение игнорируется, цвет родителя остаётся.

Не поддерживается: `tokenColors` как путь к TextMate-файлу `.tmTheme`.
Файловые хелперы (`VscThemeIo`) лежат в `atmos_vsc_theme_io.dart` (`dart:io`).

### Типизированные цвета

Ключи workbench из встроенных тем сгенерированы во вложенные геттеры:

```dart
theme.colors.editor.background;
theme.colors.activityBar.foreground;
theme.colors.focusBorder;
```

После добавления ключей в JSON тем:

```bash
dart run tool/generate_workbench_colors.dart
```

## Встроенные темы

В `lib/themes/` лежат цветовые темы, скопированные из встроенных тем VS Code / Cursor
(см. [lib/themes/NOTICE.md](lib/themes/NOTICE.md)). Каталог:
[`VscBundledThemes`](lib/src/bundled_themes.dart).

| Папка | Источник |
|-------|----------|
| `defaults/` | VS Code `theme-defaults` (+ `2026-*.json` из upstream) |
| `cursor/` | Cursor `theme-cursor` |
| `abyss/`, `monokai/`, `solarized-*`, … | Соответствующие расширения тем VS Code / Cursor |

## Лицензия

Код пакета — MIT. См. [LICENSE](LICENSE). JSON встроенных тем:
[lib/themes/NOTICE.md](lib/themes/NOTICE.md).
