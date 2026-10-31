# System font preview

Flutter web demo for `atmos_local_fonts_flutter`.

Русский: [README_RU.md](README_RU.md).

The left column lists font families installed on the system. The main pane
renders text in the selected family, with a custom field and canned samples:
Lorem, pangrams, the alphabet, and `Hamburgefonstiv`.

The list loads from a button: the Local Font Access API requires a user
gesture. Chrome or Edge only.

## Run

```bash
cd packages/atmos_local_fonts_flutter/example
flutter pub get
flutter run -d chrome
```
