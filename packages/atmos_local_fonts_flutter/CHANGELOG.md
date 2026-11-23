# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Initial release: `loadLocalFontFiles` via `FontLoader`
- `FlutterLocalFonts` queries a `LocalFontSource` and registers faces
- `isLoading` while a query or load is in progress
- `isLoaded` / `isFamilyLoaded` after Flutter accepts the files
- `loadFamily` reads every installed face of the family, not one file
