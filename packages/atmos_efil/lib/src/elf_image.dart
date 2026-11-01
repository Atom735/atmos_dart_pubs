import 'dart:convert';
import 'dart:typed_data';

import 'byte_cursor.dart';
import 'format.dart';
import 'image.dart';

/// ELF32 or ELF64 image.
class ElfImage extends ExecutableImage {
  ElfImage._({
    required this.elfClass,
    required this.machine,
    required this.type,
    required this.endian,
    required this.programHeaders,
    required List<ExecutableSection> sections,
    required Uint8List bytes,
    required int entryPoint,
    required int entryOffset,
  })  : _sections = sections,
        _bytes = bytes,
        _entryPoint = entryPoint,
        _entryOffset = entryOffset;

  /// Parses [source]. The image keeps its own copy.
  factory ElfImage.parse(Uint8List source) {
    if (source.length < 16 ||
        source[0] != 0x7F ||
        source[1] != 0x45 ||
        source[2] != 0x4C ||
        source[3] != 0x46) {
      throw ExecutableFormatException('Not an ELF image.');
    }
    final elfClass = source[4];
    if (elfClass != 1 && elfClass != 2) {
      throw ExecutableFormatException('Unsupported ELF class $elfClass.');
    }
    final data = source[5];
    final Endian endian;
    if (data == 1) {
      endian = Endian.little;
    } else if (data == 2) {
      endian = Endian.big;
    } else {
      throw ExecutableFormatException('Unsupported ELF data encoding $data.');
    }
    final is64 = elfClass == 2;
    final bytes = Uint8List.fromList(source);
    final cursor = ByteCursor(bytes, endian);
    cursor.offset = 16;
    final type = cursor.u16();
    final machine = cursor.u16();
    cursor.skip(4);
    final entryOffset = cursor.offset;
    final entry = is64 ? cursor.u64() : cursor.u32();
    final phoff = is64 ? cursor.u64() : cursor.u32();
    final shoff = is64 ? cursor.u64() : cursor.u32();
    cursor.skip(4);
    cursor.skip(2);
    final phentsize = cursor.u16();
    final phnum = cursor.u16();
    final shentsize = cursor.u16();
    final shnum = cursor.u16();
    final shstrndx = cursor.u16();
    final minSh = is64 ? 64 : 40;
    final minPh = is64 ? 56 : 32;
    final counts = _resolveCounts(
      cursor: cursor,
      is64: is64,
      shoff: shoff,
      shentsize: shentsize,
      shnum: shnum,
      shstrndx: shstrndx,
      phnum: phnum,
      minSh: minSh,
      length: bytes.length,
    );
    if (counts.shnum > 0 && shentsize < minSh) {
      throw ExecutableFormatException('ELF section header is too small.');
    }
    if (counts.phnum > 0 && phentsize < minPh) {
      throw ExecutableFormatException('ELF program header is too small.');
    }
    requireInFile(
      shoff,
      counts.shnum * shentsize,
      bytes.length,
      'Section headers',
    );
    requireInFile(
      phoff,
      counts.phnum * phentsize,
      bytes.length,
      'Program headers',
    );
    final headers = _programHeaders(
      cursor,
      is64,
      phoff,
      phentsize,
      counts.phnum,
    );
    final raw = _rawSections(cursor, is64, shoff, shentsize, counts.shnum);
    if (counts.clearFirstSize && raw.isNotEmpty) {
      raw[0] = raw[0].withoutSize();
    }
    final names = _names(bytes, raw, counts.shstrndx);
    final sections = <ExecutableSection>[];
    for (var i = 0; i < raw.length; i++) {
      final row = raw[i];
      if (row.fileSize > 0) {
        requireInFile(row.fileOffset, row.fileSize, bytes.length, 'Section');
      }
      sections.add(
        ExecutableSection(
          name: names[i],
          virtualAddress: row.virtualAddress,
          virtualSize: row.virtualSize,
          fileOffset: row.fileOffset,
          fileSize: row.fileSize,
          flags: row.flags,
          image: bytes,
        ),
      );
    }
    return ElfImage._(
      elfClass: elfClass,
      machine: machine,
      type: type,
      endian: endian,
      programHeaders: headers,
      sections: sections,
      bytes: bytes,
      entryPoint: entry,
      entryOffset: entryOffset,
    );
  }

  /// `1` for ELF32, `2` for ELF64.
  final int elfClass;

  /// `e_machine`.
  final int machine;

  /// `e_type`.
  final int type;

  /// Encoding from `e_ident`.
  final Endian endian;

  /// Program headers in file order.
  final List<ElfProgramHeader> programHeaders;

  final List<ExecutableSection> _sections;
  final Uint8List _bytes;
  int _entryPoint;
  final int _entryOffset;

  /// True for ELF64.
  bool get is64 => elfClass == 2;

  @override
  ExecutableFormat get format => ExecutableFormat.elf;

  @override
  int get entryPoint => _entryPoint;

  @override
  set entryPoint(int value) {
    final bits = is64 ? 64 : 32;
    if (value < 0 || value.bitLength > bits) {
      throw ExecutableEditException(
        'Entry point does not fit the ELF header field.',
      );
    }
    final cursor = ByteCursor(_bytes, endian);
    if (is64) {
      cursor.setU64(_entryOffset, value);
    } else {
      cursor.setU32(_entryOffset, value);
    }
    _entryPoint = value;
  }

  @override
  List<ExecutableSection> get sections => List.unmodifiable(_sections);

  @override
  Uint8List toBytes() => Uint8List.fromList(_bytes);
}

/// One ELF program header.
class ElfProgramHeader {
  /// Creates a program header.
  const ElfProgramHeader({
    required this.type,
    required this.flags,
    required this.offset,
    required this.virtualAddress,
    required this.physicalAddress,
    required this.fileSize,
    required this.memorySize,
    required this.alignment,
  });

  /// `p_type`.
  final int type;

  /// `p_flags`.
  final int flags;

  /// `p_offset`.
  final int offset;

  /// `p_vaddr`.
  final int virtualAddress;

  /// `p_paddr`.
  final int physicalAddress;

  /// `p_filesz`.
  final int fileSize;

  /// `p_memsz`.
  final int memorySize;

  /// `p_align`.
  final int alignment;
}

class _RawSection {
  const _RawSection({
    required this.nameOffset,
    required this.flags,
    required this.virtualAddress,
    required this.virtualSize,
    required this.fileOffset,
    required this.fileSize,
  });

  final int nameOffset;
  final int flags;
  final int virtualAddress;
  final int virtualSize;
  final int fileOffset;
  final int fileSize;

  _RawSection withoutSize() {
    return _RawSection(
      nameOffset: nameOffset,
      flags: flags,
      virtualAddress: virtualAddress,
      virtualSize: 0,
      fileOffset: fileOffset,
      fileSize: 0,
    );
  }
}

class _Counts {
  const _Counts({
    required this.shnum,
    required this.shstrndx,
    required this.phnum,
    required this.clearFirstSize,
  });

  final int shnum;
  final int shstrndx;
  final int phnum;
  final bool clearFirstSize;
}

_Counts _resolveCounts({
  required ByteCursor cursor,
  required bool is64,
  required int shoff,
  required int shentsize,
  required int shnum,
  required int shstrndx,
  required int phnum,
  required int minSh,
  required int length,
}) {
  final extended =
      shoff != 0 && (shnum == 0 || shstrndx == 0xFFFF || phnum == 0xFFFF);
  if (!extended) {
    return _Counts(
      shnum: shnum,
      shstrndx: shstrndx,
      phnum: phnum,
      clearFirstSize: false,
    );
  }
  if (shentsize < minSh) {
    throw ExecutableFormatException('ELF section header is too small.');
  }
  requireInFile(shoff, shentsize, length, 'Section headers');
  cursor.offset = shoff;
  cursor.skip(8);
  if (is64) {
    cursor.skip(24);
  } else {
    cursor.skip(12);
  }
  final size = is64 ? cursor.u64() : cursor.u32();
  final link = cursor.u32();
  final info = cursor.u32();
  return _Counts(
    shnum: shnum == 0 ? size : shnum,
    shstrndx: shstrndx == 0xFFFF ? link : shstrndx,
    phnum: phnum == 0xFFFF ? info : phnum,
    clearFirstSize: shnum == 0,
  );
}

List<ElfProgramHeader> _programHeaders(
  ByteCursor cursor,
  bool is64,
  int phoff,
  int phentsize,
  int phnum,
) {
  final headers = <ElfProgramHeader>[];
  for (var i = 0; i < phnum; i++) {
    cursor.offset = phoff + i * phentsize;
    if (is64) {
      final type = cursor.u32();
      final flags = cursor.u32();
      headers.add(
        ElfProgramHeader(
          type: type,
          flags: flags,
          offset: cursor.u64(),
          virtualAddress: cursor.u64(),
          physicalAddress: cursor.u64(),
          fileSize: cursor.u64(),
          memorySize: cursor.u64(),
          alignment: cursor.u64(),
        ),
      );
    } else {
      final type = cursor.u32();
      final offset = cursor.u32();
      final virtualAddress = cursor.u32();
      final physicalAddress = cursor.u32();
      final fileSize = cursor.u32();
      final memorySize = cursor.u32();
      final flags = cursor.u32();
      final alignment = cursor.u32();
      headers.add(
        ElfProgramHeader(
          type: type,
          flags: flags,
          offset: offset,
          virtualAddress: virtualAddress,
          physicalAddress: physicalAddress,
          fileSize: fileSize,
          memorySize: memorySize,
          alignment: alignment,
        ),
      );
    }
  }
  return headers;
}

List<_RawSection> _rawSections(
  ByteCursor cursor,
  bool is64,
  int shoff,
  int shentsize,
  int shnum,
) {
  final rows = <_RawSection>[];
  for (var i = 0; i < shnum; i++) {
    cursor.offset = shoff + i * shentsize;
    final nameOffset = cursor.u32();
    final type = cursor.u32();
    final flags = is64 ? cursor.u64() : cursor.u32();
    final virtualAddress = is64 ? cursor.u64() : cursor.u32();
    final fileOffset = is64 ? cursor.u64() : cursor.u32();
    final size = is64 ? cursor.u64() : cursor.u32();
    final fileSize = type == 8 ? 0 : size;
    rows.add(
      _RawSection(
        nameOffset: nameOffset,
        flags: flags,
        virtualAddress: virtualAddress,
        virtualSize: size,
        fileOffset: fileOffset,
        fileSize: fileSize,
      ),
    );
  }
  return rows;
}

List<String> _names(Uint8List bytes, List<_RawSection> rows, int shstrndx) {
  if (shstrndx < 0 || shstrndx >= rows.length) {
    return List.filled(rows.length, '');
  }
  final table = rows[shstrndx];
  return [
    for (final row in rows)
      _sectionName(bytes, table.fileOffset, table.fileSize, row.nameOffset),
  ];
}

String _sectionName(Uint8List bytes, int base, int size, int nameOffset) {
  if (nameOffset < 0 || nameOffset >= size) return '';
  final start = base + nameOffset;
  final limit = base + size;
  var end = start;
  while (end < limit && bytes[end] != 0) {
    end++;
  }
  return ascii.decode(bytes.sublist(start, end), allowInvalid: true);
}
