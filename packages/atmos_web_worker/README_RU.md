# atmos_web_worker

English: [README.md](README.md).

Dart-биндинги браузерных
**[Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)**
от [Atom735](https://github.com/Atom735).

## Установка

```yaml
dependencies:
  atmos_web_worker: ^0.1.1
```

## Быстрый старт

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

## Платформа

| Цель | Поддержка |
|------|-----------|
| Браузер | да |
| VM / native | stub / unsupported |

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Пул jobs поверх workers |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | Хелперы JS interop |
| [`atmos_web_worker_scope`](https://pub.dev/packages/atmos_web_worker_scope) | Dart-скрипт внутри worker |

## Лицензия

MIT — см. [LICENSE](LICENSE).
