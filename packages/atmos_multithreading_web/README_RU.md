# atmos_multithreading_web

English: [README.md](README.md).

Бэкенд пула **Web Worker** для
[`atmos_multithreading`](https://pub.dev/packages/atmos_multithreading) от
[Atom735](https://github.com/Atom735).

## Установка

```yaml
dependencies:
  atmos_multithreading_web: ^0.1.0
```

## Хост

```dart
import 'package:atmos_multithreading_web/atmos_multithreading_web.dart';

Future<void> main() async {
  final pool = WebWorkerParallelExecutor(
    scriptUrl: 'worker.js',
    size: 2,
  );
  final result = await pool.run('double', 21);
  await pool.close();
}
```

## Скрипт воркера

Воркеры должны отвечать на envelope-запросы `ParallelMessage` с тем же `id`.
Имена полей — в `ParallelMessage` пакета `atmos_multithreading`.

## SharedArrayBuffer

`shareCounterBuffer` / `broadcastSharedBuffer` передают **сырой**
`SharedArrayBuffer` (не прогоняйте через `jsify` — буфер сломается).
Страница должна быть **cross-origin isolated** (COOP + COEP и CORP на
подресурсах). Подробности и **dev-only** JS Service Worker для заголовков при
`flutter run`: см. README
[`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api).

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_multithreading`](https://pub.dev/packages/atmos_multithreading) | Ядро parallel API |
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Биндинги Worker |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SAB + Atomics |

## Лицензия

MIT — см. [LICENSE](LICENSE).
