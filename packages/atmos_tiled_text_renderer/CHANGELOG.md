# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.1

- Package now lives in the [atmos_dart_pubs](https://github.com/Atom735/atmos_dart_pubs) monorepo
- Thrown messages (`ArgumentError`, `StateError`) are English

## 0.1.0

- `AtlasTextStyle`, `AtlasTextSpan`, and `AtlasGlyph` models
- `flattenWithLigatures` tokenization: the span tree expands into a flat glyph list, and ligatures join inside a single span
- `AtlasManager` bakes an ASCII atlas and ligatures into a `ui.Image`, accounts for the device pixel ratio, and releases the previous texture
- `FlattenedLineCache` stores the flat line and the `charCount` sum
- `AtlasTextPainter` draws backgrounds and assembles glyphs with one `drawAtlas`
- `example/`: four hello-world lines in Fira Code, JetBrains Mono, Cascadia Mono, and Liberation Mono, plus gallery screenshots
- pub.dev metadata: repository, topics, platforms, and screenshots
