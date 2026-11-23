# atmos_icon_font_gen

Русский: [README_RU.md](README_RU.md).

Generate a TrueType icon font and Dart `IconData` source from glyph contours or SVG path data. Uses [`atmos_ttf`](https://pub.dev/packages/atmos_ttf) for font assembly.

## Install

```yaml
dev_dependencies:
  atmos_icon_font_gen: ^0.1.0
```

## Quick start

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

SVG Y is flipped into font space (viewBox height = `unitsPerEm` by default). Pass ready `TtfContour` lists via `contours` when you already have font-unit outlines.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
