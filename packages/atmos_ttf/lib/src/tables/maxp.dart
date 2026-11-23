import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../errors.dart';

/// Maximum profile table (`maxp`).
///
/// Таблица профиля максимумов (`maxp`).
class TtfMaxp {
  /// Creates a `maxp` table. Version `0x00010000` includes TrueType fields.
  ///
  /// Создаёт таблицу `maxp`. Версия `0x00010000` включает поля TrueType.
  TtfMaxp({
    this.version = 0x00010000,
    required this.numGlyphs,
    this.maxPoints = 0,
    this.maxContours = 0,
    this.maxCompositePoints = 0,
    this.maxCompositeContours = 0,
    this.maxZones = 2,
    this.maxTwilightPoints = 0,
    this.maxStorage = 0,
    this.maxFunctionDefs = 0,
    this.maxInstructionDefs = 0,
    this.maxStackElements = 0,
    this.maxSizeOfInstructions = 0,
    this.maxComponentElements = 0,
    this.maxComponentDepth = 0,
  });

  /// Parses a `maxp` table.
  ///
  /// Разбирает таблицу `maxp`.
  factory TtfMaxp.parse(Uint8List data) {
    if (data.length < 6) {
      throw TtfFormatException('maxp table is too short.');
    }
    final r = BinaryReader(data);
    final version = r.readUint32();
    final numGlyphs = r.readUint16();
    if (version == 0x00005000 || data.length < 32) {
      return TtfMaxp(version: version, numGlyphs: numGlyphs);
    }
    return TtfMaxp(
      version: version,
      numGlyphs: numGlyphs,
      maxPoints: r.readUint16(),
      maxContours: r.readUint16(),
      maxCompositePoints: r.readUint16(),
      maxCompositeContours: r.readUint16(),
      maxZones: r.readUint16(),
      maxTwilightPoints: r.readUint16(),
      maxStorage: r.readUint16(),
      maxFunctionDefs: r.readUint16(),
      maxInstructionDefs: r.readUint16(),
      maxStackElements: r.readUint16(),
      maxSizeOfInstructions: r.readUint16(),
      maxComponentElements: r.readUint16(),
      maxComponentDepth: r.readUint16(),
    );
  }

  /// Table version Fixed.
  final int version;

  /// Number of glyphs.
  final int numGlyphs;

  /// Max points in a non-composite glyph.
  final int maxPoints;

  /// Max contours in a non-composite glyph.
  final int maxContours;

  /// Max points in a composite glyph.
  final int maxCompositePoints;

  /// Max contours in a composite glyph.
  final int maxCompositeContours;

  /// Max zones.
  final int maxZones;

  /// Max twilight points.
  final int maxTwilightPoints;

  /// Max storage area locations.
  final int maxStorage;

  /// Max function defs.
  final int maxFunctionDefs;

  /// Max instruction defs.
  final int maxInstructionDefs;

  /// Max stack elements.
  final int maxStackElements;

  /// Max size of glyph instructions.
  final int maxSizeOfInstructions;

  /// Max component elements.
  final int maxComponentElements;

  /// Max component depth.
  final int maxComponentDepth;

  /// Encodes the table.
  ///
  /// Кодирует таблицу.
  Uint8List encode() {
    final w = BinaryWriter()
      ..writeUint32(version)
      ..writeUint16(numGlyphs);
    if (version >= 0x00010000) {
      w
        ..writeUint16(maxPoints)
        ..writeUint16(maxContours)
        ..writeUint16(maxCompositePoints)
        ..writeUint16(maxCompositeContours)
        ..writeUint16(maxZones)
        ..writeUint16(maxTwilightPoints)
        ..writeUint16(maxStorage)
        ..writeUint16(maxFunctionDefs)
        ..writeUint16(maxInstructionDefs)
        ..writeUint16(maxStackElements)
        ..writeUint16(maxSizeOfInstructions)
        ..writeUint16(maxComponentElements)
        ..writeUint16(maxComponentDepth);
    }
    return w.toBytes();
  }
}
