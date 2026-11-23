# atmos_cross_file

English: [README.md](README.md).

Расширенный API файлов (chunked read, источники FS / RAM) поверх \`cross_file\` — by Atom735.

## Установка

```yaml
dependencies:
  atmos_cross_file: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_cross_file/atmos_cross_file.dart';

Future<void> readHead(AtmosXFile file) async {
  final chunk = await file.readChunk(0, 16);
}
```

## Лицензия

BSD 3-Clause. См. [LICENSE](LICENSE).
