# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.1

- `readBytes` copies the blob into a Dart `Uint8List`. `FontLoader` rejects a JS view
- A face with missing metadata is skipped instead of failing the whole catalog

## 0.1.0

- Initial release: `queryLocalFonts` and `FontData` (`blob` bytes)
- Feature detection via `isLocalFontAccessApiSupported`
