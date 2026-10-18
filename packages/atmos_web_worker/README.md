# atmos_web_worker

Dart bindings for browser
**[Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)**
by [Atom735](https://github.com/Atom735).

## Install

```yaml
dependencies:
  atmos_web_worker: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_web_worker/atmos_web_worker.dart';

void main() {
  if (!isWebWorkerSupported) return;
  final worker = WebWorker('worker.js');
  worker.messages.listen((event) {
    print(event.data);
  });
  worker.postMessage({'cmd': 'ping'});
}
```

## Platform

| Target | Support |
|--------|---------|
| Browser | yes |
| VM / native | stub / unsupported |

## Related

| Package | Role |
|---------|------|
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Job pool over workers |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | JS interop helpers |

## License

MIT — see [LICENSE](LICENSE).
