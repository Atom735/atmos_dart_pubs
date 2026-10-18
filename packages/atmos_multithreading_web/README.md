# atmos_multithreading_web

**Web Worker** pool backend for
[`atmos_multithreading`](https://pub.dev/packages/atmos_multithreading) by
[Atom735](https://github.com/Atom735).

## Install

```yaml
dependencies:
  atmos_multithreading_web: ^0.1.0
```

## Host

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

## Worker script

Workers must answer `ParallelMessage` request envelopes with matching `id`.
See `ParallelMessage` in `atmos_multithreading` for field names.

## SharedArrayBuffer

`shareCounterBuffer` / `broadcastSharedBuffer` post the **raw**
`SharedArrayBuffer` (never run it through `jsify` — that breaks the buffer).
The page must be **cross-origin isolated** (COOP + COEP, and CORP on
subresources). Details and a **dev-only** JS Service Worker header hack for
`flutter run`: see
[`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api)
README.

## Related

| Package | Role |
|---------|------|
| [`atmos_multithreading`](https://pub.dev/packages/atmos_multithreading) | Core parallel API |
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Worker bindings |
| [`atmos_web_shared_buffer_api`](https://pub.dev/packages/atmos_web_shared_buffer_api) | SAB + Atomics |

## License

MIT — see [LICENSE](LICENSE).
