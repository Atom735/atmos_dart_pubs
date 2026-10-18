# atmos_web_js_utils

Small **browser JS interop** helpers for Dart by [Atom735](https://github.com/Atom735).

Built on `dart:js_interop` / `dart:js_util`: `JSObject` / `JSArray` indexing,
`JSPromise.toDartAs`, async iterators, `ReadableStream` reader types, plus
high-level helpers used by File System Access and Worker bindings.

## Install

```yaml
dependencies:
  atmos_web_js_utils: ^0.1.0
```

## Quick start

```dart
import 'dart:js_interop';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

Future<void> example(JSPromise promise) async {
  final value = await promise.toDartAs<JSObject>();
  print(value['name']);
  print(globalHasProperty('showOpenFilePicker'));
}
```

## Platform

| Target | Support |
|--------|---------|
| Browser (JS / Wasm-web via JS interop) | yes |
| VM / native | stub that throws `UnsupportedError` |

## License

MIT — see [LICENSE](LICENSE).
