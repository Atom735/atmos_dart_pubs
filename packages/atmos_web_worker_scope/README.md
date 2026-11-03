# atmos_web_worker_scope

Русский: [README_RU.md](README_RU.md).

Dart side of a **dedicated Web Worker**. [`atmos_web_worker`](../atmos_web_worker) starts `new Worker()` on the page. This package is the script that runs inside that worker.

The browser binding is JS interop (`globalThis`, `addEventListener`, `postMessage`). It does not use `dart:html` or `DedicatedWorkerGlobalScope`: dart2js casts that type to `Window` and rejects the worker script.

## Install

```yaml
dependencies:
  atmos_web_worker_scope: ^0.1.0
```

## Quick start

Compile `worker/main.dart` with `dart compile js` and pass the output to `WebWorker` on the page.

```dart
import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';
import 'package:atmos_web_worker_scope/atmos_web_worker_scope.dart';

void main() {
  final scope = WorkerScope.current;
  if (scope == null) return;
  scope.messages.listen((event) {
    scope.postMessage(jsify(<String, Object?>{
      'type': 'pong',
      'echo': event.data,
    }));
  });
}
```

`WorkerScope.current` is null when the file is evaluated as a page, so a mistaken `<script>` does not throw.

`postMessage` does not convert the value. Dart maps go through `jsify`. Handles and `SharedArrayBuffer` are posted as the JS objects you already hold.

## Platform

| Target | Support |
|--------|---------|
| Dedicated worker (`dart compile js`) | yes |
| Page, service worker, shared worker | `current` is null |
| VM / native | `current` is null |

## Related

| Package | Role |
|---------|------|
| [`atmos_web_worker`](../atmos_web_worker) | `new Worker()` on the page |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | `jsify` and property access |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |

## License

MIT — see [LICENSE](LICENSE).
