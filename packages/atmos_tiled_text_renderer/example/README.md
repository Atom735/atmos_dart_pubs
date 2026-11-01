# Hello world

Four lines of the same Dart block, drawn from an atlas in Fira Code,
JetBrains Mono, Cascadia Mono, and Liberation Mono. Liberation Mono
matches Courier New metrics. Consolas and Courier New are not in the
repository.

Четыре строки одного и того же Dart-блока, нарисованные атласом
на Fira Code, JetBrains Mono, Cascadia Mono и Liberation Mono.
Liberation Mono повторяет метрику Courier New. Consolas и Courier New
в репозиторий не входят.

## Screenshots

<p>
  <img src="screenshots/hello_world_gallery.png" alt="Hello world gallery" width="689">
</p>

<p>
  <img src="screenshots/hello_world_fira_code.png" alt="Fira Code" width="522">
</p>

<p>
  <img src="screenshots/hello_world_jetbrains_mono.png" alt="JetBrains Mono" width="522">
</p>

<p>
  <img src="screenshots/hello_world_cascadia_mono.png" alt="Cascadia Mono" width="498">
</p>

<p>
  <img src="screenshots/hello_world_liberation_mono.png" alt="Liberation Mono" width="522">
</p>

```bash
flutter run -d chrome
flutter build web --release --base-href "/atmos_tiled_text_renderer/" --web-renderer canvaskit --no-web-resources-cdn --pwa-strategy none
```

`flutter run -d chrome` opens the example locally. `build web` writes
static files to `build/web`: CanvasKit, the repository base path for
GitHub Pages, and no service worker, so the next publish is not stuck
in cache. Publishing is the `pages` workflow at the repository root,
after Pages is set to GitHub Actions.

`flutter run -d chrome` открывает пример локально. Команда `build web`
кладёт статику в `build/web`: CanvasKit, базовый путь репозитория на
GitHub Pages и без service worker, чтобы следующая публикация не
оставалась в кэше. Публикация — workflow `pages` в корне репозитория,
после включения Pages со источником GitHub Actions.

Golden frames live in `test/goldens/`. After a layout change, recapture
them with `flutter test --update-goldens`.

Золотые кадры лежат в `test/goldens/`. После правки вёрстки их
переснимают командой `flutter test --update-goldens`.
