# История изменений

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.1

- Пакет перенесён в монорепозиторий [atmos_dart_pubs](https://github.com/Atom735/atmos_dart_pubs)
- Тексты `ArgumentError` и `StateError` на английском

## 0.1.0

- Модели `AtlasTextStyle`, `AtlasTextSpan` и `AtlasGlyph`
- Токенизация `flattenWithLigatures`: дерево спанов разворачивается в плоский список глифов, лигатуры склеиваются внутри одного спана
- `AtlasManager` запекает ASCII-атлас и лигатуры в `ui.Image` с учётом device pixel ratio и освобождает предыдущую текстуру
- `FlattenedLineCache` хранит плоскую строку и сумму `charCount`
- `AtlasTextPainter` рисует подложки и собирает глифы одним `drawAtlas`
- Пример `example/`: четыре строки hello world на Fira Code, JetBrains Mono, Cascadia Mono и Liberation Mono, плюс скриншоты галереи
- Метаданные для pub.dev: репозиторий, темы, платформы и скриншоты
