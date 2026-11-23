# atmos_icon_font_gen

English: [README.md](README.md).

Генерация TrueType-шрифта иконок и Dart-исходника с `IconData` из контуров глифов или SVG path. Сборка шрифта через [`atmos_ttf`](https://pub.dev/packages/atmos_ttf).

## Установка

```yaml
dev_dependencies:
  atmos_icon_font_gen: ^0.1.0
```

## Быстрый старт

```dart
import 'dart:io';

import 'package:atmos_icon_font_gen/atmos_icon_font_gen.dart';

void main() {
  final result = generateIconFont(
    IconFontSpec(
      fontFamily: 'MyIcons',
      className: 'MyIcons',
      fontPackage: 'my_icons',
      unitsPerEm: 1000,
      icons: [
        IconGlyphSpec(
          name: 'square',
          codePoint: 0xE001,
          svgPath: 'M100 100H900V900H100Z',
        ),
        IconGlyphSpec(
          name: 'check',
          codePoint: 0xE002,
          svgPath: 'M200 500L400 700L800 300',
        ),
      ],
    ),
  );

  File('assets/my_icons.ttf').writeAsBytesSync(result.ttfBytes);
  File('lib/src/my_icons.g.dart').writeAsStringSync(result.dartSource);
}
```

Ось Y SVG переворачивается в пространство шрифта (высота viewBox по умолчанию = `unitsPerEm`). Готовые контуры в единицах шрифта можно передать через `contours` (`TtfContour`). Целые SVG-файлы: `svgDocumentFirstPathD` (через `atmos_svg`) берёт первый `<path d>`.

### CLI

```bash
dart run atmos_icon_font_gen --input icons/ \
  --out-ttf assets/my_icons.ttf --out-dart lib/src/my_icons.g.dart \
  --family MyIcons --class MyIcons
```

## Лицензия

BSD 3-Clause — см. [LICENSE](LICENSE).
