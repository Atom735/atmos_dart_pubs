import 'dart:ui';

import 'package:flutter/rendering.dart';

import 'atlas_manager.dart';
import 'models/flattened_line_cache.dart';

/// Default white — the same value as `Colors.white`.
///
/// The atlas glyph is white too, so a letter stays white without an
/// explicit color.
///
/// Белый по умолчанию — то же значение, что у `Colors.white`.
///
/// Глиф в атласе тоже белый, поэтому без явного цвета буква остаётся белой.
const Color _defaultGlyphColor = Color(0xFFFFFFFF);

/// Frame lists live on the manager, not on the painter.
///
/// A widget usually creates a new [AtlasTextPainter] on every build.
/// [Expando] keeps list capacity across those instances.
///
/// Списки кадра живут на менеджере, а не на painter.
///
/// Виджет обычно создаёт новый [AtlasTextPainter] на каждый build.
/// [Expando] сохраняет ёмкость списков между этими экземплярами.
final Expando<_AtlasFrameBuffer> _frameBuffers = Expando<_AtlasFrameBuffer>();

/// Projects ready lines into one `Canvas.drawAtlas`.
///
/// [paint] has no `ParagraphBuilder` and does not parse text. Coordinates
/// come from the monospace grid and the DPR captured with the texture.
///
/// After [AtlasManager.updateDpr] the widget must build the painter again:
/// [shouldRepaint] compares the DPR and texture snapshot, not the live
/// manager fields (the old and new painters share the same object).
///
/// Проекция готовых строк в один `Canvas.drawAtlas`.
///
/// В [paint] нет `ParagraphBuilder` и нет разбора текста. Координаты
/// считаются из моноширинной сетки и DPR, снятого вместе с текстурой.
///
/// После [AtlasManager.updateDpr] виджет должен собрать painter заново:
/// [shouldRepaint] сравнивает снимок DPR и текстуры, а не живые поля
/// менеджера (старый и новый painter держат один и тот же объект).
class AtlasTextPainter extends CustomPainter {
  /// [visibleLines] is only what is on screen now, top to bottom.
  ///
  /// [visibleLines] — только то, что сейчас на экране, сверху вниз.
  AtlasTextPainter({
    required this.atlasManager,
    required this.visibleLines,
  })  : dpr = atlasManager.dpr,
        atlasImage = atlasManager.atlasImage,
        cellWidthPx = atlasManager.cellWidthPx,
        cellHeightPx = atlasManager.cellHeightPx;

  /// Source of the texture and glyph rectangles.
  ///
  /// Источник текстуры и прямоугольников глифов.
  final AtlasManager atlasManager;

  /// Viewport lines. An empty list draws nothing.
  ///
  /// Строки вьюпорта. Пустой список — кадр ничего не рисует.
  final List<FlattenedLineCache> visibleLines;

  /// DPR at the moment the painter was created.
  ///
  /// DPR на момент создания painter.
  final double dpr;

  /// Texture at the moment the painter was created.
  /// May already be [Image.dispose].
  ///
  /// Текстура на момент создания painter. Может быть уже [Image.dispose].
  final Image? atlasImage;

  /// Cell width in atlas pixels at creation time.
  ///
  /// Ширина ячейки в пикселях атласа на момент создания.
  final int cellWidthPx;

  /// Cell height in atlas pixels at creation time.
  ///
  /// Высота ячейки в пикселях атласа на момент создания.
  final int cellHeightPx;

  final Paint _backgroundPaint = Paint()..isAntiAlias = false;

  final Paint _glyphPaint = Paint()..filterQuality = FilterQuality.none;

  @override
  void paint(Canvas canvas, Size size) {
    final atlas = atlasManager.atlasImage;
    if (atlas == null || visibleLines.isEmpty) {
      return;
    }
    final pixelRatio = atlasManager.dpr;
    final cellWidth = atlasManager.cellWidthPx;
    final cellHeight = atlasManager.cellHeightPx;
    if (!(pixelRatio > 0) || cellWidth <= 0 || cellHeight <= 0) {
      return;
    }

    // Logical cell. charWidth * dpr == cellWidthPx, so after
    // scale(1 / dpr) the sprite maps texel to pixel, with no second scale.
    // Логическая ячейка. charWidth * dpr == cellWidthPx, поэтому после
    // scale(1 / dpr) спрайт ложится тексель в пиксель, без повторного масштаба.
    final charWidth = cellWidth / pixelRatio;
    final charHeight = cellHeight / pixelRatio;

    canvas.save();
    // The atlas is in physical pixels, the Flutter canvas in logical ones.
    // X/Y below are logical position * dpr.
    // Атлас в физических пикселях, холст Flutter — в логических.
    // Дальше X/Y задаются как логическая позиция * dpr.
    canvas.scale(1 / pixelRatio);
    _paintBackgrounds(
      canvas,
      pixelRatio: pixelRatio,
      charWidth: charWidth,
      charHeight: charHeight,
    );
    _paintGlyphs(
      canvas,
      size,
      atlas,
      pixelRatio: pixelRatio,
      charWidth: charWidth,
      charHeight: charHeight,
    );
    canvas.restore();
  }

  void _paintBackgrounds(
    Canvas canvas, {
    required double pixelRatio,
    required double charWidth,
    required double charHeight,
  }) {
    final lineHeight = charHeight * pixelRatio;
    final lines = visibleLines;
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final top = lineIndex * lineHeight;
      var x = 0.0;
      Color? runColor;
      var runLeft = 0.0;
      var runWidth = 0.0;

      void flush() {
        final color = runColor;
        if (color == null || runWidth <= 0) {
          return;
        }
        // Neighboring glyphs of one color merge into a single rectangle.
        // Соседние глифы одного цвета сливаются в один прямоугольник.
        _backgroundPaint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(runLeft, top, runWidth, lineHeight),
          _backgroundPaint,
        );
        runColor = null;
        runWidth = 0;
      }

      for (final glyph in lines[lineIndex].glyphs) {
        if (_isLineBreak(glyph.text)) {
          continue;
        }
        final width = charWidth * glyph.charCount * pixelRatio;
        final left = x * pixelRatio;
        final background = glyph.style.backgroundColor;
        if (background == null) {
          flush();
        } else if (runColor == background) {
          runWidth += width;
        } else {
          flush();
          runColor = background;
          runLeft = left;
          runWidth = width;
        }
        // A ligature advances the caret by charCount cells, not by one.
        // Лигатура сдвигает каретку на charCount ячеек, не на одну.
        x += charWidth * glyph.charCount;
      }
      flush();
    }
  }

  void _paintGlyphs(
    Canvas canvas,
    Size size,
    Image atlas, {
    required double pixelRatio,
    required double charWidth,
    required double charHeight,
  }) {
    final buffer =
        _frameBuffers[atlasManager] ??= _AtlasFrameBuffer();
    final transforms = buffer.transforms..clear();
    final rects = buffer.rects..clear();
    final colors = buffer.colors..clear();
    final lines = visibleLines;
    final lineHeight = charHeight * pixelRatio;

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final top = lineIndex * lineHeight;
      var x = 0.0;
      for (final glyph in lines[lineIndex].glyphs) {
        if (_isLineBreak(glyph.text)) {
          continue;
        }
        final advance = charWidth * glyph.charCount;
        final source = atlasManager.getGlyph(glyph.text);
        if (source != null) {
          final left = x * pixelRatio;
          // rotation 0, scale 1, anchor (0, 0) is the top-left corner of
          // the source rect in its local coordinates. fromComponents with
          // those arguments collapses to RSTransform(1, 0, left, top):
          // sin(0) and cos(0) are not computed per glyph.
          // rotation 0, scale 1, anchor (0, 0) — это верхний левый угол
          // вырезки в её локальных координатах. fromComponents при таких
          // аргументах вырождается в RSTransform(1, 0, left, top):
          // sin(0) и cos(0) не считаются на каждый глиф.
          transforms.add(RSTransform(1, 0, left, top));
          rects.add(source);
          colors.add(glyph.style.color ?? _defaultGlyphColor);
        }
        x += advance;
      }
    }

    if (transforms.isEmpty) {
      return;
    }
    canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      colors,
      // The atlas is a white mask with alpha. modulate multiplies it by
      // the glyph color. srcIn would keep white RGB and take only the
      // color's alpha.
      // Атлас — белая маска с альфой. modulate умножает её на цвет глифа.
      // srcIn оставил бы белый RGB и взял бы только альфу цвета.
      BlendMode.modulate,
      Rect.fromLTWH(0, 0, size.width * pixelRatio, size.height * pixelRatio),
      _glyphPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AtlasTextPainter oldDelegate) {
    if (oldDelegate.dpr != dpr ||
        oldDelegate.cellWidthPx != cellWidthPx ||
        oldDelegate.cellHeightPx != cellHeightPx ||
        !identical(oldDelegate.atlasImage, atlasImage)) {
      return true;
    }
    return _linesChanged(oldDelegate.visibleLines, visibleLines);
  }
}

bool _linesChanged(
  List<FlattenedLineCache> previous,
  List<FlattenedLineCache> next,
) {
  if (previous.length != next.length) {
    return true;
  }
  for (var i = 0; i < next.length; i++) {
    final before = previous[i];
    final after = next[i];
    if (identical(before, after)) {
      continue;
    }
    if (before.charCount != after.charCount ||
        before.glyphs.length != after.glyphs.length ||
        before.compositionHash != after.compositionHash) {
      return true;
    }
    for (var j = 0; j < after.glyphs.length; j++) {
      if (before.glyphs[j] != after.glyphs[j]) {
        return true;
      }
    }
  }
  return false;
}

bool _isLineBreak(String text) {
  return text == '\n' || text == '\r' || text == '\u2028' || text == '\u2029';
}

class _AtlasFrameBuffer {
  final List<RSTransform> transforms = <RSTransform>[];
  final List<Rect> rects = <Rect>[];
  final List<Color> colors = <Color>[];
}
