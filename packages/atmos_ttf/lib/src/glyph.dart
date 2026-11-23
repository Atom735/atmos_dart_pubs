import 'dart:math' as math;
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import 'errors.dart';
import 'point.dart';

/// Flag: point is on the curve.
const int kGlyfOnCurve = 0x01;

/// Flag: x is 1 byte.
const int kGlyfXShort = 0x02;

/// Flag: y is 1 byte.
const int kGlyfYShort = 0x04;

/// Flag: next byte is a repeat count for this flag.
const int kGlyfRepeat = 0x08;

/// Flag: x is same as previous (or positive if [kGlyfXShort]).
const int kGlyfXSameOrPositive = 0x10;

/// Flag: y is same as previous (or positive if [kGlyfYShort]).
const int kGlyfYSameOrPositive = 0x20;

/// One glyph: empty, simple contours, or opaque composite / raw bytes.
///
/// Один глиф: пустой, простые контуры или непрозрачные составные / сырые байты.
class TtfGlyph {
  TtfGlyph._({
    required this.advanceWidth,
    required this.leftSideBearing,
    required this.contours,
    required this.rawGlyf,
    required this.numberOfContours,
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });

  /// Empty `.notdef`-style glyph (no contours).
  ///
  /// Пустой глиф в стиле `.notdef` (без контуров).
  factory TtfGlyph.empty({
    int advanceWidth = 0,
    int leftSideBearing = 0,
  }) =>
      TtfGlyph._(
        advanceWidth: advanceWidth,
        leftSideBearing: leftSideBearing,
        contours: const [],
        rawGlyf: null,
        numberOfContours: 0,
        xMin: 0,
        yMin: 0,
        xMax: 0,
        yMax: 0,
      );

  /// Simple glyph from [contours]. Bounding box is computed.
  ///
  /// Простой глиф из [contours]. Bounding box вычисляется.
  factory TtfGlyph.simple({
    required List<TtfContour> contours,
    int advanceWidth = 1000,
    int leftSideBearing = 0,
  }) {
    if (contours.isEmpty) {
      return TtfGlyph.empty(
        advanceWidth: advanceWidth,
        leftSideBearing: leftSideBearing,
      );
    }
    var xMin = 0x7FFF;
    var yMin = 0x7FFF;
    var xMax = -0x8000;
    var yMax = -0x8000;
    for (final contour in contours) {
      for (final p in contour.points) {
        xMin = math.min(xMin, p.x);
        yMin = math.min(yMin, p.y);
        xMax = math.max(xMax, p.x);
        yMax = math.max(yMax, p.y);
      }
    }
    return TtfGlyph._(
      advanceWidth: advanceWidth,
      leftSideBearing: leftSideBearing,
      contours: List<TtfContour>.unmodifiable(contours),
      rawGlyf: null,
      numberOfContours: contours.length,
      xMin: xMin,
      yMin: yMin,
      xMax: xMax,
      yMax: yMax,
    );
  }

  /// Parses a `glyf` entry. Composite glyphs keep [rawGlyf] only.
  ///
  /// Разбирает запись `glyf`. Составные глифы сохраняют только [rawGlyf].
  factory TtfGlyph.parseGlyf(
    Uint8List data, {
    int advanceWidth = 0,
    int leftSideBearing = 0,
  }) {
    if (data.isEmpty) {
      return TtfGlyph.empty(
        advanceWidth: advanceWidth,
        leftSideBearing: leftSideBearing,
      );
    }
    final reader = BinaryReader(data);
    final nContours = reader.readInt16();
    final xMin = reader.readInt16();
    final yMin = reader.readInt16();
    final xMax = reader.readInt16();
    final yMax = reader.readInt16();
    if (nContours < 0) {
      return TtfGlyph._(
        advanceWidth: advanceWidth,
        leftSideBearing: leftSideBearing,
        contours: const [],
        rawGlyf: Uint8List.fromList(data),
        numberOfContours: nContours,
        xMin: xMin,
        yMin: yMin,
        xMax: xMax,
        yMax: yMax,
      );
    }
    if (nContours == 0) {
      return TtfGlyph.empty(
        advanceWidth: advanceWidth,
        leftSideBearing: leftSideBearing,
      );
    }
    final endPts = List<int>.generate(nContours, (_) => reader.readUint16());
    final instrLen = reader.readUint16();
    reader.skip(instrLen);
    final nPoints = endPts.last + 1;
    final flags = <int>[];
    while (flags.length < nPoints) {
      final flag = reader.readUint8();
      flags.add(flag);
      if ((flag & kGlyfRepeat) != 0) {
        final repeat = reader.readUint8();
        for (var i = 0; i < repeat; i++) {
          flags.add(flag);
        }
      }
    }
    if (flags.length != nPoints) {
      throw TtfFormatException('glyf flag count mismatch.');
    }
    final xs = List<int>.filled(nPoints, 0);
    var x = 0;
    for (var i = 0; i < nPoints; i++) {
      final flag = flags[i];
      if ((flag & kGlyfXShort) != 0) {
        final dx = reader.readUint8();
        x += (flag & kGlyfXSameOrPositive) != 0 ? dx : -dx;
      } else if ((flag & kGlyfXSameOrPositive) == 0) {
        x += reader.readInt16();
      }
      xs[i] = x;
    }
    final ys = List<int>.filled(nPoints, 0);
    var y = 0;
    for (var i = 0; i < nPoints; i++) {
      final flag = flags[i];
      if ((flag & kGlyfYShort) != 0) {
        final dy = reader.readUint8();
        y += (flag & kGlyfYSameOrPositive) != 0 ? dy : -dy;
      } else if ((flag & kGlyfYSameOrPositive) == 0) {
        y += reader.readInt16();
      }
      ys[i] = y;
    }
    final contours = <TtfContour>[];
    var start = 0;
    for (final end in endPts) {
      final points = <TtfPoint>[];
      for (var i = start; i <= end; i++) {
        points.add(
          TtfPoint(
            xs[i],
            ys[i],
            onCurve: (flags[i] & kGlyfOnCurve) != 0,
          ),
        );
      }
      contours.add(TtfContour(points));
      start = end + 1;
    }
    return TtfGlyph._(
      advanceWidth: advanceWidth,
      leftSideBearing: leftSideBearing,
      contours: List<TtfContour>.unmodifiable(contours),
      rawGlyf: null,
      numberOfContours: nContours,
      xMin: xMin,
      yMin: yMin,
      xMax: xMax,
      yMax: yMax,
    );
  }

  /// Advance width from `hmtx`.
  ///
  /// Ширина продвижения из `hmtx`.
  final int advanceWidth;

  /// Left side bearing from `hmtx`.
  ///
  /// Левый side bearing из `hmtx`.
  final int leftSideBearing;

  /// Decoded simple contours; empty for empty / composite glyphs.
  ///
  /// Декодированные простые контуры; пусто для пустых / составных глифов.
  final List<TtfContour> contours;

  /// Opaque `glyf` payload for composite glyphs; otherwise `null`.
  ///
  /// Непрозрачная нагрузка `glyf` для составных глифов; иначе `null`.
  final Uint8List? rawGlyf;

  /// `numberOfContours` from the glyf header (`< 0` = composite).
  ///
  /// `numberOfContours` из заголовка glyf (`< 0` = составной).
  final int numberOfContours;

  /// Glyph bounding box.
  final int xMin;

  /// Glyph bounding box.
  final int yMin;

  /// Glyph bounding box.
  final int xMax;

  /// Glyph bounding box.
  final int yMax;

  /// Whether this is a composite glyph (raw bytes only).
  ///
  /// Является ли глиф составным (только сырые байты).
  bool get isComposite => numberOfContours < 0;

  /// Whether the glyph has no outline.
  ///
  /// Есть ли у глифа контур.
  bool get isEmpty =>
      !isComposite && contours.isEmpty && (rawGlyf == null || rawGlyf!.isEmpty);

  /// Encodes the `glyf` entry (without `hmtx` metrics).
  ///
  /// Кодирует запись `glyf` (без метрик `hmtx`).
  Uint8List encodeGlyf() {
    if (rawGlyf != null) return Uint8List.fromList(rawGlyf!);
    if (contours.isEmpty) return Uint8List(0);

    final writer = BinaryWriter()
      ..writeInt16(contours.length)
      ..writeInt16(xMin)
      ..writeInt16(yMin)
      ..writeInt16(xMax)
      ..writeInt16(yMax);

    var pointCount = -1;
    for (final contour in contours) {
      pointCount += contour.points.length;
      writer.writeUint16(pointCount);
    }
    writer.writeUint16(0); // no instructions

    final allPoints = <TtfPoint>[
      for (final c in contours) ...c.points,
    ];
    final flags = <int>[];
    var prevX = 0;
    var prevY = 0;
    final dxs = <int>[];
    final dys = <int>[];
    for (final p in allPoints) {
      final dx = p.x - prevX;
      final dy = p.y - prevY;
      dxs.add(dx);
      dys.add(dy);
      var flag = p.onCurve ? kGlyfOnCurve : 0;
      if (dx == 0) {
        flag |= kGlyfXSameOrPositive;
      } else if (dx >= -255 && dx <= 255) {
        flag |= kGlyfXShort;
        if (dx > 0) flag |= kGlyfXSameOrPositive;
      }
      if (dy == 0) {
        flag |= kGlyfYSameOrPositive;
      } else if (dy >= -255 && dy <= 255) {
        flag |= kGlyfYShort;
        if (dy > 0) flag |= kGlyfYSameOrPositive;
      }
      flags.add(flag);
      prevX = p.x;
      prevY = p.y;
    }

    for (var i = 0; i < flags.length;) {
      final flag = flags[i];
      var repeat = 0;
      while (i + 1 + repeat < flags.length &&
          flags[i + 1 + repeat] == flag &&
          repeat < 255) {
        repeat++;
      }
      if (repeat > 0) {
        writer.writeUint8(flag | kGlyfRepeat);
        writer.writeUint8(repeat);
        i += 1 + repeat;
      } else {
        writer.writeUint8(flag);
        i++;
      }
    }

    for (var i = 0; i < flags.length; i++) {
      final flag = flags[i];
      final dx = dxs[i];
      if ((flag & kGlyfXShort) != 0) {
        writer.writeUint8(dx.abs());
      } else if ((flag & kGlyfXSameOrPositive) == 0) {
        writer.writeInt16(dx);
      }
    }
    for (var i = 0; i < flags.length; i++) {
      final flag = flags[i];
      final dy = dys[i];
      if ((flag & kGlyfYShort) != 0) {
        writer.writeUint8(dy.abs());
      } else if ((flag & kGlyfYSameOrPositive) == 0) {
        writer.writeInt16(dy);
      }
    }

    return writer.toBytes();
  }
}
