# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.1

- `readFileRange` uses `Blob.slice`, so a large file is not loaded whole
- Depends on `atmos_filesystem` 0.1.1

## 0.1.0

- Initial release: `FsaFileSystemProvider` over a directory handle
- Scheme `fsa`, POSIX-style paths under the picked root
- Helpers to pick a directory and register it on `AtmosFileSystem`
