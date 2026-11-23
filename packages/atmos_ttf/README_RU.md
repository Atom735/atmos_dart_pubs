# atmos_ttf

English: [README.md](README.md).

Pure-Dart ридер и билдер TrueType / OpenType (`sfnt`). Загрузка `.ttf` / `.otf`, просмотр таблиц и глифов или сборка минимального TrueType из контуров — для пайплайнов иконочных шрифтов.

Чтение и запись через [`atmos_binary_buffer`](https://pub.dev/packages/atmos_binary_buffer).

## Установка

```yaml
dependencies:
  atmos_ttf: ^0.1.0
```

## Быстрый старт

```dart
import 'dart:typed_data';

import 'package:atmos_ttf/atmos_ttf.dart';

Uint8List buildIconFont() {
  final builder = TtfFontBuilder(familyName: 'MyIcons', unitsPerEm: 1000)
    ..addEmptyGlyph() // .notdef
    ..addGlyph(
      TtfGlyph.simple(
        advanceWidth: 1000,
        contours: [
          TtfContour([
            TtfPoint(100, 100),
            TtfPoint(900, 100),
            TtfPoint(900, 900),
            TtfPoint(100, 900),
          ]),
        ],
      ),
      codePoint: 0xE001,
    );
  return builder.build().toBytes();
}

void inspect(Uint8List bytes) {
  final font = openTtf(bytes);
  print(font.tableTags);
  print(font.cmap.mappings.length);
  final glyph = font.glyph(1);
  print(glyph?.advanceWidth);
}
```

Составные глифы при чтении сохраняются как сырые байты `glyf`; билдер пишет только простые глифы.

## Лицензия

BSD 3-Clause — см. [LICENSE](LICENSE).
