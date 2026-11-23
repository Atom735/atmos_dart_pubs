# atmos_http_client

English: [README.md](README.md).

Типизированные модели HTTP-запросов и тонкий клиент на `package:http` для Dart — by Atom735.

## Установка

```yaml
dependencies:
  atmos_http_client: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_http_client/atmos_http_client.dart';

Future<void> main() async {
  final client = AtmosHttpClientHttp();
  final response = await client.send(
    AtmosHttpRequestJson(
      'POST',
      Uri.parse('https://httpbin.org/post'),
      body: {'ok': true},
    ),
  );
  // ignore: avoid_print
  print(response.statusCode);
  client.close();
}
```

## Лицензия

BSD 3-Clause. См. [LICENSE](LICENSE).
