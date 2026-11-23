# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- Первый релиз: однопроходный `jsoncDecode` / `JsoncDecoder` / кодек `jsonc`
- JSONC: комментарии `//` и `/* */`, trailing commas
- Хелпер `stripJsonc` (больше памяти; лучше прямой decode)
- Path-`reviver` со стеком `JsoncPath` на прямом tree-пути
- SAX `jsoncVisit` / `JsoncVisitor` (без промежуточного `Map`)
- Pull API: `JsoncReader`, `JsoncBinder`, `jsoncBind`
- Оптимизации hot-path: ручной int parse, локальный `skipNoise`, reuse path
- `jsoncDecodeUtf8` / `JsoncUtf8Decoder` / `jsoncUtf8` (UTF-8 байты, без полной `String`)
- Бенчмарки против `JsonDecoder` (время + RSS), плюс reviver/bind/utf8
- Примеры в `example/example.dart`
