# atmos_local_fonts

Переносимая модель **локальных шрифтов** для Dart от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

Начертание и источник, который умеет перечислить начертания. Без типов
браузера и Flutter: платформенные пакеты реализуют `LocalFontSource`.

## Установка

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
```

## Быстрый старт

```dart
import 'dart:typed_data';

import 'package:atmos_local_fonts/atmos_local_fonts.dart';

Future<Uint8List> bytes() async => Uint8List(0);

final source = MemoryLocalFontSource(<LocalFontFace>[
  LocalFontFace(
    family: 'Arial',
    fullName: 'Arial',
    postscriptName: 'ArialMT',
    style: 'Regular',
    readBytes: bytes,
  ),
]);

Future<void> main() async {
  final faces = await source.query();
  print(faces.single.family);
}
```

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [atmos_local_fonts_web](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_web) | Браузерный источник (Local Font Access API) |
| [atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter) | Регистрация байтов шрифта во Flutter |
| [atmos_web_local_font_access_api](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_web_local_font_access_api) | Низкоуровневые браузерные привязки |

## Лицензия

MIT — см. [LICENSE](LICENSE).
