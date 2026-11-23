import 'package:atmos_ttf/atmos_ttf.dart';
import 'package:test/test.dart';

void main() {
  test('builds a readable icon font with cmap and glyf', () {
    final font = TtfFontBuilder(familyName: 'TestIcons', unitsPerEm: 1000)
      ..addEmptyGlyph()
      ..addGlyph(
        TtfGlyph.simple(
          advanceWidth: 1000,
          leftSideBearing: 100,
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
      )
      ..addGlyph(
        TtfGlyph.simple(
          advanceWidth: 1000,
          contours: [
            TtfContour([
              const TtfPoint(200, 200),
              const TtfPoint(800, 200),
              const TtfPoint(500, 800),
            ]),
          ],
        ),
        codePoint: 0xE002,
      );

    final built = font.build();
    final bytes = built.toBytes();
    expect(isTtf(bytes), isTrue);

    final parsed = openTtf(bytes);
    expect(parsed.tableTags, containsAll(['cmap', 'glyf', 'head', 'loca']));
    expect(parsed.maxp.numGlyphs, 3);
    expect(parsed.head.unitsPerEm, 1000);
    expect(parsed.name.valueFor(1), 'TestIcons');

    final cmap = parsed.cmap;
    expect(cmap.glyphFor(0xE001), 1);
    expect(cmap.glyphFor(0xE002), 2);
    expect(cmap.glyphFor(0x20), 0);

    final g1 = parsed.glyph(1)!;
    expect(g1.isEmpty, isFalse);
    expect(g1.contours, hasLength(1));
    expect(g1.contours.first.points, hasLength(4));
    expect(g1.advanceWidth, 1000);
    expect(g1.xMin, 100);
    expect(g1.xMax, 900);

    final g2 = parsed.glyph(2)!;
    expect(g2.contours.first.points, hasLength(3));

    final notdef = parsed.glyph(0)!;
    expect(notdef.isEmpty, isTrue);
  });

  test('glyph encode/decode round-trips on-curve points', () {
    final original = TtfGlyph.simple(
      advanceWidth: 500,
      leftSideBearing: 10,
      contours: [
        TtfContour([
          const TtfPoint(0, 0),
          const TtfPoint(100, 0, onCurve: false),
          const TtfPoint(100, 100),
        ]),
      ],
    );
    final encoded = original.encodeGlyf();
    final decoded = TtfGlyph.parseGlyf(
      encoded,
      advanceWidth: 500,
      leftSideBearing: 10,
    );
    expect(decoded.contours, hasLength(1));
    expect(decoded.contours.first.points, original.contours.first.points);
    expect(decoded.xMin, original.xMin);
    expect(decoded.yMax, original.yMax);
  });

  test('refuses empty builder', () {
    expect(
      () => TtfFontBuilder(familyName: 'X').build(),
      throwsA(isA<TtfFormatException>()),
    );
  });
}
