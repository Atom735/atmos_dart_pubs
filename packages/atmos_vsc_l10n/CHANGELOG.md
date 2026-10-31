# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.0.1-alpha

- `VscLocalizedString`, `VscNlsBundle`, `%key%` resolve, `VscL10n.t`
- Comment-aware bundle keys (`message/comment…`), named `{name}` args
- `tArgs` / `tNamed` / `tMessage`, locale listeners, pseudo-locale
- Diagnostics: `missingLookups`, `resolveJsonDetailed`, `missingKeys`
- Bundle `merge` / `loadAllPackageNls` (io library)
- Pure parse in main lib; files via `atmos_vsc_l10n_io.dart`
