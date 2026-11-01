import 'package:flutter/foundation.dart';

import 'atlas_glyph.dart';
import 'atlas_text_span.dart';

/// A flat line, already expanded from the span tree.
///
/// `AtlasTextPainter` reads only this snapshot. `flattenWithLigatures`
/// is not called per frame: the line is rebuilt when its text changes.
///
/// Плоская строка, уже развёрнутая из дерева спанов.
///
/// `AtlasTextPainter` читает только этот снимок. `flattenWithLigatures`
/// на кадр не вызывается: строка пересобирается, когда меняется её текст.
@immutable
class FlattenedLineCache {
  /// Stores already computed [glyphs] in an immutable snapshot.
  ///
  /// [charCount] is calculated here once, not in the paint loop.
  ///
  /// Кладёт уже посчитанные [glyphs] в неизменяемый снимок.
  ///
  /// [charCount] считается здесь один раз, а не в цикле отрисовки.
  FlattenedLineCache(List<AtlasGlyph> glyphs)
      : glyphs = List<AtlasGlyph>.unmodifiable(glyphs),
        charCount = _sumCharCount(glyphs),
        compositionHash = _hashGlyphs(glyphs);

  /// Flattens [span] once and stores the result.
  ///
  /// Разворачивает [span] один раз и сохраняет результат.
  factory FlattenedLineCache.fromSpan(
    AtlasTextSpan span,
    List<String> ligatures, {
    AtlasTextStyle? inheritedStyle,
  }) {
    return FlattenedLineCache(
      span.flattenWithLigatures(
        ligatures,
        inheritedStyle: inheritedStyle,
      ),
    );
  }

  /// Glyphs from left to right.
  /// Do not change the list after the cache is built.
  ///
  /// Глифы слева направо. Список нельзя менять после создания кэша.
  final List<AtlasGlyph> glyphs;

  /// Line width in monospace cells.
  ///
  /// This is the sum of [AtlasGlyph.charCount]: the `==` ligature is 2, not 1.
  ///
  /// Ширина строки в моноширинных ячейках.
  ///
  /// Это сумма [AtlasGlyph.charCount]: лигатура `==` даёт 2, а не 1.
  final int charCount;

/// Fingerprint of the line contents for `AtlasTextPainter.shouldRepaint`.
///
/// Отпечаток состава строки для `AtlasTextPainter.shouldRepaint`.
  final int compositionHash;
}

int _sumCharCount(List<AtlasGlyph> glyphs) {
  var sum = 0;
  for (final glyph in glyphs) {
    sum += glyph.charCount;
  }
  return sum;
}

int _hashGlyphs(List<AtlasGlyph> glyphs) {
  var hash = 0;
  for (final glyph in glyphs) {
    hash = Object.hash(hash, glyph.text, glyph.style, glyph.charCount);
  }
  return hash;
}
