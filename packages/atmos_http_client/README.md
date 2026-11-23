# atmos_http_client

Русский: [README_RU.md](README_RU.md).

Typed HTTP request models and client helpers for Dart by Atom735.

## Install

```yaml
dependencies:
  atmos_http_client: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_http_client/atmos_http_client.dart';

Future<void> ping(AtmosHttpClient client) async {
  await client.send('GET', Uri.parse('https://example.com/'));
}
```

Sealed request hierarchy: `AtmosHttpRequestBase` (JSON / multipart parts under `src/request/`).

## License

BSD 3-Clause. See [LICENSE](LICENSE).
