# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.1

- `jsBytesFromUint8Array` смотрит на JS-буфер. `SharedArrayBuffer` не копируется

## 0.1.0

- Первый релиз на `dart:js_interop` + хелперы
- Расширения `JSObject` / `JSArray`, типы async iterator / ReadableStream
- `JSPromise.toDartAs`, `globalHasProperty`, `jsGlobalThis`
- Высокоуровневые хелперы: Promise↔Future, свойства, `jsArray`, байты
- На не-web stub бросает `UnsupportedError`
