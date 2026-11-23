import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

/// PostScript table (`post`) — header fields used by icon fonts.
///
/// Таблица PostScript (`post`) — поля заголовка для иконочных шрифтов.
class TtfPost {
  /// Creates a `post` table.
  ///
  /// Создаёт таблицу `post`.
  TtfPost({
    this.version = 0x00030000,
    this.italicAngle = 0,
    this.underlinePosition = 0,
    this.underlineThickness = 0,
    this.isFixedPitch = 0,
    this.minMemType42 = 0,
    this.maxMemType42 = 0,
    this.minMemType1 = 0,
    this.maxMemType1 = 0,
  });

  /// Parses a `post` table header (format 3 has no names).
  ///
  /// Разбирает заголовок `post` (format 3 без имён).
  factory TtfPost.parse(Uint8List data) {
    final r = BinaryReader(data);
    return TtfPost(
      version: r.readUint32(),
      italicAngle: r.readInt32(),
      underlinePosition: r.readInt16(),
      underlineThickness: r.readInt16(),
      isFixedPitch: r.readUint32(),
      minMemType42: r.readUint32(),
      maxMemType42: r.readUint32(),
      minMemType1: r.readUint32(),
      maxMemType1: r.readUint32(),
    );
  }

  /// Version Fixed (`0x00030000` = no glyph names).
  final int version;

  /// Italic angle as Fixed 16.16.
  final int italicAngle;

  /// Underline position.
  final int underlinePosition;

  /// Underline thickness.
  final int underlineThickness;

  /// Non-zero if monospaced.
  final int isFixedPitch;

  /// Memory Type 42 min.
  final int minMemType42;

  /// Memory Type 42 max.
  final int maxMemType42;

  /// Memory Type 1 min.
  final int minMemType1;

  /// Memory Type 1 max.
  final int maxMemType1;

  /// Encodes a format-3 `post` table (header only).
  ///
  /// Кодирует `post` format 3 (только заголовок).
  Uint8List encode() {
    final w = BinaryWriter()
      ..writeUint32(version)
      ..writeInt32(italicAngle)
      ..writeInt16(underlinePosition)
      ..writeInt16(underlineThickness)
      ..writeUint32(isFixedPitch)
      ..writeUint32(minMemType42)
      ..writeUint32(maxMemType42)
      ..writeUint32(minMemType1)
      ..writeUint32(maxMemType1);
    return w.toBytes();
  }
}
