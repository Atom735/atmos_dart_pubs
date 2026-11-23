# atmos_http_client

Русский: [README_RU.md](README_RU.md).

Typed HTTP request models and a thin `package:http` client for Dart by Atom735.

## Install

```yaml
dependencies:
  atmos_http_client: ^0.1.0
```

## Quick start

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

## License

BSD 3-Clause. See [LICENSE](LICENSE).
