# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- Разбор sfnt (TrueType / CFF OTTO): offset table и сырые байты таблиц
- Декод `head`, `hhea`, `maxp`, `hmtx`, `loca`, `cmap` (форматы 4 / 12), `name`, `post`, `OS/2`
- Декод и кодирование простых глифов `glyf` (контуры, on/off-curve точки)
- Пересборка шрифта из таблиц с выравниванием и checksum
- `TtfFontBuilder` для сборки минимального TrueType (иконки) из глифов
