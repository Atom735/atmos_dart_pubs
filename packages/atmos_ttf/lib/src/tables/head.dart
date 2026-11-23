import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../errors.dart';

/// Font header table (`head`).
///
/// Таблица заголовка шрифта (`head`).
class TtfHead {
  /// Creates a `head` table.
  ///
  /// Создаёт таблицу `head`.
  TtfHead({
    this.majorVersion = 1,
    this.minorVersion = 0,
    this.fontRevision = 0x00010000,
    this.checksumAdjustment = 0,
    this.magicNumber = 0x5F0F3CF5,
    this.flags = 0,
    required this.unitsPerEm,
    required this.created,
    required this.modified,
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
    this.macStyle = 0,
    this.lowestRecPPEM = 8,
    this.fontDirectionHint = 2,
    this.indexToLocFormat = 1,
    this.glyphDataFormat = 0,
  });

  /// Parses a `head` table.
  ///
  /// Разбирает таблицу `head`.
  factory TtfHead.parse(Uint8List data) {
    if (data.length < 54) {
      throw TtfFormatException('head table is too short.');
    }
    final r = BinaryReader(data);
    return TtfHead(
      majorVersion: r.readUint16(),
      minorVersion: r.readUint16(),
      fontRevision: r.readUint32(),
      checksumAdjustment: r.readUint32(),
      magicNumber: r.readUint32(),
      flags: r.readUint16(),
      unitsPerEm: r.readUint16(),
      created: r.readInt64(),
      modified: r.readInt64(),
      xMin: r.readInt16(),
      yMin: r.readInt16(),
      xMax: r.readInt16(),
      yMax: r.readInt16(),
      macStyle: r.readUint16(),
      lowestRecPPEM: r.readUint16(),
      fontDirectionHint: r.readInt16(),
      indexToLocFormat: r.readInt16(),
      glyphDataFormat: r.readInt16(),
    );
  }

  /// Major version (usually 1).
  final int majorVersion;

  /// Minor version (usually 0).
  final int minorVersion;

  /// Font revision as Fixed 16.16.
  final int fontRevision;

  /// Checksum adjustment field.
  final int checksumAdjustment;

  /// Must be `0x5F0F3CF5`.
  final int magicNumber;

  /// Head flags.
  final int flags;

  /// Units per em (typically 1000 or 2048).
  final int unitsPerEm;

  /// Creation time (seconds since 1904-01-01).
  final int created;

  /// Modification time (seconds since 1904-01-01).
  final int modified;

  /// Font bounding box.
  final int xMin;

  /// Font bounding box.
  final int yMin;

  /// Font bounding box.
  final int xMax;

  /// Font bounding box.
  final int yMax;

  /// Mac style bits.
  final int macStyle;

  /// Smallest readable size in pixels.
  final int lowestRecPPEM;

  /// Font direction hint.
  final int fontDirectionHint;

  /// `0` = short `loca`, `1` = long `loca`.
  final int indexToLocFormat;

  /// Glyph data format (0).
  final int glyphDataFormat;

  /// Whether `loca` uses 32-bit offsets.
  bool get isLongLoca => indexToLocFormat == 1;

  /// Encodes the table. [checksumAdjustment] is written as given.
  ///
  /// Кодирует таблицу. [checksumAdjustment] пишется как есть.
  Uint8List encode({int? checksumAdjustment}) {
    final adj = checksumAdjustment ?? this.checksumAdjustment;
    final w = BinaryWriter()
      ..writeUint16(majorVersion)
      ..writeUint16(minorVersion)
      ..writeUint32(fontRevision)
      ..writeUint32(adj)
      ..writeUint32(magicNumber)
      ..writeUint16(flags)
      ..writeUint16(unitsPerEm)
      ..writeInt64(created)
      ..writeInt64(modified)
      ..writeInt16(xMin)
      ..writeInt16(yMin)
      ..writeInt16(xMax)
      ..writeInt16(yMax)
      ..writeUint16(macStyle)
      ..writeUint16(lowestRecPPEM)
      ..writeInt16(fontDirectionHint)
      ..writeInt16(indexToLocFormat)
      ..writeInt16(glyphDataFormat);
    return w.toBytes();
  }

  /// Copy with selected fields replaced.
  ///
  /// Копия с заменой выбранных полей.
  TtfHead copyWith({
    int? checksumAdjustment,
    int? xMin,
    int? yMin,
    int? xMax,
    int? yMax,
    int? indexToLocFormat,
    int? modified,
  }) =>
      TtfHead(
        majorVersion: majorVersion,
        minorVersion: minorVersion,
        fontRevision: fontRevision,
        checksumAdjustment: checksumAdjustment ?? this.checksumAdjustment,
        magicNumber: magicNumber,
        flags: flags,
        unitsPerEm: unitsPerEm,
        created: created,
        modified: modified ?? this.modified,
        xMin: xMin ?? this.xMin,
        yMin: yMin ?? this.yMin,
        xMax: xMax ?? this.xMax,
        yMax: yMax ?? this.yMax,
        macStyle: macStyle,
        lowestRecPPEM: lowestRecPPEM,
        fontDirectionHint: fontDirectionHint,
        indexToLocFormat: indexToLocFormat ?? this.indexToLocFormat,
        glyphDataFormat: glyphDataFormat,
      );
}
