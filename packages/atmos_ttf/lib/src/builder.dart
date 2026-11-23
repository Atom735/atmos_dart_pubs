import 'dart:math' as math;
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import 'cmap.dart';
import 'errors.dart';
import 'font.dart';
import 'glyph.dart';
import 'open.dart';
import 'table_record.dart';
import 'tables/head.dart';
import 'tables/hhea.dart';
import 'tables/hmtx.dart';
import 'tables/maxp.dart';
import 'tables/name.dart';
import 'tables/os2.dart';
import 'tables/post.dart';

/// Builds a minimal TrueType icon font from simple glyphs.
///
/// Собирает минимальный TrueType-шрифт иконок из простых глифов.
class TtfFontBuilder {
  /// Creates a builder.
  ///
  /// Glyph index `0` should be the empty `.notdef` (call [addEmptyGlyph]
  /// first).
  ///
  /// Создаёт билдер.
  ///
  /// Индекс `0` обычно пустой `.notdef` (сначала [addEmptyGlyph]).
  TtfFontBuilder({
    required this.familyName,
    this.subfamilyName = 'Regular',
    this.unitsPerEm = 1000,
    this.ascender,
    this.descender,
    this.manufacturer,
    this.version = 'Version 1.000',
  });

  /// Font family name (`name` id 1).
  final String familyName;

  /// Subfamily (`name` id 2).
  final String subfamilyName;

  /// Units per em.
  final int unitsPerEm;

  /// Override ascender (default = [unitsPerEm]).
  final int? ascender;

  /// Override descender (default = 0).
  final int? descender;

  /// Optional manufacturer name.
  final String? manufacturer;

  /// Version string for `name` id 5.
  final String version;

  final List<TtfGlyph> _glyphs = [];
  final Map<int, int> _cmap = {};

  /// Number of glyphs added so far.
  int get glyphCount => _glyphs.length;

  /// Adds an empty glyph (typically `.notdef` at index 0).
  ///
  /// Добавляет пустой глиф (обычно `.notdef` с индексом 0).
  int addEmptyGlyph({int advanceWidth = 0}) {
    _glyphs.add(TtfGlyph.empty(advanceWidth: advanceWidth));
    return _glyphs.length - 1;
  }

  /// Adds [glyph] and optionally maps [codePoint] → its index.
  ///
  /// Добавляет [glyph] и при необходимости маппит [codePoint] → индекс.
  int addGlyph(TtfGlyph glyph, {int? codePoint}) {
    if (glyph.isComposite) {
      throw TtfUnsupportedException(
        'TtfFontBuilder accepts simple glyphs only.',
      );
    }
    final id = _glyphs.length;
    _glyphs.add(glyph);
    if (codePoint != null) {
      if (codePoint < 0) {
        throw ArgumentError.value(codePoint, 'codePoint');
      }
      _cmap[codePoint] = id;
    }
    return id;
  }

  /// Maps [codePoint] to an existing [glyphId].
  ///
  /// Маппит [codePoint] на существующий [glyphId].
  void mapCodePoint(int codePoint, int glyphId) {
    if (glyphId < 0 || glyphId >= _glyphs.length) {
      throw RangeError.index(glyphId, _glyphs, 'glyphId');
    }
    _cmap[codePoint] = glyphId;
  }

  /// Builds a [TtfFont] ready for [TtfFont.toBytes].
  ///
  /// Собирает [TtfFont], готовый к [TtfFont.toBytes].
  TtfFont build() {
    if (_glyphs.isEmpty) {
      throw TtfFormatException('Font needs at least one glyph (.notdef).');
    }

    final upm = unitsPerEm;
    final asc = ascender ?? upm;
    final desc = descender ?? 0;

    var xMin = 0;
    var yMin = 0;
    var xMax = 0;
    var yMax = 0;
    var maxPoints = 0;
    var maxContours = 0;
    var advanceWidthMax = 0;
    var minLsb = 0;
    var minRsb = 0;
    var xMaxExtent = 0;
    var firstChar = 0xFFFF;
    var lastChar = 0;

    final glyfChunks = <Uint8List>[];
    final loca = <int>[0];
    var glyfOffset = 0;

    for (final g in _glyphs) {
      advanceWidthMax = math.max(advanceWidthMax, g.advanceWidth);
      if (!g.isEmpty) {
        xMin = math.min(xMin, g.xMin);
        yMin = math.min(yMin, g.yMin);
        xMax = math.max(xMax, g.xMax);
        yMax = math.max(yMax, g.yMax);
        var points = 0;
        for (final c in g.contours) {
          points += c.points.length;
        }
        maxPoints = math.max(maxPoints, points);
        maxContours = math.max(maxContours, g.contours.length);
        minLsb = math.min(minLsb, g.leftSideBearing);
        final rsb = g.advanceWidth - g.leftSideBearing - (g.xMax - g.xMin);
        minRsb = math.min(minRsb, rsb);
        xMaxExtent =
            math.max(xMaxExtent, g.leftSideBearing + (g.xMax - g.xMin));
      }
      final encoded = g.encodeGlyf();
      glyfChunks.add(encoded);
      glyfOffset += encoded.length;
      // Align each glyph to 2 bytes? Spec says long word alignment recommended
      // for offsets; short loca uses word offsets. We use long loca.
      if (glyfOffset.isOdd) {
        glyfChunks.add(Uint8List(1));
        glyfOffset++;
      }
      loca.add(glyfOffset);
    }

    for (final c in _cmap.keys) {
      firstChar = math.min(firstChar, c);
      lastChar = math.max(lastChar, c);
    }
    if (_cmap.isEmpty) {
      firstChar = 0;
      lastChar = 0;
    }

    final glyfWriter = BinaryWriter();
    glyfChunks.forEach(glyfWriter.writeBytes);
    final glyfBytes = glyfWriter.toBytes();

    final locaWriter = BinaryWriter();
    loca.forEach(locaWriter.writeUint32);
    final locaBytes = locaWriter.toBytes();

    final metrics = [
      for (final g in _glyphs)
        TtfHorizontalMetric(
          advanceWidth: g.advanceWidth,
          leftSideBearing: g.leftSideBearing,
        ),
    ];
    final hmtx = TtfHmtx(metrics);

    final now = _macTime(DateTime.now().toUtc());
    final head = TtfHead(
      unitsPerEm: upm,
      created: now,
      modified: now,
      xMin: xMin,
      yMin: yMin,
      xMax: xMax,
      yMax: yMax,
      indexToLocFormat: 1,
    );

    final hhea = TtfHhea(
      ascender: asc,
      descender: desc,
      advanceWidthMax: advanceWidthMax,
      minLeftSideBearing: minLsb,
      minRightSideBearing: minRsb,
      xMaxExtent: xMaxExtent,
      numberOfHMetrics: _glyphs.length,
    );

    final maxp = TtfMaxp(
      numGlyphs: _glyphs.length,
      maxPoints: maxPoints,
      maxContours: maxContours,
    );

    final name = TtfName.fromFamily(
      family: familyName,
      subfamily: subfamilyName,
      version: version,
      manufacturer: manufacturer,
    );

    final os2 = TtfOs2(
      sTypoAscender: asc,
      sTypoDescender: desc,
      usWinAscent: asc < 0 ? 0 : asc,
      usWinDescent: desc < 0 ? -desc : desc,
      usFirstCharIndex: firstChar & 0xFFFF,
      usLastCharIndex: lastChar & 0xFFFF,
      xAvgCharWidth: advanceWidthMax == 0 ? upm ~/ 2 : advanceWidthMax,
      sxHeight: (asc * 0.5).round(),
      sCapHeight: (asc * 0.7).round(),
    );

    final cmap = TtfCmap(_cmap);
    final post = TtfPost(isFixedPitch: 0);

    final tables = <TtfTableRecord>[
      TtfTableRecord(tag: 'OS/2', bytes: os2.encode()),
      TtfTableRecord(tag: 'cmap', bytes: cmap.encode()),
      TtfTableRecord(tag: 'glyf', bytes: glyfBytes),
      TtfTableRecord(tag: 'head', bytes: head.encode()),
      TtfTableRecord(tag: 'hhea', bytes: hhea.encode()),
      TtfTableRecord(tag: 'hmtx', bytes: hmtx.encode()),
      TtfTableRecord(tag: 'loca', bytes: locaBytes),
      TtfTableRecord(tag: 'maxp', bytes: maxp.encode()),
      TtfTableRecord(tag: 'name', bytes: name.encode()),
      TtfTableRecord(tag: 'post', bytes: post.encode()),
    ];

    return TtfFont(sfntVersion: kSfntTrueType, tables: tables);
  }
}

/// Mac epoch seconds since 1904-01-01 UTC.
int _macTime(DateTime utc) {
  final epoch = DateTime.utc(1904);
  return utc.difference(epoch).inSeconds;
}
