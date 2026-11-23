# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- `IconFontSpec` / `IconGlyphSpec` — именованные иконки с контурами или SVG path
- Сборка TrueType через `atmos_ttf`
- Генерация Dart-исходника с константами `IconData` (удобно для tree-shaking)
- Базовый парсер SVG path (`M L H V C Q Z` и относительные формы)
- `svgDocumentFirstPathD` через `atmos_svg`
- CLI `atmos_icon_font_gen` (каталог SVG → TTF + Dart)
