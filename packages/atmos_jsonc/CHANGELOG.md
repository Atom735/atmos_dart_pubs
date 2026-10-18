# Changelog

## 0.1.0

### EN

- Initial release: single-pass `jsoncDecode` / `JsoncDecoder` / `jsonc` codec
- JSONC: `//` and `/* */` comments, trailing commas
- `stripJsonc` helper (higher memory; prefer direct decode)
- Path-aware `reviver` (`JsoncPath` stack) on the direct tree path
- SAX `jsoncVisit` / `JsoncVisitor` (no intermediate `Map`)
- Pull API: `JsoncReader`, `JsoncBinder`, `jsoncBind`
- Hot-path opts: manual int parse, local `skipNoise`, reusable path stack
- `jsoncDecodeUtf8` / `JsoncUtf8Decoder` / `jsoncUtf8` (UTF-8 bytes, no full `String`)
- Benchmarks vs `dart:convert` `JsonDecoder` (time + RSS), plus reviver/bind/utf8
- Runnable examples in `example/example.dart`

### RU

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
