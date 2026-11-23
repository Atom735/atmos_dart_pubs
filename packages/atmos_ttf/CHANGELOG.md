# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Parse sfnt (TrueType / CFF-flavoured OTTO) offset tables and raw table bytes
- Decode `head`, `hhea`, `maxp`, `hmtx`, `loca`, `cmap` (formats 4 / 12), `name`, `post`, `OS/2`
- Decode and encode simple `glyf` glyphs (contours, on/off-curve points)
- Rebuild a font from tables with correct padding and checksums
- `TtfFontBuilder` to assemble a minimal icon-style TrueType font from glyphs
