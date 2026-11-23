# atmos_multithreading

English: [README.md](README.md).

Портабельный API **параллельных вычислений** для Dart от [Atom735](https://github.com/Atom735).

Jobs — именованные обработчики с сериализуемым payload и результатом.
Бэкенды: in-process (`LocalParallelExecutor`) или web workers через
[`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web).

## Установка

```yaml
dependencies:
  atmos_multithreading: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_multithreading/atmos_multithreading.dart';

Future<void> main() async {
  final pool = LocalParallelExecutor({
    'double': (input) => (input as int) * 2,
  });
  print(await pool.run('double', 21)); // 42
  await pool.close();
}
```

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Пул Web Worker |
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Низкоуровневые биндинги Worker |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |

## Пример (Flutter web)

Спаун **Dart** counter-воркеров, опрос значений, параллельные CPU-jobs, SAB:

```bash
cd packages/atmos_multithreading/example
flutter pub get
dart run tool/build_worker.dart   # worker/main.dart → web/counter_worker.js
flutter run -d chrome             # COI через web/coi_sw.js (один reload)
```

Подробности COOP/COEP/CORP — в [`example/README.md`](example/README.md).

## Лицензия

MIT — см. [LICENSE](LICENSE).
