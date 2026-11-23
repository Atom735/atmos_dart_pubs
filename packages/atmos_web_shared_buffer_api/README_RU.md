# atmos_web_shared_buffer_api

English: [README.md](README.md).

Dart-биндинги браузерных
**[SharedArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer)**
и
**[Atomics](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics)**
от [Atom735](https://github.com/Atom735).

## Установка

```yaml
dependencies:
  atmos_web_shared_buffer_api: ^0.1.1
```

## Быстрый старт

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

## Cross-origin isolation (обязательно)

В современных браузерах `SharedArrayBuffer` доступен только если страница
**[cross-origin isolated](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer#security_requirements)**
(`window.crossOriginIsolated === true`). Обычно это значит, что **документ**
(и часто связанные ответы) отдаются с заголовками:

| Заголовок | Типичное значение | Роль |
|-----------|-------------------|------|
| **COOP** `Cross-Origin-Opener-Policy` | `same-origin` | Изолирует browsing context |
| **COEP** `Cross-Origin-Embedder-Policy` | `require-corp` | Требует CORP (или CORS) у подресурсов |
| **CORP** `Cross-Origin-Resource-Policy` | `same-origin` или `cross-origin` | Позволяет грузить ресурсы при COEP |

Перед аллокацией лучше проверять [`isCrossOriginIsolated`](lib/src/support.dart).

### Production

Ставьте COOP / COEP / CORP на реальном HTTP-сервере / CDN.

### Локальные тесты: JS Service Worker с подменой заголовков

Flutter **3.16** `flutter run -d chrome` почти не умеет подставлять response
headers (нет `--web-header`). Для **dev-only** локальных прогонов можно
зарегистрировать маленький Service Worker, который переписывает ответы и
добавляет COOP/COEP/CORP, чтобы после одного reload `crossOriginIsolated`
стал `true`.

Рабочая копия из демо multithreading:

- [`../atmos_multithreading/example/web/coi_sw.js`](../atmos_multithreading/example/web/coi_sw.js)
- регистрация в [`../atmos_multithreading/example/web/index.html`](../atmos_multithreading/example/web/index.html)

Эскиз (та же идея):

```js
// coi_sw.js — DEV ONLY, не модель безопасности для production
const COOP = 'same-origin';
const COEP = 'require-corp';
const CORP = 'cross-origin'; // нужно, чтобы подресурсы грузились при COEP

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

Регистрируйте рано в `index.html` и **не** регистрируйте кэширующий SW Flutter
на том же scope. После первой установки ожидайте один автоматический reload.

Альтернатива без SW: отдавать `build/web` с настоящими заголовками
(`dart run tool/serve_coi.dart` в примере multithreading).

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_web_worker`](https://pub.dev/packages/atmos_web_worker) | Биндинги Web Worker |
| [`atmos_multithreading_web`](https://pub.dev/packages/atmos_multithreading_web) | Пул воркеров + хелперы шаринга SAB |

## Лицензия

MIT — см. [LICENSE](LICENSE).
