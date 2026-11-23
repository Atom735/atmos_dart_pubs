import 'package:atmos_ttf/atmos_ttf.dart';

/// Builds a tiny icon font and prints basic facts about it.
void main() {
  final font = TtfFontBuilder(familyName: 'ExampleIcons', unitsPerEm: 1000)
    ..addEmptyGlyph()
    ..addGlyph(
      TtfGlyph.simple(
        advanceWidth: 1000,
        contours: [
          TtfContour([
            const TtfPoint(100, 100),
            const TtfPoint(900, 100),
            const TtfPoint(900, 900),
            const TtfPoint(100, 900),
          ]),
        ],
      ),
      codePoint: 0xE001,
    );

  final bytes = font.build().toBytes();
  final parsed = openTtf(bytes);

  // ignore: avoid_print
  print('bytes: ${bytes.length}');
  // ignore: avoid_print
  print('glyphs: ${parsed.maxp.numGlyphs}');
  // ignore: avoid_print
  print('cmap 0xE001 -> ${parsed.cmap.glyphFor(0xE001)}');
  // ignore: avoid_print
  print('family: ${parsed.name.valueFor(1)}');
}
