# atmos_web_worker_scope

English: [README.md](README.md).

Сторона **dedicated Web Worker** на Dart. [`atmos_web_worker`](../atmos_web_worker) на странице делает `new Worker()`. Этот пакет — скрипт, который выполняется внутри воркера.

Биндинг к браузеру — JS interop (`globalThis`, `addEventListener`, `postMessage`). `dart:html` и `DedicatedWorkerGlobalScope` не используются: dart2js приводит этот тип к `Window` и отклоняет промис скрипта.

## Установка

```yaml
dependencies:
  atmos_web_worker_scope: ^0.1.0
```

## Быстрый старт

Скомпилируйте `worker/main.dart` через `dart compile js` и отдайте файл в `WebWorker` на странице.

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

`WorkerScope.current` равен null, если файл выполнился как страница, поэтому случайный `<script>` не бросает исключение.

`postMessage` не конвертирует значение. Карты Dart проходят через `jsify`. Хэндлы и `SharedArrayBuffer` отправляются как уже готовые JS-объекты.

## Платформы

| Среда | Поддержка |
|-------|-----------|
| Dedicated worker (`dart compile js`) | да |
| Страница, service worker, shared worker | `current` равен null |
| VM / native | `current` равен null |

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_web_worker`](../atmos_web_worker) | `new Worker()` на странице |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | `jsify` и доступ к свойствам |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |

## Лицензия

MIT — см. [LICENSE](LICENSE).
