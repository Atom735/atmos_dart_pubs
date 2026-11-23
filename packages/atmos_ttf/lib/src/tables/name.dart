import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

/// One `name` table record.
///
/// Одна запись таблицы `name`.
class TtfNameRecord {
  /// Creates a name record.
  ///
  /// Создаёт запись имени.
  TtfNameRecord({
    required this.platformId,
    required this.encodingId,
    required this.languageId,
    required this.nameId,
    required this.value,
  });

  /// Platform id (0 = Unicode, 1 = Mac, 3 = Windows).
  final int platformId;

  /// Encoding id.
  final int encodingId;

  /// Language id.
  final int languageId;

  /// Name id (1 = family, 2 = subfamily, 4 = full, 6 = PostScript, …).
  final int nameId;

  /// Decoded string value.
  final String value;
}

/// Naming table (`name`).
///
/// Таблица имён (`name`).
class TtfName {
  /// Creates a `name` table.
  ///
  /// Создаёт таблицу `name`.
  TtfName(List<TtfNameRecord> records)
      : records = List<TtfNameRecord>.unmodifiable(records);

  /// Parses a `name` table (format 0).
  ///
  /// Разбирает таблицу `name` (format 0).
  factory TtfName.parse(Uint8List data) {
    final r = BinaryReader(data);
    final format = r.readUint16();
    final count = r.readUint16();
    final stringOffset = r.readUint16();
    final records = <TtfNameRecord>[];
    final headers = <_NameHeader>[];
    for (var i = 0; i < count; i++) {
      headers.add(
        _NameHeader(
          platformId: r.readUint16(),
          encodingId: r.readUint16(),
          languageId: r.readUint16(),
          nameId: r.readUint16(),
          length: r.readUint16(),
          offset: r.readUint16(),
        ),
      );
    }
    // format 1 lang tags ignored
    if (format > 1) {
      // still try to decode format 0 layout
    }
    for (final h in headers) {
      final start = stringOffset + h.offset;
      final bytes = data.sublist(start, start + h.length);
      final value = _decodeName(h.platformId, h.encodingId, bytes);
      records.add(
        TtfNameRecord(
          platformId: h.platformId,
          encodingId: h.encodingId,
          languageId: h.languageId,
          nameId: h.nameId,
          value: value,
        ),
      );
    }
    return TtfName(records);
  }

  /// Builds a Windows Unicode `name` table from common strings.
  ///
  /// Собирает Windows Unicode таблицу `name` из обычных строк.
  factory TtfName.fromFamily({
    required String family,
    String subfamily = 'Regular',
    String? fullName,
    String? postScriptName,
    String? version,
    String? manufacturer,
  }) {
    final full = fullName ?? '$family $subfamily';
    final ps = postScriptName ??
        family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final entries = <MapEntry<int, String>>[
      MapEntry(1, family),
      MapEntry(2, subfamily),
      MapEntry(3, 'atmos_ttf:$ps'),
      MapEntry(4, full),
      MapEntry(5, version ?? 'Version 1.000'),
      MapEntry(6, ps),
      if (manufacturer != null) MapEntry(8, manufacturer),
    ];
    return TtfName([
      for (final e in entries)
        TtfNameRecord(
          platformId: 3,
          encodingId: 1,
          languageId: 0x0409,
          nameId: e.key,
          value: e.value,
        ),
    ]);
  }

  /// Name records.
  final List<TtfNameRecord> records;

  /// First value for [nameId], if any.
  ///
  /// Первое значение для [nameId], если есть.
  String? valueFor(int nameId) {
    for (final r in records) {
      if (r.nameId == nameId) return r.value;
    }
    return null;
  }

  /// Encodes format 0 with UTF-16BE storage for Windows records.
  ///
  /// Кодирует format 0 с UTF-16BE для Windows-записей.
  Uint8List encode() {
    final encoded = <Uint8List>[];
    for (final rec in records) {
      encoded.add(_encodeName(rec.platformId, rec.encodingId, rec.value));
    }
    final count = records.length;
    const headerSize = 6;
    final recordSize = count * 12;
    final stringOffset = headerSize + recordSize;
    final w = BinaryWriter()
      ..writeUint16(0)
      ..writeUint16(count)
      ..writeUint16(stringOffset);
    var offset = 0;
    for (var i = 0; i < count; i++) {
      final rec = records[i];
      final bytes = encoded[i];
      w
        ..writeUint16(rec.platformId)
        ..writeUint16(rec.encodingId)
        ..writeUint16(rec.languageId)
        ..writeUint16(rec.nameId)
        ..writeUint16(bytes.length)
        ..writeUint16(offset);
      offset += bytes.length;
    }
    encoded.forEach(w.writeBytes);
    return w.toBytes();
  }
}

class _NameHeader {
  _NameHeader({
    required this.platformId,
    required this.encodingId,
    required this.languageId,
    required this.nameId,
    required this.length,
    required this.offset,
  });

  final int platformId;
  final int encodingId;
  final int languageId;
  final int nameId;
  final int length;
  final int offset;
}

String _decodeName(int platformId, int encodingId, Uint8List bytes) {
  if (platformId == 1) {
    return latin1.decode(bytes, allowInvalid: true);
  }
  // Unicode / Windows Unicode
  if (bytes.length.isOdd) {
    return latin1.decode(bytes, allowInvalid: true);
  }
  final codeUnits = <int>[];
  for (var i = 0; i < bytes.length; i += 2) {
    codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
  }
  return String.fromCharCodes(codeUnits);
}

Uint8List _encodeName(int platformId, int encodingId, String value) {
  if (platformId == 1) {
    return Uint8List.fromList(latin1.encode(value));
  }
  final out = Uint8List(value.length * 2);
  for (var i = 0; i < value.length; i++) {
    final cu = value.codeUnitAt(i);
    out[i * 2] = (cu >> 8) & 0xFF;
    out[i * 2 + 1] = cu & 0xFF;
  }
  return out;
}
