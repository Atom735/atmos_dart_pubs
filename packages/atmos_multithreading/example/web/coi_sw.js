/**
 * Dev-only Service Worker: добавляет COOP/COEP (+ CORP) к ответам,
 * чтобы `window.crossOriginIsolated === true` и SharedArrayBuffer
 * работал при `flutter run -d chrome` (Flutter 3.16 без --web-header).
 *
 * Не использовать как production security-модель без ревью.
 */

const COOP = 'same-origin';
const COEP = 'require-corp';
// Без CORP ресурсы не загрузятся при COEP require-corp.
const CORP = 'cross-origin';

self.addEventListener('install', (event) => {
  // Сразу активируем новую версию SW, не дожидаясь закрытия вкладок.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Берём контроль над открытыми клиентами немедленно.
  event.waitUntil(
    (async () => {
      await self.clients.claim();
      // Первый визит без COI — просим клиентов перезагрузиться под SW.
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        client.postMessage({ type: 'coi-reloaded' });
      }
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(relayWithIsolationHeaders(event.request));
});

/**
 * Проксирует запрос и возвращает Response с нужными заголовками.
 * @param {Request} request
 * @returns {Promise<Response>}
 */
async function relayWithIsolationHeaders(request) {
  const response = await fetch(request);

  // opaque / error — заголовки не трогаем
  if (response.type === 'opaque' || response.status === 0) {
    return response;
  }

  const headers = new Headers(response.headers);
  headers.set('Cross-Origin-Opener-Policy', COOP);
  headers.set('Cross-Origin-Embedder-Policy', COEP);
  headers.set('Cross-Origin-Resource-Policy', CORP);

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
