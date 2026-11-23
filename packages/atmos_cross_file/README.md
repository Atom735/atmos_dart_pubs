# atmos_cross_file

Русский: [README_RU.md](README_RU.md).

Extended file API (chunked read, FS / RAM sources) on top of \`cross_file\` — by Atom735.

## Install

```yaml
dependencies:
  atmos_cross_file: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_cross_file/atmos_cross_file.dart';

Future<void> readHead(AtmosXFile file) async {
  final chunk = await file.readChunk(0, 16);
}
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
