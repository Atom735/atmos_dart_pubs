import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import 'checksum.dart';
import 'cmap.dart';
import 'errors.dart';
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

/// Parsed `sfnt` font: table directory plus helpers for common tables.
///
/// Разобранный шрифт `sfnt`: каталог таблиц и хелперы для частых таблиц.
class TtfFont {
  /// Creates a font from already-decoded [tables].
  ///
  /// Создаёт шрифт из уже разобранных [tables].
  TtfFont({
    required this.sfntVersion,
    required List<TtfTableRecord> tables,
  }) : tables = List<TtfTableRecord>.unmodifiable(
          List<TtfTableRecord>.from(tables)
            ..sort((a, b) => a.tag.compareTo(b.tag)),
        );

  /// Parses [source]. The font keeps its own copy of table payloads.
  ///
  /// Разбирает [source]. Шрифт хранит собственные копии полезных нагрузок.
  factory TtfFont.parse(Uint8List source) {
    final bytes = Uint8List.fromList(source);
    final reader = BinaryReader(bytes);
    final sfntVersion = reader.readUint32();
    final numTables = reader.readUint16();
    reader.skip(6); // searchRange, entrySelector, rangeShift
    final tables = <TtfTableRecord>[];
    for (var i = 0; i < numTables; i++) {
      final tag = reader.readFourCC();
      reader.readUint32(); // checksum
      final offset = reader.readUint32();
      final length = reader.readUint32();
      if (offset < 0 || offset + length > bytes.length) {
        throw TtfFormatException('Table $tag is out of bounds.');
      }
      tables.add(
        TtfTableRecord(
          tag: tag,
          bytes: Uint8List.fromList(
            bytes.sublist(offset, offset + length),
          ),
        ),
      );
    }
    return TtfFont(sfntVersion: sfntVersion, tables: tables);
  }

  /// `sfnt` version (`0x00010000`, `OTTO`, or `true`).
  final int sfntVersion;

  /// Tables sorted by tag.
  final List<TtfTableRecord> tables;

  /// Table tags in directory order (alphabetical).
  List<String> get tableTags => [for (final t in tables) t.tag];

  /// Raw bytes for [tag], or `null` if missing.
  Uint8List? tableBytes(String tag) {
    for (final t in tables) {
      if (t.tag == tag) return t.bytes;
    }
    return null;
  }

  /// Requires table [tag].
  Uint8List requireTable(String tag) {
    final bytes = tableBytes(tag);
    if (bytes == null) {
      throw TtfFormatException('Missing required table $tag.');
    }
    return bytes;
  }

  /// Decoded `head` table.
  TtfHead get head => TtfHead.parse(requireTable('head'));

  /// Decoded `hhea` table.
  TtfHhea get hhea => TtfHhea.parse(requireTable('hhea'));

  /// Decoded `maxp` table.
  TtfMaxp get maxp => TtfMaxp.parse(requireTable('maxp'));

  /// Decoded `hmtx` table.
  TtfHmtx get hmtx {
    final hheaTable = hhea;
    return TtfHmtx.parse(
      requireTable('hmtx'),
      numberOfHMetrics: hheaTable.numberOfHMetrics,
      numGlyphs: maxp.numGlyphs,
    );
  }

  /// Decoded `cmap` table.
  TtfCmap get cmap => TtfCmap.parse(requireTable('cmap'));

  /// Decoded `name` table.
  TtfName get name => TtfName.parse(requireTable('name'));

  /// Decoded `post` table header.
  TtfPost get post => TtfPost.parse(requireTable('post'));

  /// Decoded `OS/2` table when present.
  TtfOs2? get os2 {
    final bytes = tableBytes('OS/2');
    return bytes == null ? null : TtfOs2.parse(bytes);
  }

  /// Whether this font has TrueType `glyf`/`loca` outlines.
  bool get hasTrueTypeOutlines =>
      tableBytes('glyf') != null && tableBytes('loca') != null;

  /// Glyph offsets from `loca` (length = numGlyphs + 1).
  List<int> locaOffsets() {
    final headTable = head;
    final numGlyphs = maxp.numGlyphs;
    final data = requireTable('loca');
    final r = BinaryReader(data);
    if (headTable.isLongLoca) {
      return List<int>.generate(numGlyphs + 1, (_) => r.readUint32());
    }
    return List<int>.generate(numGlyphs + 1, (_) => r.readUint16() * 2);
  }

  /// Returns glyph [glyphId], or `null` if out of range / no `glyf`.
  TtfGlyph? glyph(int glyphId) {
    if (!hasTrueTypeOutlines) return null;
    final numGlyphs = maxp.numGlyphs;
    if (glyphId < 0 || glyphId >= numGlyphs) return null;
    final offsets = locaOffsets();
    final start = offsets[glyphId];
    final end = offsets[glyphId + 1];
    final glyf = requireTable('glyf');
    final slice = start == end
        ? Uint8List(0)
        : Uint8List.fromList(glyf.sublist(start, end));
    final metrics = hmtx.metrics[glyphId];
    return TtfGlyph.parseGlyf(
      slice,
      advanceWidth: metrics.advanceWidth,
      leftSideBearing: metrics.leftSideBearing,
    );
  }

  /// Rebuilds the font file with fresh checksums and padding.
  ///
  /// Пересобирает файл шрифта с актуальными checksum и выравниванием.
  Uint8List toBytes() {
    final sorted = List<TtfTableRecord>.from(tables)
      ..sort((a, b) => a.tag.compareTo(b.tag));

    // Patch head.checksumAdjustment to 0 before computing the file checksum.
    final withHeadZero = <TtfTableRecord>[];
    for (final t in sorted) {
      if (t.tag == 'head') {
        final headTable =
            TtfHead.parse(t.bytes).copyWith(checksumAdjustment: 0);
        withHeadZero.add(
          TtfTableRecord(tag: 'head', bytes: headTable.encode()),
        );
      } else {
        withHeadZero.add(t);
      }
    }

    final numTables = withHeadZero.length;
    var searchRange = 1;
    var entrySelector = 0;
    while (searchRange * 2 <= numTables) {
      searchRange *= 2;
      entrySelector++;
    }
    searchRange *= 16;
    final rangeShift = numTables * 16 - searchRange;

    final offsetTableSize = 12 + numTables * 16;
    var dataOffset = offsetTableSize;
    final offsets = <int>[];
    final checksums = <int>[];
    for (final t in withHeadZero) {
      offsets.add(dataOffset);
      checksums.add(ttfTableChecksum(t.bytes));
      dataOffset += t.paddedLength;
    }

    final writer = BinaryWriter(Endian.big)
      ..writeUint32(sfntVersion == 0 ? kSfntTrueType : sfntVersion)
      ..writeUint16(numTables)
      ..writeUint16(searchRange)
      ..writeUint16(entrySelector)
      ..writeUint16(rangeShift);

    for (var i = 0; i < numTables; i++) {
      final t = withHeadZero[i];
      writer
        ..writeFourCC(t.tag)
        ..writeUint32(checksums[i])
        ..writeUint32(offsets[i])
        ..writeUint32(t.bytes.length);
    }

    for (final t in withHeadZero) {
      writer.writeBytes(t.bytes);
      final pad = t.paddedLength - t.bytes.length;
      for (var i = 0; i < pad; i++) {
        writer.writeUint8(0);
      }
    }

    final fontBytes = writer.toBytes();
    final adjustment =
        (kHeadChecksumMagic - ttfFontChecksum(fontBytes)) & 0xFFFFFFFF;

    // Write checksumAdjustment at head + 8.
    final headOffset = offsets[withHeadZero.indexWhere((t) => t.tag == 'head')];
    final out = Uint8List.fromList(fontBytes);
    ByteData.sublistView(out).setUint32(headOffset + 8, adjustment, Endian.big);
    return out;
  }

  /// Replaces or inserts a table by [tag].
  ///
  /// Заменяет или вставляет таблицу с [tag].
  TtfFont withTable(String tag, Uint8List bytes) {
    final next = <TtfTableRecord>[
      for (final t in tables)
        if (t.tag != tag) t,
      TtfTableRecord(tag: tag, bytes: bytes),
    ];
    return TtfFont(sfntVersion: sfntVersion, tables: next);
  }
}
