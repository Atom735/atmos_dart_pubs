# Changelog

## 0.1.1

### EN

- `readBytes` copies the blob into a Dart `Uint8List`. `FontLoader` rejects a JS view
- A face with missing metadata is skipped instead of failing the whole catalog

### RU

- `readBytes` копирует blob в обычный `Uint8List`: `FontLoader` не принимает JS-view
- Начертание без метаданных пропускается и не роняет весь список

## 0.1.0

### EN

- Initial release: `queryLocalFonts` and `FontData` (`blob` bytes)
- Feature detection via `isLocalFontAccessApiSupported`

### RU

- Первый релиз: `queryLocalFonts` и `FontData` (байты через `blob`)
- Детект API: `isLocalFontAccessApiSupported`
