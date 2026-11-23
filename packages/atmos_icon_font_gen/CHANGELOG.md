# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- `IconFontSpec` / `IconGlyphSpec` for named icons with contours or SVG path data
- Build a TrueType font via `atmos_ttf`
- Emit Dart source with `IconData` constants (tree-shake friendly)
- Basic SVG path parser (`M L H V C Q Z` and relative forms)
- `svgDocumentFirstPathD` via `atmos_svg`
- CLI `atmos_icon_font_gen` (directory of SVGs → TTF + Dart)
