# Hello world

Русский: [README_RU.md](README_RU.md).

Four lines of the same Dart block, drawn from an atlas in Fira Code,
JetBrains Mono, Cascadia Mono, and Liberation Mono. Liberation Mono
matches Courier New metrics. Consolas and Courier New are not in the
repository.

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
```

`Canvas.drawAtlas` does not draw the atlas on Flutter's HTML renderer.
Build the web example with CanvasKit:

```bash
flutter build web --release --web-renderer canvaskit --no-web-resources-cdn --pwa-strategy none
```

## Fonts

Faces under `fonts/` keep their own licenses in `fonts/LICENSES/`.
They are not covered by the package BSD license.

- Fira Code — SIL Open Font License 1.1
- JetBrains Mono — Apache License 2.0
- Cascadia Mono — SIL Open Font License 1.1 (reserved font name Cascadia Code)
- Liberation Mono — SIL Open Font License 1.1
