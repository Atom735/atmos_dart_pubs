# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

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
