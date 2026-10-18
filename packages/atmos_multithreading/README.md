# atmos_multithreading

Portable **parallel compute** API for Dart by [Atom735](https://github.com/Atom735).

Jobs are named handlers that receive a serializable payload and return a result.
Backends: in-process (`LocalParallelExecutor`) or web workers via
[`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web).

## Install

```yaml
dependencies:
  atmos_multithreading: ^0.1.0
```

## Quick start

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

## Related packages

| Package | Role |
|---------|------|
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Web Worker pool backend |
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Low-level Worker bindings |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SharedArrayBuffer + Atomics |

## Example (Flutter web)

Spawn **Dart** counter workers, poll values, run parallel CPU jobs, share SAB:

```bash
cd packages/atmos_multithreading/example
flutter pub get
dart run tool/build_worker.dart   # worker/main.dart → web/counter_worker.js
flutter run -d chrome             # COI via web/coi_sw.js (reload once)
```

See [`example/README.md`](example/README.md) for COOP/COEP/CORP details.

## License

MIT — see [LICENSE](LICENSE).
