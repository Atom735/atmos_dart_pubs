# Changelog

## 0.1.1

### EN

- `readFileRange` uses `Blob.slice`, so a large file is not loaded whole
- Depends on `atmos_filesystem` 0.1.1

### RU

- `readFileRange` идёт через `Blob.slice`, большой файл не читается целиком
- Зависимость от `atmos_filesystem` 0.1.1

## 0.1.0

### EN

- Initial release: `FsaFileSystemProvider` over a directory handle
- Scheme `fsa`, POSIX-style paths under the picked root
- Helpers to pick a directory and register it on `AtmosFileSystem`

### RU

- Первый релиз: `FsaFileSystemProvider` поверх directory handle
- Scheme `fsa`, POSIX-пути относительно выбранного корня
- Хелперы выбора папки и регистрации в `AtmosFileSystem`
