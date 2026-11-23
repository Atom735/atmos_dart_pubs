# atmos_web_js_utils

English: [README.md](README.md).

Небольшие хелперы **browser JS interop** для Dart от [Atom735](https://github.com/Atom735).

На `dart:js_interop` / `dart:js_util`: индексация `JSObject` / `JSArray`,
`JSPromise.toDartAs`, async iterators, типы reader для `ReadableStream`, плюс
высокоуровневые хелперы для File System Access и Worker-биндингов.

## Установка

```yaml
dependencies:
  atmos_web_js_utils: ^0.1.1
```

## Быстрый старт

```dart
import 'dart:js_interop';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

Future<void> example(JSPromise promise) async {
  final value = await promise.toDartAs<JSObject>();
  print(value['name']);
  print(globalHasProperty('showOpenFilePicker'));
}
```

## Платформа

| Цель | Поддержка |
|------|-----------|
| Браузер (JS / Wasm-web через JS interop) | да |
| VM / native | stub с `UnsupportedError` |

## Лицензия

MIT — см. [LICENSE](LICENSE).
