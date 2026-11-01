import 'dart:ui';

import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('charCount складывает ширину лигатур', () {
    final line = FlattenedLineCache.fromSpan(
      const AtlasTextSpan(text: 'a==b'),
      const <String>['=='],
    );

    expect(
      line.glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['a', '==', 'b'],
    );
    expect(line.charCount, 4);
  });

  test('пустая строка имеет нулевую ширину', () {
    final line = FlattenedLineCache(const <AtlasGlyph>[]);

    expect(line.glyphs, isEmpty);
    expect(line.charCount, 0);
    expect(line.compositionHash, 0);
  });

  test('fromSpan переносит унаследованный цвет в глиф', () {
    const red = Color(0xFFFF0000);
    final line = FlattenedLineCache.fromSpan(
      const AtlasTextSpan(text: '!='),
      const <String>['!='],
      inheritedStyle: const AtlasTextStyle(color: red),
    );

    expect(line.glyphs.single.charCount, 2);
    expect(line.glyphs.single.style.color, red);
  });
}
