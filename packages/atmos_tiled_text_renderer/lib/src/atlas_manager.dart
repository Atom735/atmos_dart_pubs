import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Glyph rectangle in the atlas texture.
///
/// [source] is in physical image pixels, on whole cell edges.
/// The index is split by the grid bit mask:
/// column is `index & columnMask`, row is `index >> columnShift`.
///
/// Прямоугольник глифа в текстуре атласа.
///
/// [source] задан в физических пикселях изображения, по целым границам
/// ячеек. Индекс раскладывается битовой маской сетки:
/// колонка — `index & columnMask`, строка — `index >> columnShift`.
@immutable
class AtlasRegion {
  /// Creates a sprite description.
  ///
  /// Создаёт описание спрайта.
  const AtlasRegion({
    required this.index,
    required this.charCount,
    required this.source,
  });

  /// Index of the first cell in the power-of-two grid.
  ///
  /// Индекс первой ячейки в степенной-двойки сетке.
  final int index;

  /// Sprite width in monospace cells.
  ///
  /// Ширина спрайта в моноширинных ячейках.
  final int charCount;

  /// Source rect in atlas pixels. Edges are whole, with no half-texel shift.
  ///
  /// Вырезка в пикселях атласа. Края целые, без полутексельного сдвига.
  final Rect source;
}

/// Lifetime of the GPU texture for a monospace atlas.
///
/// Baking happens when the device pixel ratio or the ligature set changes,
/// not on every frame. Glyphs are drawn white (`0xFFFFFFFF`) on a transparent
/// background so the whole screen is one `Canvas.drawAtlas`:
/// the letter color arrives in `colors`, and the background is the
/// [solidRegion] sprite, tinted by the same call. Atlas sampling is
/// `FilterQuality.none`, and the destination rect on screen matches the
/// cell one-to-one.
///
/// Жизненный цикл GPU-текстуры моноширинного атласа.
///
/// Запекание случается при смене device pixel ratio или набора лигатур,
/// а не на каждом кадре. Глифы рисуются белым (`0xFFFFFFFF`) на прозрачном
/// фоне, чтобы весь экран собирался одним `Canvas.drawAtlas`:
/// цвет буквы приходит в `colors`, а подложка — спрайтом [solidRegion],
/// покрашенным тем же вызовом. Выборка атласа — `FilterQuality.none`,
/// прямоугольник назначения на экране равен ячейке один-в-один.
class AtlasManager {
  /// [fontFamily] is the monospace font family.
  /// [logicalFontSize] is the size in logical pixels, before DPR.
  ///
  /// [fontFamily] — семейство моноширинного шрифта.
  /// [logicalFontSize] — кегль в логических пикселях, до DPR.
  AtlasManager({
    required this.fontFamily,
    required this.logicalFontSize,
  }) {
    if (fontFamily.isEmpty) {
      throw ArgumentError.value(
        fontFamily,
        'fontFamily',
        'Font family must not be empty.',
      );
    }
    if (!(logicalFontSize > 0) ||
        logicalFontSize.isNaN ||
        logicalFontSize.isInfinite) {
      throw ArgumentError.value(
        logicalFontSize,
        'logicalFontSize',
        'Font size must be a finite number greater than zero.',
      );
    }
  }

  /// Family used to measure and bake the atlas.
  ///
  /// Семейство, которым измеряется и запекается атлас.
  final String fontFamily;

  /// Size in logical pixels.
  ///
  /// Кегль в логических пикселях.
  final double logicalFontSize;

  static const int _textureLimit = 4096;

  static const List<String> _monoFallbacks = <String>[
    'monospace',
    'JetBrains Mono',
    'Cascadia Mono',
    'DejaVu Sans Mono',
    'Menlo',
    'Consolas',
  ];

  /// The font's OpenType ligatures are off: a wide `==` cell must
  /// hold two characters, not a substituted font glyph.
  ///
  /// OpenType-лигатуры шрифта выключены: широкая ячейка `==` должна
  /// содержать два знака, а не подменённый глиф шрифта.
  static const List<FontFeature> _literalGlyphs = <FontFeature>[
    FontFeature.disable('liga'),
    FontFeature.disable('clig'),
    FontFeature.disable('calt'),
  ];

  static final List<String> _ascii = List<String>.generate(
    127,
    String.fromCharCode,
    growable: false,
  );

  Image? _image;
  Map<String, AtlasRegion> _regions = const <String, AtlasRegion>{};
  AtlasRegion? _solid;
  double _logicalCellWidth = 0;
  double _logicalCellHeight = 0;
  int _cellWidthPx = 0;
  int _cellHeightPx = 0;
  double _dpr = 1;
  int _columns = 0;
  int _columnShift = 0;
  int _generation = 0;
  bool _disposed = false;

  /// Current texture. `null` until [updateDpr], or after [dispose].
  ///
  /// Текущая текстура. `null`, пока не вызван [updateDpr] или после [dispose].
  Image? get image => _image;

  /// Same as [image]. Short name for the hot paint path.
  ///
  /// То же, что [image]. Короткое имя для горячего пути отрисовки.
  Image? get atlasImage => _image;

  /// The atlas is baked and the manager is still alive.
  ///
  /// Атлас запечён и менеджер ещё жив.
  bool get isReady => !_disposed && _image != null;

  /// DPR of the last successful bake.
  ///
  /// DPR последнего успешного запекания.
  double get devicePixelRatio => _dpr;

  /// Same as [devicePixelRatio].
  ///
  /// То же, что [devicePixelRatio].
  double get dpr => _dpr;

  /// Width of one cell in the font's logical pixels, before DPR.
  ///
  /// Ширина одной ячейки в логических пикселях шрифта, до DPR.
  double get logicalCellWidth => _logicalCellWidth;

  /// Line height in the font's logical pixels, before DPR.
  ///
  /// Высота строки в логических пикселях шрифта, до DPR.
  double get logicalCellHeight => _logicalCellHeight;

  /// Cell width in atlas pixels.
  ///
  /// Ширина ячейки в пикселях атласа.
  int get cellWidthPx => _cellWidthPx;

  /// Cell height in atlas pixels.
  ///
  /// Высота ячейки в пикселях атласа.
  int get cellHeightPx => _cellHeightPx;

  /// Number of grid columns. Always a power of two while the atlas is ready.
  ///
  /// Число колонок сетки. Всегда степень двойки, пока атлас готов.
  int get columns => _columns;

  /// Row shift: `index >> columnShift`.
  ///
  /// Сдвиг строки: `index >> columnShift`.
  int get columnShift => _columnShift;

  /// Column mask: `index & columnMask`. Zero until the atlas is baked.
  ///
  /// Маска колонки: `index & columnMask`. Ноль, пока атлас не запечён.
  int get columnMask => _columns == 0 ? 0 : _columns - 1;

  /// How many text sprites are baked, excluding the white background cell.
  ///
  /// Сколько текстовых спрайтов запечено, без белой ячейки подложки.
  int get bakedGlyphCount => _regions.length;

  /// White cell for backgrounds in the same `drawAtlas` as the letters.
  ///
  /// Белая ячейка для фонов в том же `drawAtlas`, что и буквы.
  AtlasRegion? get solidRegion => _solid;

  /// Source rect of glyph [text], or `null` if that sprite is not baked.
  ///
  /// Вырезка глифа [text] или `null`, если такой спрайт не запечён.
  AtlasRegion? regionFor(String text) => _regions[text];

  /// Rectangle of [text] in the atlas texture.
  ///
  /// The same object stored by [regionFor]: a frame can pass it to
  /// `drawAtlas` without copying the [Rect]. `null` if the sprite is not baked.
  ///
  /// Прямоугольник [text] в текстуре атласа.
  ///
  /// Тот же объект, что лежит в [regionFor]: кадр может положить его
  /// в `drawAtlas`, не копируя [Rect]. `null`, если спрайт не запечён.
  Rect? getGlyph(String text) => _regions[text]?.source;

  /// Rebakes the atlas for [newDpr].
  ///
  /// The canvas size is `logicalFontSize * newDpr`. The cell is measured
  /// at that size through [ParagraphBuilder] and raised to a whole number
  /// of pixels, so on Retina (DPR 2 and above) strokes are not blurred by
  /// a second scale. The texture receives ASCII 32–126 and
  /// [standardLigatures]. The previous [image] is released with `dispose`
  /// only after the new texture is ready.
  ///
  /// Перезапекает атлас под [newDpr].
  ///
  /// Кегль на холсте равен `logicalFontSize * newDpr`. Ячейка измеряется
  /// уже на этом кегле через [ParagraphBuilder] и поднимается до целого
  /// числа пикселей, чтобы на Retina (DPR 2 и выше) штрихи не мылись
  /// повторным масштабом. В текстуру попадают ASCII 32–126 и
  /// [standardLigatures]. Предыдущий [image] освобождается через `dispose`
  /// только после того, как новая текстура готова.
  Future<void> updateDpr(
    double newDpr,
    List<String> standardLigatures,
  ) {
    if (_disposed) {
      throw StateError('AtlasManager has been disposed.');
    }
    if (!(newDpr > 0) || newDpr.isNaN || newDpr.isInfinite) {
      throw ArgumentError.value(
        newDpr,
        'newDpr',
        'DPR must be a finite number greater than zero.',
      );
    }
    final generation = ++_generation;
    return _bake(newDpr, standardLigatures, generation);
  }

  /// Releases the texture. A second call is safe.
  ///
  /// Отпускает текстуру. Повторный вызов безопасен.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _generation++;
    _image?.dispose();
    _image = null;
    _regions = const <String, AtlasRegion>{};
    _solid = null;
  }

  /// Logical cell size at [logicalFontSize], without DPR.
  ///
  /// Width is the average advance of eight zeros, height is the line box
  /// of a line with ascenders and descenders. The monospace grid then
  /// does not clip `g`.
  ///
  /// Логический размер ячейки при [logicalFontSize], без DPR.
  ///
  /// Ширина — средняя advance восьми нулей, высота — line box строки
  /// с верхними и нижними выносными. Так моноширинная сетка не режет `g`.
  void _measureLogicalCell() {
    if (_logicalCellWidth > 0 && _logicalCellHeight > 0) {
      return;
    }
    final metrics = _measureAdvance(logicalFontSize);
    _logicalCellWidth = metrics.width;
    _logicalCellHeight = metrics.height;
  }

  Future<void> _bake(
    double newDpr,
    List<String> standardLigatures,
    int generation,
  ) async {
    _measureLogicalCell();
    final deviceFontSize = logicalFontSize * newDpr;
    final device = _measureAdvance(deviceFontSize);
    final cellWidthPx = device.width.ceil().clamp(1, _textureLimit);
    final cellHeightPx =
        device.height.ceil().clamp(1, _textureLimit);
    final keys = _glyphKeys(standardLigatures);
    final layout = _layoutAtlas(
      keys: keys,
      cellWidthPx: cellWidthPx,
      cellHeightPx: cellHeightPx,
    );

    final regions = <String, AtlasRegion>{};
    AtlasRegion? solid;
    for (final placement in layout.placements) {
      final region = AtlasRegion(
        index: placement.index,
        charCount: placement.charCount,
        source: _sourceRect(placement, layout),
      );
      if (placement.solid) {
        solid = region;
      } else {
        regions[placement.text] = region;
      }
    }

    final recorder = PictureRecorder();
    Picture? picture;
    try {
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
          0,
          0,
          layout.width.toDouble(),
          layout.height.toDouble(),
        ),
      );
      _paintAtlas(canvas, layout, deviceFontSize);
      picture = recorder.endRecording();
      final image = await picture.toImage(layout.width, layout.height);
      if (_disposed || generation != _generation) {
        image.dispose();
        return;
      }
      final previous = _image;
      _image = image;
      _regions = Map<String, AtlasRegion>.unmodifiable(regions);
      _solid = solid;
      _dpr = newDpr;
      _cellWidthPx = cellWidthPx;
      _cellHeightPx = cellHeightPx;
      _columns = layout.columns;
      _columnShift = layout.shift;
      previous?.dispose();
    } finally {
      picture?.dispose();
    }
  }

  _CellMetrics _measureAdvance(double fontSize) {
    final widthSample = _paragraph('00000000', fontSize);
    final heightSample = _paragraph('Hgjy|', fontSize);
    try {
      final width = widthSample.maxIntrinsicWidth / 8;
      final height = heightSample.height;
      if (!(width > 0) || !(height > 0)) {
        throw StateError(
          'Failed to measure a cell of "$fontFamily" at size $fontSize.',
        );
      }
      return _CellMetrics(width, height);
    } finally {
      widthSample.dispose();
      heightSample.dispose();
    }
  }

  Paragraph _paragraph(String sample, double fontSize) {
    final builder = ParagraphBuilder(
      ParagraphStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      ),
    )
      ..pushStyle(_glyphStyle(fontSize))
      ..addText(sample);
    final paragraph = builder.build();
    paragraph.layout(const ParagraphConstraints(width: double.infinity));
    return paragraph;
  }

  TextStyle _glyphStyle(double fontSize) {
    return TextStyle(
      color: const Color(0xFFFFFFFF),
      fontFamily: fontFamily,
      fontFamilyFallback: _monoFallbacks,
      fontSize: fontSize,
      fontFeatures: _literalGlyphs,
    );
  }

  List<String> _glyphKeys(List<String> standardLigatures) {
    final keys = <String>[];
    for (var code = 32; code <= 126; code++) {
      keys.add(_ascii[code]);
    }
    final seen = <String>{...keys};
    final extra = <String>[];
    for (final raw in standardLigatures) {
      if (raw.runes.length < 2 || _containsLineBreak(raw) || !seen.add(raw)) {
        continue;
      }
      extra.add(raw);
    }
    extra.sort((a, b) {
      final byLength = b.length.compareTo(a.length);
      if (byLength != 0) {
        return byLength;
      }
      return a.compareTo(b);
    });
    keys.addAll(extra);
    return keys;
  }

  _AtlasLayout _layoutAtlas({
    required List<String> keys,
    required int cellWidthPx,
    required int cellHeightPx,
  }) {
    final maxCols = _textureLimit ~/ cellWidthPx;
    final longest = _longestRun(keys);
    if (maxCols < longest || cellHeightPx > _textureLimit) {
      throw ArgumentError(
        'Cell ${cellWidthPx}x$cellHeightPx px does not fit in a '
        '$_textureLimit atlas together with a $longest-cell ligature.',
      );
    }

    final preferredCols = (2048 ~/ cellWidthPx).clamp(longest, maxCols);
    var shift = 0;
    while ((1 << (shift + 1)) <= preferredCols) {
      shift++;
    }
    if ((1 << shift) < longest) {
      if ((1 << (shift + 1)) > maxCols) {
        throw ArgumentError(
          'A $longest-cell ligature does not fit a power-of-two grid '
          'no wider than $_textureLimit px.',
        );
      }
      shift++;
    }

    while (true) {
      final columns = 1 << shift;
      final pack = _pack(keys, columns, shift);
      final width = columns * cellWidthPx;
      final height = pack.rows * cellHeightPx;
      if (width <= _textureLimit && height <= _textureLimit) {
        return _AtlasLayout(
          placements: pack.placements,
          columns: columns,
          shift: shift,
          width: width,
          height: height,
          cellWidthPx: cellWidthPx,
          cellHeightPx: cellHeightPx,
        );
      }
      if ((1 << (shift + 1)) > maxCols) {
        throw ArgumentError(
          'Atlas ${width}x$height px exceeds $_textureLimit. '
          'Reduce the font size, DPR, or ligature count.',
        );
      }
      shift++;
    }
  }

  void _paintAtlas(Canvas canvas, _AtlasLayout layout, double fontSize) {
    final solidPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..isAntiAlias = false;
    final style = _glyphStyle(fontSize);
    final paragraphStyle = ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    for (final placement in layout.placements) {
      final rect = _sourceRect(placement, layout);
      if (placement.solid) {
        canvas.drawRect(rect, solidPaint);
        continue;
      }
      final builder = ParagraphBuilder(paragraphStyle)
        ..pushStyle(style)
        ..addText(placement.text);
      final paragraph = builder.build();
      paragraph.layout(ParagraphConstraints(width: rect.width + 1));
      canvas.save();
      canvas.clipRect(rect, doAntiAlias: false);
      canvas.drawParagraph(paragraph, Offset(rect.left, rect.top));
      canvas.restore();
      paragraph.dispose();
    }
  }
}

Rect _sourceRect(_Placement placement, _AtlasLayout layout) {
  final column = placement.index & (layout.columns - 1);
  final row = placement.index >> layout.shift;
  return Rect.fromLTWH(
    (column * layout.cellWidthPx).toDouble(),
    (row * layout.cellHeightPx).toDouble(),
    (placement.charCount * layout.cellWidthPx).toDouble(),
    layout.cellHeightPx.toDouble(),
  );
}

int _longestRun(List<String> keys) {
  var longest = 1;
  for (final key in keys) {
    final count = key.runes.length;
    if (count > longest) {
      longest = count;
    }
  }
  return longest;
}

bool _containsLineBreak(String value) {
  return value.contains('\n') ||
      value.contains('\r') ||
      value.contains('\u2028') ||
      value.contains('\u2029');
}

_Pack _pack(List<String> keys, int columns, int shift) {
  final placements = <_Placement>[
    const _Placement(text: '', index: 0, charCount: 1, solid: true),
  ];
  var cursor = 1;
  var lastIndex = 0;
  final mask = columns - 1;
  for (final key in keys) {
    final count = key.runes.length;
    if ((cursor & mask) + count > columns) {
      cursor = ((cursor >> shift) + 1) << shift;
    }
    placements.add(
      _Placement(
        text: key,
        index: cursor,
        charCount: count,
        solid: false,
      ),
    );
    final end = cursor + count - 1;
    if (end > lastIndex) {
      lastIndex = end;
    }
    cursor += count;
  }
  return _Pack(
    placements: placements,
    rows: (lastIndex >> shift) + 1,
  );
}

class _CellMetrics {
  const _CellMetrics(this.width, this.height);

  final double width;
  final double height;
}

class _Placement {
  const _Placement({
    required this.text,
    required this.index,
    required this.charCount,
    required this.solid,
  });

  final String text;
  final int index;
  final int charCount;
  final bool solid;
}

class _Pack {
  const _Pack({
    required this.placements,
    required this.rows,
  });

  final List<_Placement> placements;
  final int rows;
}

class _AtlasLayout {
  const _AtlasLayout({
    required this.placements,
    required this.columns,
    required this.shift,
    required this.width,
    required this.height,
    required this.cellWidthPx,
    required this.cellHeightPx,
  });

  final List<_Placement> placements;
  final int columns;
  final int shift;
  final int width;
  final int height;
  final int cellWidthPx;
  final int cellHeightPx;
}
