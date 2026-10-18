# atmos_web_shared_buffer_api

Dart bindings for browser
**[SharedArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer)**
and
**[Atomics](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics)**
by [Atom735](https://github.com/Atom735).

## Install

```yaml
dependencies:
  atmos_web_shared_buffer_api: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_web_shared_buffer_api/atmos_web_shared_buffer_api.dart';

void main() {
  if (!isSharedMemorySupported || !isCrossOriginIsolated) return;
  final view = SharedInt32Array(4);
  view.store(0, 0);
  view.add(0, 1);
  print(view.load(0)); // 1
}
```

## Cross-origin isolation (required)

In modern browsers `SharedArrayBuffer` is available only when the page is
**[cross-origin isolated](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer#security_requirements)**
(`window.crossOriginIsolated === true`). That normally means the **document**
(and often related responses) are served with:

| Header | Typical value | Role |
|--------|---------------|------|
| **COOP** `Cross-Origin-Opener-Policy` | `same-origin` | Isolates the browsing context |
| **COEP** `Cross-Origin-Embedder-Policy` | `require-corp` | Requires CORP (or CORS) on subresources |
| **CORP** `Cross-Origin-Resource-Policy` | `same-origin` or `cross-origin` | Lets resources load under COEP |

Prefer checking [`isCrossOriginIsolated`](lib/src/support.dart) before allocating.

### Production

Set COOP / COEP / CORP on your real HTTP server / CDN.

### Local testing: JS Service Worker header hack

Flutter **3.16** `flutter run -d chrome` cannot easily inject response headers
(no `--web-header`). For **dev-only** local runs you can register a small
Service Worker that rewrites responses and adds COOP/COEP/CORP so
`crossOriginIsolated` becomes `true` after one reload.

Working copy used by the multithreading demo:

- [`../atmos_multithreading/example/web/coi_sw.js`](../atmos_multithreading/example/web/coi_sw.js)
- registration in [`../atmos_multithreading/example/web/index.html`](../atmos_multithreading/example/web/index.html)

Sketch (same idea):

```js
// coi_sw.js — DEV ONLY, not a production security model
const COOP = 'same-origin';
const COEP = 'require-corp';
const CORP = 'cross-origin'; // needed so subresources still load under COEP

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));

self.addEventListener('fetch', (event) => {
  event.respondWith((async () => {
    const response = await fetch(event.request);
    if (response.type === 'opaque' || response.status === 0) return response;
    const headers = new Headers(response.headers);
    headers.set('Cross-Origin-Opener-Policy', COOP);
    headers.set('Cross-Origin-Embedder-Policy', COEP);
    headers.set('Cross-Origin-Resource-Policy', CORP);
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers,
    });
  })());
});
```

Register early in `index.html`, and **do not** also register Flutter’s caching
SW on the same scope. Expect one automatic reload after the first install.

Alternative without a SW: serve `build/web` with real headers
(`dart run tool/serve_coi.dart` in the multithreading example).

## Related

| Package | Role |
|---------|------|
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Web Worker bindings |
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Worker pool + SAB share helpers |

## License

MIT — see [LICENSE](LICENSE).
