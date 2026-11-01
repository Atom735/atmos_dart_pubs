import 'dart:convert';
import 'dart:typed_data';

import 'byte_cursor.dart';
import 'format.dart';
import 'image.dart';

/// PE32 or PE32+ image behind an `MZ` header.
class PeImage extends ExecutableImage {
  PeImage._({
    required this.machine,
    required this.is64,
    required this.subsystem,
    required List<ExecutableSection> sections,
    required Uint8List bytes,
    required int entryPoint,
    required int entryOffset,
  })  : _sections = sections,
        _bytes = bytes,
        _entryPoint = entryPoint,
        _entryOffset = entryOffset;

  /// Parses [source]. The image keeps its own copy.
  factory PeImage.parse(Uint8List source) {
    if (source.length < 0x40 || source[0] != 0x4D || source[1] != 0x5A) {
      throw ExecutableFormatException('Not an MZ image.');
    }
    final bytes = Uint8List.fromList(source);
    final cursor = ByteCursor(bytes, Endian.little);
    cursor.offset = 0x3C;
    final lfanew = cursor.u32();
    requireInFile(lfanew, 24, bytes.length, 'PE header');
    cursor.offset = lfanew;
    if (cursor.u32() != 0x00004550) {
      throw ExecutableFormatException('MZ image has no PE signature.');
    }
    final machine = cursor.u16();
    final sectionCount = cursor.u16();
    cursor.skip(12);
    final optionalSize = cursor.u16();
    cursor.skip(2);
    requireInFile(lfanew + 24, optionalSize, bytes.length, 'Optional header');
    if (optionalSize < 24) {
      throw ExecutableFormatException('PE optional header is too small.');
    }
    cursor.offset = lfanew + 24;
    final magic = cursor.u16();
    final is64 = magic == 0x20B;
    if (magic != 0x10B && magic != 0x20B) {
      throw ExecutableFormatException(
        'Unsupported PE optional magic 0x${magic.toRadixString(16)}.',
      );
    }
    cursor.offset = lfanew + 24 + 16;
    final entryOffset = cursor.offset;
    final entry = cursor.u32();
    var subsystem = 0;
    if (optionalSize >= 70) {
      final subsystemAt = lfanew + 24 + 68;
      if (subsystemAt + 2 <= lfanew + 24 + optionalSize) {
        cursor.offset = subsystemAt;
        subsystem = cursor.u16();
      }
    }
    final table = lfanew + 24 + optionalSize;
    requireInFile(table, sectionCount * 40, bytes.length, 'Section table');
    final sections = <ExecutableSection>[];
    for (var i = 0; i < sectionCount; i++) {
      final at = table + i * 40;
      cursor.offset = at + 8;
      final virtualSize = cursor.u32();
      final virtualAddress = cursor.u32();
      final rawSize = cursor.u32();
      final rawPointer = cursor.u32();
      cursor.skip(12);
      final flags = cursor.u32();
      final name = _sectionName(bytes.sublist(at, at + 8));
      if (rawSize > 0) {
        requireInFile(rawPointer, rawSize, bytes.length, 'Section "$name"');
      }
      sections.add(
        ExecutableSection(
          name: name,
          virtualAddress: virtualAddress,
          virtualSize: virtualSize,
          fileOffset: rawPointer,
          fileSize: rawSize,
          flags: flags,
          image: bytes,
        ),
      );
    }
    return PeImage._(
      machine: machine,
      is64: is64,
      subsystem: subsystem,
      sections: sections,
      bytes: bytes,
      entryPoint: entry,
      entryOffset: entryOffset,
    );
  }

  /// COFF `Machine`.
  final int machine;

  /// True for PE32+ (`0x20B`).
  final bool is64;

  /// Optional-header subsystem, or 0 when the header is too short.
  final int subsystem;

  final List<ExecutableSection> _sections;
  final Uint8List _bytes;
  int _entryPoint;
  final int _entryOffset;

  @override
  ExecutableFormat get format => ExecutableFormat.pe;

  @override
  int get entryPoint => _entryPoint;

  @override
  set entryPoint(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      throw ExecutableEditException('PE entry RVA must fit in uint32.');
    }
    ByteCursor(_bytes, Endian.little).setU32(_entryOffset, value);
    _entryPoint = value;
  }

  @override
  List<ExecutableSection> get sections => List.unmodifiable(_sections);

  @override
  Uint8List toBytes() => Uint8List.fromList(_bytes);
}

String _sectionName(List<int> raw) {
  var end = raw.indexOf(0);
  if (end < 0) end = raw.length;
  return ascii.decode(raw.sublist(0, end), allowInvalid: true);
}
