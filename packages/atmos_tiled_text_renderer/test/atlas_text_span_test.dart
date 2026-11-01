import 'dart:ui';

import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const red = Color(0xFFFF0000);
  const green = Color(0xFF00FF00);
  const blue = Color(0xFF0000FF);

  test('пустой спан не даёт глифов', () {
    expect(
      const AtlasTextSpan().flattenWithLigatures(defaultCodeLigatures),
      isEmpty,
    );
    expect(
      const AtlasTextSpan(text: '').flattenWithLigatures(const <String>[]),
      isEmpty,
    );
    expect(
      const AtlasTextSpan(children: <AtlasTextSpan>[])
          .flattenWithLigatures(const <String>['==']),
      isEmpty,
    );
  });

  test('склеивает ==, != и -> внутри одного спана', () {
    const span = AtlasTextSpan(text: 'a!=b->c==d');
    final glyphs = span.flattenWithLigatures(
      const <String>['==', '!=', '->'],
    );

    expect(
      glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['a', '!=', 'b', '->', 'c', '==', 'd'],
    );
    expect(glyphs[1].charCount, 2);
    expect(glyphs[3].charCount, 2);
    expect(glyphs[5].charCount, 2);
    for (final glyph in glyphs) {
      expect(glyph.sourceSpan, same(span));
      expect(glyph.style, AtlasTextStyle.empty);
    }
  });

  test('на позиции побеждает самая длинная лигатура', () {
    final glyphs = const AtlasTextSpan(text: '====')
        .flattenWithLigatures(const <String>['==', '===']);

    expect(
      glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['===', '='],
    );
    expect(glyphs.first.charCount, 3);
  });

  test('граница спана рвёт лигатуру даже при одном стиле', () {
    const style = AtlasTextStyle(color: red);
    // Two distinct instances: const would collapse them into one object.
    // Два разных экземпляра: const склеил бы их в один объект.
    // ignore: prefer_const_constructors
    final left = AtlasTextSpan(text: '=', style: style);
    // ignore: prefer_const_constructors
    final right = AtlasTextSpan(text: '=', style: style);
    final glyphs = AtlasTextSpan(
      children: <AtlasTextSpan>[left, right],
    ).flattenWithLigatures(const <String>['==']);

    expect(
      glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['=', '='],
    );
    expect(glyphs[0].sourceSpan, same(left));
    expect(glyphs[1].sourceSpan, same(right));
    expect(glyphs[0].style.color, red);
    expect(glyphs[1].style.color, red);
  });

  test('разный цвет соседних спанов тоже не склеивается', () {
    final glyphs = const AtlasTextSpan(
      children: <AtlasTextSpan>[
        AtlasTextSpan(
          text: '=',
          style: AtlasTextStyle(color: red),
        ),
        AtlasTextSpan(
          text: '=',
          style: AtlasTextStyle(color: green),
        ),
      ],
    ).flattenWithLigatures(const <String>['==']);

    expect(glyphs, hasLength(2));
    expect(glyphs[0].style.color, red);
    expect(glyphs[1].style.color, green);
  });

  test('стиль родителя наследуется и точечно перекрывается', () {
    const child = AtlasTextSpan(
      text: '!=',
      style: AtlasTextStyle(backgroundColor: green),
    );
    const overridden = AtlasTextSpan(
      text: 'x',
      style: AtlasTextStyle(color: blue),
    );
    final glyphs = const AtlasTextSpan(
      style: AtlasTextStyle(color: red),
      children: <AtlasTextSpan>[
        child,
        AtlasTextSpan(text: 'a'),
        overridden,
      ],
    ).flattenWithLigatures(const <String>['!=']);

    expect(glyphs, hasLength(3));
    expect(glyphs[0].text, '!=');
    expect(glyphs[0].charCount, 2);
    expect(glyphs[0].sourceSpan, same(child));
    expect(glyphs[0].style.color, red);
    expect(glyphs[0].style.backgroundColor, green);
    expect(glyphs[1].style.color, red);
    expect(glyphs[1].style.backgroundColor, isNull);
    expect(glyphs[2].style.color, blue);
  });

  test('вложенный спан получает стиль корня', () {
    final glyphs = const AtlasTextSpan(
      style: AtlasTextStyle(color: red),
      children: <AtlasTextSpan>[
        AtlasTextSpan(
          children: <AtlasTextSpan>[
            AtlasTextSpan(text: '->'),
          ],
        ),
      ],
    ).flattenWithLigatures(const <String>['->']);

    expect(glyphs.single.text, '->');
    expect(glyphs.single.style.color, red);
    expect(glyphs.single.charCount, 2);
  });

  test('перевод строки не входит в лигатуру', () {
    final glyphs = const AtlasTextSpan(text: 'a\nb')
        .flattenWithLigatures(const <String>['\n', 'a\n']);

    expect(
      glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['a', '\n', 'b'],
    );
    expect(glyphs[1].charCount, 1);
  });

  test('суррогатная пара — один глиф', () {
    final glyphs =
        const AtlasTextSpan(text: 'a\u{1F600}b').flattenWithLigatures(
      const <String>[],
    );

    expect(
      glyphs.map((AtlasGlyph glyph) => glyph.text),
      <String>['a', '\u{1F600}', 'b'],
    );
    expect(glyphs[1].charCount, 1);
  });

  test('длинная строка режется за один проход', () {
    final text = List<String>.filled(5000, '==').join();
    final glyphs =
        AtlasTextSpan(text: text).flattenWithLigatures(const <String>['==']);

    expect(glyphs, hasLength(5000));
    expect(glyphs.first.text, '==');
    expect(glyphs.first.charCount, 2);
    expect(glyphs.last.text, '==');
  });

  test('merge не создаёт новый стиль, если перекрывать нечего', () {
    const base = AtlasTextStyle(color: red);
    expect(identical(base.merge(null), base), isTrue);
    expect(identical(base.merge(AtlasTextStyle.empty), base), isTrue);
    expect(
      base.merge(const AtlasTextStyle(backgroundColor: green)).color,
      red,
    );
  });

  test('лист не может одновременно хранить text и children', () {
    expect(
      () => AtlasTextSpan(
        text: 'a',
        children: const <AtlasTextSpan>[AtlasTextSpan(text: 'b')],
      ),
      throwsAssertionError,
    );
  });
}
