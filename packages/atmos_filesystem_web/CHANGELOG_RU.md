# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.1

- `readFileRange` идёт через `Blob.slice`, большой файл не читается целиком
- Зависимость от `atmos_filesystem` 0.1.1

## 0.1.0

- Первый релиз: `FsaFileSystemProvider` поверх directory handle
- Схема `fsa`, POSIX-пути относительно выбранного корня

- Хелперы выбора папки и регистрации в `AtmosFileSystem`
