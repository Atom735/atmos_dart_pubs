# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.0.1-alpha

- Load bundled OS / negative keybinding JSON via `AssetBundle`
- Map Flutter key events ↔ `VscKeyStroke`
- `VscKeybindingsHost`: chord-aware dispatch, skip printable when
  `EditableText` owns focus, ignore key repeats
