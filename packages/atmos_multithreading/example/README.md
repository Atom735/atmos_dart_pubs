# atmos_multithreading example (Flutter web)

Demo of **Dart Web Workers** + **SharedArrayBuffer / Atomics**:

- **Spawn worker** — counter +1 every 50 ms (message path)
- **Create & share SAB** — workers `Atomics.add` on shared Int32 slots; main
  thread reads the same memory with `Atomics.load` (no `postMessage`)
- **Heavy job** — CPU-bound `heavySum` on one / all workers

Worker source: [`worker/main.dart`](worker/main.dart)

## Build worker (Dart → JS)

```bash
cd packages/atmos_multithreading/example
flutter pub get
dart run tool/build_worker.dart
```

## SharedArrayBuffer needs COOP / COEP / CORP

Browsers expose SAB only when the page is cross-origin isolated, typically via:

- **COOP** `Cross-Origin-Opener-Policy: same-origin`
- **COEP** `Cross-Origin-Embedder-Policy: require-corp`
- **CORP** `Cross-Origin-Resource-Policy` on subresources (`same-origin` or
  `cross-origin`) so they still load under COEP

See also
[`atmos_web_shared_buffer_api` README](../../atmos_web_shared_buffer_api/README.md).

### Local testing: JS Service Worker header hack

Flutter 3.16 `flutter run -d chrome` has no easy way to set those headers.
This example registers a **dev-only** Service Worker
[`web/coi_sw.js`](web/coi_sw.js) that proxies responses and **injects**
COOP/COEP/CORP. The page reloads once after SW activation.

```bash
cd packages/atmos_multithreading/example
dart run tool/build_worker.dart
flutter run -d chrome
```

Then `window.crossOriginIsolated === true` and **Create & share SAB** works.

> Not a production security model — for local demos only.

### Optional: real headers without the SW

```bash
flutter build web
dart run tool/serve_coi.dart
# http://localhost:8080
```

### SAB layout

| Index | Meaning |
|------:|---------|
| `0` | global atomic counter (all workers add) |
| `2+i` | per-worker atomic counter |
