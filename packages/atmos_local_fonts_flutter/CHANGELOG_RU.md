# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- Первый релиз: `loadLocalFontFiles` через `FontLoader`
- `FlutterLocalFonts` запрашивает `LocalFontSource` и регистрирует начертания
- `isLoading` на время запроса или загрузки
- `isLoaded` / `isFamilyLoaded` после того, как Flutter принял файлы
- `loadFamily` читает все установленные начертания семейства, не один файл
