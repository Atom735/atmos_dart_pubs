import 'package:flutter/foundation.dart';

import 'atlas_glyph.dart';

/// Ligatures worth baking for code: comparisons, arrows,
/// and logical operators. The same list is passed to
/// [AtlasTextSpan.flattenWithLigatures] and `AtlasManager.updateDpr`.
///
/// Лигатуры, которые имеет смысл запечь для кода: сравнения, стрелки,
/// логические операторы. Тот же список передаётся в
/// [AtlasTextSpan.flattenWithLigatures] и в `AtlasManager.updateDpr`.
const List<String> defaultCodeLigatures = <String>[
  '->',
  '=>',
  '<-',
  '!=',
  '==',
  '<=',
  '>=',
  '&&',
  '||',
  '++',
  '--',
  '+=',
  '-=',
  '*=',
  '/=',
  '??',
  '?.',
  '::',
  '/*',
  '*/',
];

/// A text hierarchy modeled on `TextSpan`, without widgets.
///
/// A node stores either its own [text] or [children]. Style flows
/// top-down: a child overrides only the fields it sets.
/// [flattenWithLigatures] walks the tree once and joins ligatures
/// only inside a single text node — a span boundary breaks a ligature,
/// even when the style matches on both sides.
///
/// Иерархия текста по образцу `TextSpan`, но без виджетов.
///
/// Узел хранит либо собственный [text], либо [children]. Стиль течёт
/// сверху вниз: ребёнок переопределяет только заданные поля.
/// [flattenWithLigatures] обходит дерево один раз и склеивает лигатуры
/// только внутри одного текстового узла — граница спана лигатуру рвёт,
/// даже если стиль по обе стороны совпадает.
@immutable
class AtlasTextSpan {
  /// Creates a span. In debug mode [text] and [children] cannot both
  /// be set: the same contract as `TextSpan`.
  ///
  /// Создаёт спан. В отладочном режиме нельзя задать [text] и [children]
  /// одновременно: это та же договорённость, что у `TextSpan`.
  const AtlasTextSpan({
    this.text,
    this.style,
    this.children,
  }) : assert(
          text == null || children == null,
          'AtlasTextSpan cannot have both text and children.',
        );

  /// Leaf text. Ignored on a node that has [children].
  ///
  /// Текст листа. У узла с [children] игнорируется.
  final String? text;

  /// Local style overrides. `null` inherits everything.
  ///
  /// Локальные переопределения стиля. `null` — целиком наследовать.
  final AtlasTextStyle? style;

  /// Nested spans. The list must not change after creation:
  /// the instance is meant to be `const`.
  ///
  /// Вложенные спаны. Список после создания менять нельзя:
  /// экземпляр рассчитан на `const`.
  final List<AtlasTextSpan>? children;

  /// Flattens the tree into a flat run of [AtlasGlyph].
  ///
  /// [ligatures] are join candidates (`==`, `!=`, `->`). Anything shorter
  /// than two code points, containing line breaks, or repeated is dropped.
  /// At each position the longest matching ligature wins. Single ASCII
  /// characters do not allocate a new string: they come from a shared cache.
  ///
  /// [inheritedStyle] is the outer container style, for example an editor
  /// theme. Cache the result: tokenization should not repeat every frame.
  ///
  /// Разворачивает дерево в плоский ряд [AtlasGlyph].
  ///
  /// [ligatures] — кандидаты на склейку (`==`, `!=`, `->`). Короче двух
  /// code point, с переводами строк и повторы отбрасываются. На каждой
  /// позиции берётся самая длинная подходящая лигатура. Одиночные
  /// символы ASCII не аллоцируют новую строку: они берутся из общего кэша.
  ///
  /// [inheritedStyle] — стиль внешнего контейнера, например темы редактора.
  /// Результат стоит кэшировать: на кадр токенизация не должна повторяться.
  List<AtlasGlyph> flattenWithLigatures(
    List<String> ligatures, {
    AtlasTextStyle? inheritedStyle,
  }) {
    final glyphs = <AtlasGlyph>[];
    _append(
      glyphs,
      _indexLigatures(ligatures),
      inheritedStyle ?? AtlasTextStyle.empty,
    );
    return glyphs;
  }

  void _append(
    List<AtlasGlyph> into,
    Map<int, List<_Ligature>> ligatures,
    AtlasTextStyle inherited,
  ) {
    final resolved = inherited.merge(style);
    final childSpans = children;
    if (childSpans != null) {
      for (final child in childSpans) {
        child._append(into, ligatures, resolved);
      }
      return;
    }
    final value = text;
    if (value == null || value.isEmpty) {
      return;
    }
    _tokenize(into, value, resolved, this, ligatures);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AtlasTextSpan &&
        other.text == text &&
        other.style == style &&
        _sameChildren(children, other.children);
  }

  @override
  int get hashCode => Object.hash(text, style, _hashChildren(children));

  @override
  String toString() {
    final childSpans = children;
    if (childSpans != null) {
      return 'AtlasTextSpan(children: ${childSpans.length})';
    }
    return 'AtlasTextSpan("$text")';
  }
}

/// A prepared ligature: canonical string and width in cells.
///
/// Подготовленная лигатура: каноническая строка и ширина в ячейках.
class _Ligature {
  const _Ligature(this.text, this.charCount);

  final String text;
  final int charCount;
}

/// ASCII 0..126, so a leaf does not allocate a `String` per character.
///
/// ASCII 0..126, чтобы лист не создавал `String` на каждый символ.
final List<String> _ascii = List<String>.generate(
  127,
  String.fromCharCode,
  growable: false,
);

Map<int, List<_Ligature>> _indexLigatures(List<String> ligatures) {
  final grouped = <int, List<_Ligature>>{};
  final seen = <String>{};
  for (final raw in ligatures) {
    final charCount = raw.runes.length;
    if (charCount < 2 || !seen.add(raw) || _hasLineBreak(raw)) {
      continue;
    }
    final bucket = grouped.putIfAbsent(
      raw.codeUnitAt(0),
      () => <_Ligature>[],
    );
    bucket.add(_Ligature(raw, charCount));
  }
  for (final bucket in grouped.values) {
    bucket.sort((a, b) {
      final byUnits = b.text.length.compareTo(a.text.length);
      if (byUnits != 0) {
        return byUnits;
      }
      return b.charCount.compareTo(a.charCount);
    });
  }
  return grouped;
}

bool _hasLineBreak(String value) {
  return value.contains('\n') ||
      value.contains('\r') ||
      value.contains('\u2028') ||
      value.contains('\u2029');
}

void _tokenize(
  List<AtlasGlyph> into,
  String text,
  AtlasTextStyle style,
  AtlasTextSpan source,
  Map<int, List<_Ligature>> ligatures,
) {
  final length = text.length;
  var index = 0;
  while (index < length) {
    final unit = text.codeUnitAt(index);
    final ligature = _match(text, index, ligatures[unit]);
    if (ligature != null) {
      into.add(
        AtlasGlyph(
          text: ligature.text,
          style: style,
          sourceSpan: source,
          charCount: ligature.charCount,
        ),
      );
      index += ligature.text.length;
      continue;
    }
    if (unit <= 0x7F) {
      into.add(
        AtlasGlyph(
          text: _ascii[unit],
          style: style,
          sourceSpan: source,
          charCount: 1,
        ),
      );
      index += 1;
      continue;
    }
    final runeLength = _runeUtf16Length(text, index);
    into.add(
      AtlasGlyph(
        text: text.substring(index, index + runeLength),
        style: style,
        sourceSpan: source,
        charCount: 1,
      ),
    );
    index += runeLength;
  }
}

_Ligature? _match(String text, int index, List<_Ligature>? candidates) {
  if (candidates == null) {
    return null;
  }
  final end = text.length;
  for (final ligature in candidates) {
    final ligatureLength = ligature.text.length;
    if (index + ligatureLength <= end &&
        text.startsWith(ligature.text, index)) {
      return ligature;
    }
  }
  return null;
}

int _runeUtf16Length(String text, int index) {
  final unit = text.codeUnitAt(index);
  if (unit >= 0xD800 && unit <= 0xDBFF && index + 1 < text.length) {
    final next = text.codeUnitAt(index + 1);
    if (next >= 0xDC00 && next <= 0xDFFF) {
      return 2;
    }
  }
  return 1;
}

bool _sameChildren(List<AtlasTextSpan>? a, List<AtlasTextSpan>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

int _hashChildren(List<AtlasTextSpan>? list) {
  if (list == null) {
    return 0;
  }
  var hash = 0;
  for (final child in list) {
    hash = Object.hash(hash, child);
  }
  return hash;
}
