# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.1

- `jsBytesFromUint8Array` views the JS buffer. A `SharedArrayBuffer` is not cloned

## 0.1.0

- Initial release based on `dart:js_interop` + helpers
- `JSObject` / `JSArray` index extensions, async iterator / ReadableStream types
- `JSPromise.toDartAs`, `globalHasProperty`, `jsGlobalThis`
- High-level helpers: Promise↔Future, property access, `jsArray`, typed bytes
- Non-web stub throws `UnsupportedError`
