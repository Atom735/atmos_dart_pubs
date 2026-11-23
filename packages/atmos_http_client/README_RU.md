# atmos_http_client

English: [README.md](README.md).

Типизированные модели HTTP-запросов и хелперы клиента для Dart — by Atom735.

## Установка

```yaml
dependencies:
  atmos_http_client: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_http_client/atmos_http_client.dart';

Future<void> ping(AtmosHttpClient client) async {
  await client.send('GET', Uri.parse('https://example.com/'));
}
```

Sealed-иерархия запросов: `AtmosHttpRequestBase` (части JSON / multipart в `src/request/`).

## Лицензия

BSD 3-Clause. См. [LICENSE](LICENSE).
