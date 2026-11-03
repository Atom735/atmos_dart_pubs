# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.3.0-alpha

- Workbench, боковая панель, панель и статус-бар сохраняют текущий шрифт и меняют только цвет и размер
- Product icons через `VscCodicon` из `atmos_vsc_codicon_flutter`
- Удалены геометрические `VscIcons`
- Command palette рисует иконки `$(codicon)` из вкладов команд
- Виджеты хрома: меню, хлебные крошки, панель, кнопка, checkbox, поле, dropdown, badge, progress, дерево, строка списка, секция, split, toolbar, баннер, уведомление
- Пример показывает галерею всех компонентов

## 0.2.0

- **Breaking:** без Material / Cupertino — только `package:flutter/widgets.dart`
- `VscUiTheme` — обычные токены + `VscUiThemeScope` (без `ThemeExtension` / lerp)
- Удалён `toWorkbenchThemeData()`
- Добавлен `VscPressable`
- Web-пример на `WidgetsApp`

## 0.1.1

- `VscUiTheme.fromColorTheme` на типизированных `theme.colors.*`
- `VscUiTheme.of` с fallback на `VscThemeScope`
- Полноценный **web**-пример: темы, вкладки, palette, шорткаты, side bar

## 0.1.0

- Первый релиз: оболочка workbench, activity / side / status bars, вкладки
- Command palette на базе `atmos_vsc_commands`
- Токены темы из `VscColorTheme` / `VscUiTheme`
