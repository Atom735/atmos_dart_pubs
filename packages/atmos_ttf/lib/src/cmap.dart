import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import 'errors.dart';

/// Character-to-glyph map from the `cmap` table.
///
/// Карта символ→глиф из таблицы `cmap`.
class TtfCmap {
  /// Creates a cmap from [mappings] (code point → glyph id).
  ///
  /// Создаёт cmap из [mappings] (кодпоинт → id глифа).
  TtfCmap(Map<int, int> mappings)
      : mappings = Map<int, int>.unmodifiable(mappings);

  /// Parses a `cmap` table, preferring Unicode BMP (platform 3/1 or 0).
  ///
  /// Разбирает таблицу `cmap`, предпочитая Unicode BMP (platform 3/1 или 0).
  factory TtfCmap.parse(Uint8List data) {
    final reader = BinaryReader(data);
    reader.skip(2); // version
    final numTables = reader.readUint16();
    final encodingRecords = <_CmapRecord>[];
    for (var i = 0; i < numTables; i++) {
      encodingRecords.add(
        _CmapRecord(
          platformId: reader.readUint16(),
          encodingId: reader.readUint16(),
          offset: reader.readUint32(),
        ),
      );
    }
    encodingRecords.sort(_preferUnicode);
    for (final record in encodingRecords) {
      reader.offset = record.offset;
      final format = reader.readUint16();
      if (format == 4) {
        return TtfCmap(_parseFormat4(reader));
      }
      if (format == 12) {
        reader.skip(2); // reserved
        return TtfCmap(_parseFormat12(reader));
      }
    }
    throw TtfUnsupportedException(
      'No supported cmap subtable (need format 4 or 12).',
    );
  }

  /// Code point → glyph index.
  ///
  /// Кодпоинт → индекс глифа.
  final Map<int, int> mappings;

  /// Looks up [codePoint], or `0` (`.notdef`) when missing.
  ///
  /// Ищет [codePoint], или `0` (`.notdef`) если нет.
  int glyphFor(int codePoint) => mappings[codePoint] ?? 0;

  /// Encodes a Windows Unicode BMP `cmap` (platform 3, encoding 1, format 4)
  /// plus a format 12 subtable when any code point is above `0xFFFF`.
  ///
  /// Кодирует Windows Unicode BMP `cmap` (platform 3, encoding 1, format 4)
  /// и format 12, если есть кодпоинты выше `0xFFFF`.
  Uint8List encode() {
    final bmp = <int, int>{};
    final all = Map<int, int>.from(mappings);
    for (final e in all.entries) {
      if (e.key <= 0xFFFF) bmp[e.key] = e.value;
    }
    final format4 = _encodeFormat4(bmp);
    final need12 = all.keys.any((c) => c > 0xFFFF);
    final format12 = need12 ? _encodeFormat12(all) : null;

    final writer = BinaryWriter()
      ..writeUint16(0) // version
      ..writeUint16(need12 ? 2 : 1);

    // Offsets relative to start of cmap.
    const headerSize = 4;
    final recordSize = need12 ? 16 : 8;
    final offset4 = headerSize + recordSize;
    writer
      ..writeUint16(3) // Windows
      ..writeUint16(1) // Unicode BMP
      ..writeUint32(offset4);
    if (need12) {
      writer
        ..writeUint16(3)
        ..writeUint16(10) // Unicode full
        ..writeUint32(offset4 + format4.length);
    }
    writer.writeBytes(format4);
    if (format12 != null) writer.writeBytes(format12);
    return writer.toBytes();
  }
}

class _CmapRecord {
  _CmapRecord({
    required this.platformId,
    required this.encodingId,
    required this.offset,
  });

  final int platformId;
  final int encodingId;
  final int offset;
}

int _preferUnicode(_CmapRecord a, _CmapRecord b) {
  int score(_CmapRecord r) {
    if (r.platformId == 0) return 0;
    if (r.platformId == 3 && (r.encodingId == 1 || r.encodingId == 10)) {
      return 1;
    }
    if (r.platformId == 3) return 2;
    return 3;
  }

  return score(a).compareTo(score(b));
}

Map<int, int> _parseFormat4(BinaryReader reader) {
  // length already consumed format; continue from length field
  reader.readUint16(); // length
  reader.readUint16(); // language
  final segCountX2 = reader.readUint16();
  final segCount = segCountX2 ~/ 2;
  reader.skip(6); // searchRange, entrySelector, rangeShift
  final endCode = List<int>.generate(segCount, (_) => reader.readUint16());
  reader.readUint16(); // reservedPad
  final startCode = List<int>.generate(segCount, (_) => reader.readUint16());
  final idDelta = List<int>.generate(segCount, (_) => reader.readInt16());
  final idRangeOffsetPos = reader.offset;
  final idRangeOffset =
      List<int>.generate(segCount, (_) => reader.readUint16());
  final map = <int, int>{};
  for (var i = 0; i < segCount; i++) {
    final start = startCode[i];
    final end = endCode[i];
    if (start == 0xFFFF && end == 0xFFFF) continue;
    final rangeOffset = idRangeOffset[i];
    for (var c = start; c <= end; c++) {
      int glyphId;
      if (rangeOffset == 0) {
        glyphId = (c + idDelta[i]) & 0xFFFF;
      } else {
        final offset = idRangeOffsetPos +
            i * 2 +
            rangeOffset +
            (c - start) * 2;
        reader.offset = offset;
        glyphId = reader.readUint16();
        if (glyphId != 0) {
          glyphId = (glyphId + idDelta[i]) & 0xFFFF;
        }
      }
      if (glyphId != 0) map[c] = glyphId;
    }
  }
  return map;
}

Map<int, int> _parseFormat12(BinaryReader reader) {
  reader.readUint32(); // length
  reader.readUint32(); // language
  final nGroups = reader.readUint32();
  final map = <int, int>{};
  for (var i = 0; i < nGroups; i++) {
    final start = reader.readUint32();
    final end = reader.readUint32();
    var glyph = reader.readUint32();
    for (var c = start; c <= end; c++) {
      map[c] = glyph++;
    }
  }
  return map;
}

/// `idDelta` as signed int16 such that `(code + delta) & 0xFFFF == glyphId`.
int _idDelta(int glyphId, int codePoint) {
  var d = glyphId - codePoint;
  if (d > 32767) d -= 65536;
  if (d < -32768) d += 65536;
  return d;
}

Uint8List _encodeFormat4(Map<int, int> mappings) {
  final codes = mappings.keys.toList()..sort();
  // Build contiguous segments.
  final starts = <int>[];
  final ends = <int>[];
  final deltas = <int>[];
  if (codes.isNotEmpty) {
    var segStart = codes.first;
    var prev = codes.first;
    var prevGlyph = mappings[codes.first]!;
    for (var i = 1; i < codes.length; i++) {
      final c = codes[i];
      final g = mappings[c]!;
      if (c == prev + 1 && g == prevGlyph + 1) {
        prev = c;
        prevGlyph = g;
        continue;
      }
      starts.add(segStart);
      ends.add(prev);
      deltas.add(_idDelta(mappings[segStart]!, segStart));
      segStart = c;
      prev = c;
      prevGlyph = g;
    }
    starts.add(segStart);
    ends.add(prev);
    deltas.add(_idDelta(mappings[segStart]!, segStart));
  }
  // Required terminator segment.
  starts.add(0xFFFF);
  ends.add(0xFFFF);
  deltas.add(1);

  final segCount = starts.length;
  final segCountX2 = segCount * 2;
  var searchRange = 2;
  var entrySelector = 0;
  while (searchRange * 2 <= segCountX2) {
    searchRange *= 2;
    entrySelector++;
  }
  final rangeShift = segCountX2 - searchRange;

  final writer = BinaryWriter()
    ..writeUint16(4)
    ..writeUint16(0) // length placeholder
    ..writeUint16(0) // language
    ..writeUint16(segCountX2)
    ..writeUint16(searchRange)
    ..writeUint16(entrySelector)
    ..writeUint16(rangeShift);
  ends.forEach(writer.writeUint16);
  writer.writeUint16(0); // reservedPad
  starts.forEach(writer.writeUint16);
  deltas.forEach(writer.writeInt16);
  for (var i = 0; i < segCount; i++) {
    writer.writeUint16(0); // idRangeOffset — deltas only
  }
  final bytes = writer.toBytes();
  final out = Uint8List.fromList(bytes);
  ByteData.sublistView(out).setUint16(2, out.length, Endian.big);
  return out;
}

Uint8List _encodeFormat12(Map<int, int> mappings) {
  final codes = mappings.keys.toList()..sort();
  final groups = <List<int>>[]; // start, end, startGlyph
  if (codes.isNotEmpty) {
    var start = codes.first;
    var prev = codes.first;
    var startGlyph = mappings[codes.first]!;
    var prevGlyph = startGlyph;
    for (var i = 1; i < codes.length; i++) {
      final c = codes[i];
      final g = mappings[c]!;
      if (c == prev + 1 && g == prevGlyph + 1) {
        prev = c;
        prevGlyph = g;
        continue;
      }
      groups.add([start, prev, startGlyph]);
      start = c;
      prev = c;
      startGlyph = g;
      prevGlyph = g;
    }
    groups.add([start, prev, startGlyph]);
  }
  final length = 16 + groups.length * 12;
  final writer = BinaryWriter()
    ..writeUint16(12)
    ..writeUint16(0) // reserved
    ..writeUint32(length)
    ..writeUint32(0) // language
    ..writeUint32(groups.length);
  for (final g in groups) {
    writer
      ..writeUint32(g[0])
      ..writeUint32(g[1])
      ..writeUint32(g[2]);
  }
  return writer.toBytes();
}
