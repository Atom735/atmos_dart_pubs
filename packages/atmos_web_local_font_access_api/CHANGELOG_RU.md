# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.1

- `readBytes` копирует blob в обычный `Uint8List`: `FontLoader` не принимает JS-view
- Начертание без метаданных пропускается и не роняет весь список

## 0.1.0

- Первый релиз: `queryLocalFonts` и `FontData` (байты через `blob`)
- Детект API: `isLocalFontAccessApiSupported`
