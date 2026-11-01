import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'atlas_text_span.dart';

/// Color of a glyph and of its background.
///
/// Both fields are optional: `null` means "inherit from the parent".
/// Color is not baked into the atlas — glyphs are white, and the final
/// tint is passed to `Canvas.drawAtlas` in the `colors` array.
///
/// Цвет глифа и его подложки.
///
/// Оба поля необязательны: `null` означает «наследовать от родителя».
/// В атлас цвет не запекается — глифы белые, а итоговый оттенок
/// передаётся в `Canvas.drawAtlas` массивом `colors`.
@immutable
class AtlasTextStyle {
  /// Empty style: both channels are inherited.
  ///
  /// Пустой стиль: оба канала наследуются.
  static const AtlasTextStyle empty = AtlasTextStyle();

  /// Creates a style. A transparent color is a value, not inheritance:
  /// pass an explicit [Color] to clear the parent color.
  ///
  /// Создаёт стиль. Прозрачный цвет — это значение, а не наследование:
  /// чтобы сбросить цвет родителя, передайте явный [Color].
  const AtlasTextStyle({
    this.color,
    this.backgroundColor,
  });

  /// Text color. `null` takes the color of the outer span.
  ///
  /// Цвет текста. `null` — взять цвет внешнего спана.
  final Color? color;

  /// Cell background color. `null` means no background of its own.
  ///
  /// Цвет подложки ячейки. `null` — без собственной подложки.
  final Color? backgroundColor;

  /// Layers [other] on top of this style.
  ///
  /// Fields of [other] that are `null` do not overwrite values already set.
  /// If the overlay changes nothing, the same instance is returned.
  ///
  /// Накладывает [other] поверх этого стиля.
  ///
  /// Поля [other], равные `null`, не затирают уже заданные значения.
  /// Если перекрытие ничего не меняет, возвращается тот же экземпляр.
  AtlasTextStyle merge(AtlasTextStyle? other) {
    if (other == null) {
      return this;
    }
    final nextColor = other.color ?? color;
    final nextBackground = other.backgroundColor ?? backgroundColor;
    if (nextColor == color && nextBackground == backgroundColor) {
      return this;
    }
    return AtlasTextStyle(
      color: nextColor,
      backgroundColor: nextBackground,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AtlasTextStyle &&
        other.color == color &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(color, backgroundColor);

  @override
  String toString() {
    return 'AtlasTextStyle(color: $color, backgroundColor: $backgroundColor)';
  }
}

/// A flat screen atom: one character or a wide ligature.
///
/// [sourceSpan] points at the text node the glyph was built from.
/// A hit test lands on the sprite and follows this reference back to the
/// span, without walking the tree again.
///
/// Плоский атом экрана: один символ или широкая лигатура.
///
/// [sourceSpan] указывает на текстовый узел, из которого собран глиф.
/// Хит-тест попадает в спрайт и по этой ссылке возвращается к спану,
/// не обходя дерево заново.
@immutable
class AtlasGlyph {
  /// Creates a glyph. [charCount] is the Unicode code point count in [text].
  ///
  /// Создаёт глиф. [charCount] — число Unicode code point в [text].
  const AtlasGlyph({
    required this.text,
    required this.style,
    required this.sourceSpan,
    required this.charCount,
  })  : assert(text != '', 'Glyph text must not be empty.'),
        assert(charCount > 0, 'charCount must be positive.');

  /// Sprite letters. For a ligature this is the whole run, for example `==`.
  ///
  /// Буквы спрайта. Для лигатуры это вся склейка, например `==`.
  final String text;

  /// Already resolved style: inheritance has been applied by this point.
  ///
  /// Уже разрешённый стиль: наследование к этому моменту применено.
  final AtlasTextStyle style;

  /// Owning text node. Used for hit testing.
  ///
  /// Текстовый узел-владелец. Нужен для хит-тестирования.
  final AtlasTextSpan sourceSpan;

  /// How many monospace cells the sprite occupies.
  ///
  /// Сколько моноширинных ячеек занимает спрайт.
  final int charCount;

  @override
  bool operator ==(Object other) {
    return other is AtlasGlyph &&
        other.text == text &&
        other.style == style &&
        other.charCount == charCount &&
        identical(other.sourceSpan, sourceSpan);
  }

  @override
  int get hashCode {
    return Object.hash(text, style, charCount, identityHashCode(sourceSpan));
  }

  @override
  String toString() => 'AtlasGlyph("$text" × $charCount)';
}
