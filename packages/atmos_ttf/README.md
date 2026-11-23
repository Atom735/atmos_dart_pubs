# atmos_ttf

Русский: [README_RU.md](README_RU.md).

Pure-Dart TrueType / OpenType (`sfnt`) reader and builder. Load a `.ttf` / `.otf`, inspect tables and glyphs, or build a minimal TrueType font from contours — aimed at icon-font pipelines.

Reads and writes go through [`atmos_binary_buffer`](https://pub.dev/packages/atmos_binary_buffer).

## Install

```yaml
dependencies:
  atmos_ttf: ^0.1.0
```

## Quick start

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

Composite glyphs are kept as raw `glyf` bytes when present; the builder emits simple glyphs only.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
