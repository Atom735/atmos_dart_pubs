import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../errors.dart';

/// Horizontal header table (`hhea`).
///
/// Таблица горизонтального заголовка (`hhea`).
class TtfHhea {
  /// Creates an `hhea` table.
  ///
  /// Создаёт таблицу `hhea`.
  TtfHhea({
    this.majorVersion = 1,
    this.minorVersion = 0,
    required this.ascender,
    required this.descender,
    this.lineGap = 0,
    required this.advanceWidthMax,
    this.minLeftSideBearing = 0,
    this.minRightSideBearing = 0,
    required this.xMaxExtent,
    this.caretSlopeRise = 1,
    this.caretSlopeRun = 0,
    this.caretOffset = 0,
    this.metricDataFormat = 0,
    required this.numberOfHMetrics,
  });

  /// Parses an `hhea` table.
  ///
  /// Разбирает таблицу `hhea`.
  factory TtfHhea.parse(Uint8List data) {
    if (data.length < 36) {
      throw TtfFormatException('hhea table is too short.');
    }
    final r = BinaryReader(data);
    return TtfHhea(
      majorVersion: r.readUint16(),
      minorVersion: r.readUint16(),
      ascender: r.readInt16(),
      descender: r.readInt16(),
      lineGap: r.readInt16(),
      advanceWidthMax: r.readUint16(),
      minLeftSideBearing: r.readInt16(),
      minRightSideBearing: r.readInt16(),
      xMaxExtent: r.readInt16(),
      caretSlopeRise: r.readInt16(),
      caretSlopeRun: r.readInt16(),
      caretOffset: r.readInt16(),
      // 4 reserved int16
      metricDataFormat: () {
        r.skip(8);
        return r.readInt16();
      }(),
      numberOfHMetrics: r.readUint16(),
    );
  }

  /// Major version.
  final int majorVersion;

  /// Minor version.
  final int minorVersion;

  /// Ascender.
  final int ascender;

  /// Descender (typically negative).
  final int descender;

  /// Line gap.
  final int lineGap;

  /// Maximum advance width.
  final int advanceWidthMax;

  /// Minimum left side bearing.
  final int minLeftSideBearing;

  /// Minimum right side bearing.
  final int minRightSideBearing;

  /// Maximum extent `lsb + (xMax-xMin)`.
  final int xMaxExtent;

  /// Caret slope rise.
  final int caretSlopeRise;

  /// Caret slope run.
  final int caretSlopeRun;

  /// Caret offset.
  final int caretOffset;

  /// Metric data format (0).
  final int metricDataFormat;

  /// Number of long horizontal metrics in `hmtx`.
  final int numberOfHMetrics;

  /// Encodes the table.
  ///
  /// Кодирует таблицу.
  Uint8List encode() {
    final w = BinaryWriter()
      ..writeUint16(majorVersion)
      ..writeUint16(minorVersion)
      ..writeInt16(ascender)
      ..writeInt16(descender)
      ..writeInt16(lineGap)
      ..writeUint16(advanceWidthMax)
      ..writeInt16(minLeftSideBearing)
      ..writeInt16(minRightSideBearing)
      ..writeInt16(xMaxExtent)
      ..writeInt16(caretSlopeRise)
      ..writeInt16(caretSlopeRun)
      ..writeInt16(caretOffset)
      ..writeInt16(0)
      ..writeInt16(0)
      ..writeInt16(0)
      ..writeInt16(0)
      ..writeInt16(metricDataFormat)
      ..writeUint16(numberOfHMetrics);
    return w.toBytes();
  }
}
