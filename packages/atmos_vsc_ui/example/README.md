# atmos_vsc_ui example (web)

Полноценное **Flutter web** демо workbench UI:

- Activity bar: Explorer / Search / SCM / Extensions
- Side bar с деревом файлов, поиском, fake SCM
- Редактор с вкладками, dirty / close, номер строк
- Command Palette (`Ctrl+Shift+P`) и Quick Open (`Ctrl+P`)
- Переключение bundled-тем (Dark Modern, 2026, Cursor, Light…)
- Status bar + шорткаты `Ctrl+B` (sidebar), `Ctrl+W` (close tab)

## Run

```bash
cd packages/atmos_vsc_ui/example
flutter pub get
flutter run -d chrome
```

Только web-платформа (`web/`). Windows/mobile не используются.
